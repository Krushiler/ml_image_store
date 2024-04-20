import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/bloc/image_creation_bloc.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/kit/gap.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';
import 'package:ml_image_store_app/presentation/widgets/image_painter.dart';
import 'package:uuid/uuid.dart';

// TODO: Refactor

class EditingImageTab extends StatefulWidget {
  const EditingImageTab({super.key});

  @override
  State<EditingImageTab> createState() => _EditingImageTabState();
}

class _EditingImageTabState extends State<EditingImageTab> {
  ui.Image? image;
  ui.Size? canvasSize;

  final List<Point> points = [];

  bool createdImage = false;

  Future<void> _createImage(EditingState state) async {
    ui.decodeImageFromList(
      state.image,
      (result) {
        if (context.mounted) {
          setState(() {
            image = result;
          });
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        createdImage = true;
      });
    });
  }

  final nameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImageCreationBloc, ImageCreationState>(
      buildWhen: (prev, curr) => curr is EditingState,
      listenWhen: (prev, curr) => curr is EditingState && (prev is! EditingState || prev.image != curr.image),
      listener: (context, s) {
        final state = s as EditingState;
        _createImage(state);
      },
      builder: (context, s) {
        final state = s as EditingState;
        if (!createdImage) {
          _createImage(state);
        }
        return SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimens.md),
                      child: image != null
                          ? GestureDetector(
                              onPanStart: (event) {
                                if (state.sending) return;
                                if (canvasSize == null) return;
                                final offset = convertToImageOffset(
                                  event.localPosition,
                                  ui.Size(image!.width.toDouble(), image!.height.toDouble()),
                                  canvasSize!,
                                );
                                setState(() {
                                  points.add(Point(x: offset.dx.toInt(), y: offset.dy.toInt(), id: const Uuid().v4()));
                                });
                              },
                              child: CustomPaint(
                                painter: ImagePainter(
                                  image!,
                                  state.features,
                                  points: points,
                                  size: canvasSize,
                                  sizeChanged: (size) {
                                    canvasSize = size;
                                  },
                                ),
                                child: const SizedBox.expand(),
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimens.md, right: Dimens.md, bottom: Dimens.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            nameTextController.clear();
                            setState(() {
                              points.clear();
                            });
                          },
                          icon: const Icon(Icons.clear),
                        ),
                        Gap.md,
                        Expanded(
                          child: TextFormField(
                            controller: nameTextController,
                            decoration: const InputDecoration(labelText: 'Feature name'),
                          ),
                        ),
                        Gap.md,
                        IconButton(
                          onPressed: points.isNotEmpty
                              ? () {
                                  context.read<ImageCreationBloc>().add(
                                        ImageCreationEvent.addFeature(
                                          Feature(
                                            points: points.toList(),
                                            className: nameTextController.text,
                                            id: const Uuid().v4(),
                                          ),
                                        ),
                                      );
                                  nameTextController.clear();
                                  setState(() {
                                    points.clear();
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Dimens.md, left: Dimens.md, right: Dimens.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: !state.sending
                                ? () {
                                    context
                                        .read<ImageCreationBloc>()
                                        .add(const ImageCreationEvent.backToPickRequested());
                                  }
                                : null,
                            child: const Text('Back'),
                          ),
                        ),
                        Gap.md,
                        Expanded(
                          child: OutlinedButton(
                            onPressed: !state.sending && state.features.isNotEmpty
                                ? () {
                                    context.read<ImageCreationBloc>().add(const ImageCreationEvent.pointsCleared());
                                  }
                                : null,
                            child: const Text('Clear'),
                          ),
                        ),
                        Gap.md,
                        Expanded(
                          child: ElevatedButton(
                            onPressed: !state.sending
                                ? () {
                                    context.read<ImageCreationBloc>().add(const ImageCreationEvent.sendRequested());
                                  }
                                : null,
                            child: const Text('Send'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              if (state.sending) const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }
}

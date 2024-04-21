import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_image_store/model/folder/folder.dart';
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

class _EditingImageTabState extends State<EditingImageTab> with TickerProviderStateMixin {
  ui.Image? image;
  ui.Size? canvasSize;

  String? deletingFeatureId;

  final List<Point> points = [];

  bool createdImage = false;

  late final AnimationController deleteAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

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

  void _clear() {
    nameTextController.clear();
    setState(() {
      points.clear();
    });
  }

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
                              onTapDown: (event) {
                                final offset = convertToImageOffset(
                                  event.localPosition,
                                  ui.Size(image!.width.toDouble(), image!.height.toDouble()),
                                  canvasSize!,
                                );
                                double distance = 0;
                                Feature? nearestFeature;
                                for (final feature in state.features) {
                                  for (final point in feature.points) {
                                    final p = point.offset;
                                    final d = (offset - p).distance;
                                    if ((d < distance || distance == 0) && d < 20) {
                                      distance = d;
                                      nearestFeature = feature;
                                    }
                                  }
                                }
                                if (nearestFeature != null) {
                                  deletingFeatureId = nearestFeature.id;
                                  deleteAnimationController.forward(from: 0);
                                }
                              },
                              onTapUp: (event) {
                                if (deletingFeatureId != null && deleteAnimationController.isCompleted) {
                                  context
                                      .read<ImageCreationBloc>()
                                      .add(ImageCreationEvent.removeFeature(deletingFeatureId!));
                                  deleteAnimationController.stop();
                                  deleteAnimationController.value = 0;
                                }
                              },
                              onPanStart: (event) {
                                deleteAnimationController.stop();
                                deleteAnimationController.value = 0;
                                deletingFeatureId = null;
                                if (canvasSize == null) return;
                                final offset = convertToImageOffset(
                                  event.localPosition,
                                  ui.Size(image!.width.toDouble(), image!.height.toDouble()),
                                  canvasSize!,
                                );
                                setState(() {
                                  if (state.folder?.type == LabelType.bbox) {
                                    points.clear();
                                  }
                                  points.add(Point(x: offset.dx.toInt(), y: offset.dy.toInt(), id: const Uuid().v4()));
                                });
                              },
                              onPanUpdate: (event) {
                                if (state.folder?.type == LabelType.bbox) {
                                  if (canvasSize == null) return;
                                  final offset = convertToImageOffset(
                                    event.localPosition,
                                    ui.Size(image!.width.toDouble(), image!.height.toDouble()),
                                    canvasSize!,
                                  );
                                  setState(() {
                                    if (points.length > 1) {
                                      points.removeRange(1, points.length);
                                    }
                                    points.add(
                                      Point(x: offset.dx.toInt(), y: offset.dy.toInt(), id: const Uuid().v4()),
                                    );
                                  });
                                }
                              },
                              child: AnimatedBuilder(
                                animation: deleteAnimationController,
                                builder: (context, child) => CustomPaint(
                                  painter: ImagePainter(
                                    image!,
                                    state.features,
                                    labelType: state.folder?.type ?? LabelType.bbox,
                                    points: points,
                                    size: canvasSize,
                                    sizeChanged: (size) {
                                      canvasSize = size;
                                    },
                                    deletingFeatureId: deletingFeatureId,
                                    deleteAnimationValue: deleteAnimationController.value,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimens.md, right: Dimens.md, bottom: Dimens.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            _clear();
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
                          onPressed: points.isNotEmpty &&
                                  (state.folder?.type == LabelType.polygon ||
                                      (state.folder?.type == LabelType.bbox && points.length == 2))
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
                                  _clear();
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
                                    if (state.imageId == null) {
                                      context
                                          .read<ImageCreationBloc>()
                                          .add(const ImageCreationEvent.backToPickRequested());
                                    } else {
                                      context.pop();
                                    }
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

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/bloc/image_creation_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/tools/bbox_labeling_tool.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/tools/labeling_tool.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/tools/polygon_labeling_tool.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/kit/gap.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';
import 'package:ml_image_store_app/presentation/widgets/button/clickable_box.dart';
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

  String? selectedFeatureId;

  bool createdImage = false;
  bool createdTool = false;

  OverlayEntry? featureOverlay;
  Offset featureOverlayOffset = Offset.zero;

  late final AnimationController selectAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
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

  @override
  void initState() {
    super.initState();

    selectAnimationController.addListener(() {
      if (selectAnimationController.isDismissed && featureOverlay?.mounted == true) {
        featureOverlay?.remove();
      } else if (!(featureOverlay?.mounted ?? false)) {
        featureOverlay = _createOverlay(context);
        Overlay.of(context).insert(featureOverlay!);
      }
    });
  }

  void _clear() {
    nameTextController.clear();
    labelingTool.points = [];
  }

  void createLabelingTool(LabelType labelType) {
    setState(() {
      createdTool = true;
      labelingTool = switch (labelType) {
        LabelType.bbox => BboxLabelingTool(),
        LabelType.polygon => PolygonLabelingTool(),
      };
    });
  }

  LabelingTool labelingTool = BboxLabelingTool();

  @override
  void dispose() {
    if (featureOverlay?.mounted == true) {
      featureOverlay?.remove();
    }
    featureOverlay?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ImageCreationBloc, ImageCreationState>(
          listenWhen: (prev, curr) => curr is EditingState && (prev is! EditingState || prev.image != curr.image),
          listener: (context, s) {
            final state = s as EditingState;
            _createImage(state);
          },
        ),
        BlocListener<ImageCreationBloc, ImageCreationState>(
          listenWhen: (prev, curr) =>
              curr is EditingState && (curr.folder?.type != null || curr.folder?.type != prev.folder?.type),
          listener: (context, s) {
            final state = s as EditingState;
            createLabelingTool(state.folder!.type);
          },
        ),
      ],
      child: BlocBuilder<ImageCreationBloc, ImageCreationState>(
        buildWhen: (prev, curr) => curr is EditingState,
        builder: (context, s) {
          final state = s as EditingState;
          if (!createdTool && state.folder?.type != null) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              createLabelingTool(state.folder!.type);
            });
          }
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
                                    featureOverlayOffset = event.globalPosition;
                                    selectedFeatureId = nearestFeature.id;
                                    selectAnimationController.forward(from: 0);
                                  } else {
                                    if (canvasSize == null) return;
                                    final offset = convertToImageOffset(
                                      event.localPosition,
                                      ui.Size(image!.width.toDouble(), image!.height.toDouble()),
                                      canvasSize!,
                                    );
                                    labelingTool.onTapDown(offset);
                                  }
                                },
                                onTapUp: (event) {
                                  if (canvasSize == null) return;
                                  final offset = convertToImageOffset(
                                    event.localPosition,
                                    ui.Size(image!.width.toDouble(), image!.height.toDouble()),
                                    canvasSize!,
                                  );
                                  labelingTool.onTapUp(offset);
                                },
                                onPanStart: (event) {
                                  selectAnimationController.reverse();
                                  if (canvasSize == null) return;
                                  final offset = convertToImageOffset(
                                    event.localPosition,
                                    ui.Size(image!.width.toDouble(), image!.height.toDouble()),
                                    canvasSize!,
                                  );
                                  labelingTool.onPanStart(offset);
                                },
                                onPanUpdate: (event) {
                                  if (canvasSize == null) return;
                                  final offset = convertToImageOffset(
                                    event.localPosition,
                                    ui.Size(image!.width.toDouble(), image!.height.toDouble()),
                                    canvasSize!,
                                  );
                                  labelingTool.onPanUpdate(offset);
                                },
                                child: AnimatedBuilder(
                                  animation: selectAnimationController,
                                  builder: (context, child) => StreamBuilder<List<Point>>(
                                    stream: labelingTool.watchPoints(),
                                    builder: (context, snapshot) => CustomPaint(
                                      painter: ImagePainter(
                                        image!,
                                        state.features,
                                        labelType: state.folder?.type ?? LabelType.bbox,
                                        points: snapshot.data ?? [],
                                        size: canvasSize,
                                        sizeChanged: (size) {
                                          canvasSize = size;
                                        },
                                        selectedFeatureId: selectedFeatureId,
                                        selectionProgress: selectAnimationController.value,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
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
                          StreamBuilder(
                            stream: labelingTool.watchPoints(),
                            builder: (context, _) => IconButton(
                              onPressed: labelingTool.isValid
                                  ? () {
                                      context.read<ImageCreationBloc>().add(
                                            ImageCreationEvent.addFeature(
                                              Feature(
                                                points: labelingTool.points.toList(),
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
      ),
    );
  }

  OverlayEntry _createOverlay(BuildContext screenContext) {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 120,
        top: featureOverlayOffset.dy,
        left: featureOverlayOffset.dx,
        child: TapRegion(
          onTapOutside: (_) {
            selectAnimationController.reverse();
          },
          child: ScaleTransition(
            scale: CurveTween(curve: Curves.easeInOut).animate(selectAnimationController),
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.sm),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.primary.shade200),
                    borderRadius: BorderRadius.circular(Dimens.sm),
                    color: context.colors.background,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ClickableBox(
                          onTap: () {
                            screenContext
                                .read<ImageCreationBloc>()
                                .add(ImageCreationEvent.removeFeature(selectedFeatureId ?? ''));
                            selectAnimationController.reverse();
                          },
                          child: const ListTile(title: Text('Delete')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

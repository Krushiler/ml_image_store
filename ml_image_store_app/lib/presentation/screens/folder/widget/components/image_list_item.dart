import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ml_image_store/model/image/image.dart' as domain;
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';
import 'package:ml_image_store_app/presentation/widgets/button/clickable_box.dart';

class ImageListItem extends StatefulWidget {
  final domain.Image image;
  final VoidCallback? onDeletePressed;

  const ImageListItem({super.key, required this.image, this.onDeletePressed});

  @override
  State<ImageListItem> createState() => _ImageListItemState();
}

class _ImageListItemState extends State<ImageListItem> with TickerProviderStateMixin {
  OverlayEntry? overlayEntry;
  final link = LayerLink();

  late final AnimationController animator;

  @override
  void initState() {
    super.initState();

    animator = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    animator.addListener(() {
      if (animator.isDismissed && overlayEntry?.mounted == true) {
        overlayEntry?.remove();
      } else if (!(overlayEntry?.mounted ?? false)) {
        overlayEntry = _createOverlay(context);
        Overlay.of(context).insert(overlayEntry!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: link,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.sm),
        onTap: () {},
        onLongPress: () {
          animator.forward();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.sm),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimens.sm),
              border: Border.all(color: context.colors.primary),
            ),
            child: CachedNetworkImage(
              imageUrl: createImageUrl(context, widget.image.fileId),
              progressIndicatorBuilder: (context, url, progress) => Padding(
                padding: const EdgeInsets.all(Dimens.md),
                child: CircularProgressIndicator(value: progress.progress),
              ),
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlay(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        height: size.height,
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 0.0),
          child: TapRegion(
            onTapOutside: (_) {
              animator.reverse();
            },
            child: ScaleTransition(
              scale: CurveTween(curve: Curves.easeInOut).animate(animator),
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
                              widget.onDeletePressed?.call();
                              animator.reverse();
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
      ),
    );
  }
}

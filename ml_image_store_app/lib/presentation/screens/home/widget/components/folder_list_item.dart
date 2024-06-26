import 'package:flutter/material.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';
import 'package:ml_image_store_app/presentation/widgets/button/clickable_box.dart';

class FolderListItem extends StatefulWidget {
  final Folder folder;
  final VoidCallback? onPressed;
  final VoidCallback? onDeletePressed;

  const FolderListItem({super.key, required this.folder, this.onDeletePressed, this.onPressed});

  @override
  State<FolderListItem> createState() => _FolderListItemState();
}

class _FolderListItemState extends State<FolderListItem> with TickerProviderStateMixin {
  late OverlayEntry overlayEntry;
  final link = LayerLink();

  late final AnimationController animator;

  @override
  void initState() {
    super.initState();

    animator = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlayEntry = _createOverlay(context);
    });

    animator.addListener(() {
      if (animator.isDismissed && overlayEntry.mounted) {
        overlayEntry.remove();
      } else if (!overlayEntry.mounted) {
        overlayEntry = _createOverlay(context);
        Overlay.of(context).insert(overlayEntry);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: link,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.sm),
        onTap: () {
          widget.onPressed?.call();
        },
        onLongPress: () {
          animator.forward();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.sm),
            border: Border.all(color: context.colors.primary),
          ),
          padding: const EdgeInsets.all(Dimens.sm),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.folder.type.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.folder),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        widget.folder.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

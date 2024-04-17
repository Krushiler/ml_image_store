import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';

class AppDialog extends StatelessWidget {
  final Widget child;

  const AppDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.all(Dimens.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.sm),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(Dimens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.sm),
        ),
        child: Wrap(
          children: [
            child,
          ],
        ),
      ),
    );
  }
}

extension DialogContextExtension on BuildContext {
  Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) =>
      showDialog<T>(
        barrierDismissible: barrierDismissible,
        context: this,
        builder: (context) => AppDialog(child: child),
      );
}

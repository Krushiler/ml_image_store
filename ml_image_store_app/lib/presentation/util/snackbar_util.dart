import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';

extension SnackBarUtil on BuildContext {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
    String? message, {
    SnackBarAction? action,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message ?? ''),
      action: action,
    ));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showPrimarySnackBar(
    String message, {
    SnackBarAction? action,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: colors.primary,
        content: Text(message),
        padding: const EdgeInsets.symmetric(horizontal: Dimens.md, vertical: Dimens.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        action: action,
        dismissDirection: DismissDirection.up,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(this).size.height - Dimens.xl - Dimens.system(this).top - Dimens.appBarHeight,
          left: Dimens.md,
          right: Dimens.md,
        ),
      ),
    );
  }
}

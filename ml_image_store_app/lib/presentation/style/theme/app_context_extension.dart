import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_colors.dart';

extension AppContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppColors get colors => theme.extension<AppColors>()!;
}

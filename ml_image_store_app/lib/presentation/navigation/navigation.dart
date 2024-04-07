import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_image_store_app/presentation/navigation/routes.dart';

class Navigation {
  final BuildContext context;

  const Navigation(this.context);

  void navigateToHome() => context.goNamed(Routes.home.name);

  void navigateToAuth() => context.goNamed(Routes.auth.name);
}

extension NavigationExtension on BuildContext {
  Navigation get navigation => Navigation(this);
}

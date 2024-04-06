import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_image_store_app/presentation/navigation/routes.dart';

class AppRouter {
  late final GoRouter _router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/auth',
        name: Routes.auth.name,
        pageBuilder: (context, state) => _page(const SizedBox(), name: 'Dashboard'),
      ),
    ],
  );

  get router => _router;
}

Page _page(Widget child, {String? name}) {
  return MaterialPage(child: child, name: name);
}

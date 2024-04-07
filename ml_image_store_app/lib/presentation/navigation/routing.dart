import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_image_store_app/presentation/navigation/routes.dart';
import 'package:ml_image_store_app/presentation/screens/app/app_navigation_cubit.dart';
import 'package:ml_image_store_app/presentation/screens/auth/login/login_screen.dart';
import 'package:ml_image_store_app/presentation/screens/home/home_screen.dart';
import 'package:ml_image_store_app/presentation/util/go_router_refresh_stream.dart';

class AppRouter {
  final AppNavigationCubit _appNavigationCubit;

  AppRouter(this._appNavigationCubit);

  late final GoRouter _router = GoRouter(
    refreshListenable: GoRouterRefreshStream(_appNavigationCubit.stream),
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/auth',
        name: Routes.auth.name,
        pageBuilder: (context, state) => _page(const LoginScreen()),
      ),
      GoRoute(
        path: '/home',
        name: Routes.home.name,
        pageBuilder: (context, state) => _page(const HomeScreen()),
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AppNavigationCubit>().state;
      final isAuthPath = state.path?.startsWith('auth') ?? false;
      if (isAuthPath && authState.isSignedIn) {
        return '/home';
      }
      if (!isAuthPath && !authState.isSignedIn) {
        return '/auth';
      }
      return null;
    },
  );

  get router => _router;
}

Page _page(Widget child, {String? name}) {
  return MaterialPage(child: child, name: name);
}

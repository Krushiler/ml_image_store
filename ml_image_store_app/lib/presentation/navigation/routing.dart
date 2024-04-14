import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_image_store_app/presentation/navigation/routes.dart';
import 'package:ml_image_store_app/presentation/screens/app/app_navigation_cubit.dart';
import 'package:ml_image_store_app/presentation/screens/auth/login/login_screen.dart';
import 'package:ml_image_store_app/presentation/screens/folder/folder_screen.dart';
import 'package:ml_image_store_app/presentation/screens/home/home_screen.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/image_creation_screen.dart';
import 'package:ml_image_store_app/presentation/util/go_router_refresh_stream.dart';

class AppRouter {
  final bool isAuthorized;
  final AppNavigationCubit _appNavigationCubit;

  AppRouter(this.isAuthorized, this._appNavigationCubit);

  late final GoRouter _router = GoRouter(
    refreshListenable: GoRouterRefreshStream(_appNavigationCubit.stream),
    initialLocation: '/folders',
    routes: [
      GoRoute(
        path: '/auth',
        name: Routes.auth.name,
        pageBuilder: (context, state) => _page(const LoginScreen()),
      ),
      GoRoute(
        path: '/folders',
        name: Routes.folders.name,
        pageBuilder: (context, state) => _page(const HomeScreen()),
        routes: [
          GoRoute(
            path: ':id',
            name: Routes.folder.name,
            pageBuilder: (context, state) => _page(FolderScreen(folderId: state.pathParameters['id'] ?? '')),
            routes: [
              GoRoute(
                path: 'create-image',
                name: Routes.createImage.name,
                pageBuilder: (context, state) => _page(
                  ImageCreationScreen(folderId: state.pathParameters['id'] ?? ''),
                ),
              ),
            ],
          )
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AppNavigationCubit>().state;
      final isAuthPath = state.fullPath?.startsWith('/auth') ?? false;
      if (isAuthPath && authState.isSignedIn) {
        return '/folders';
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

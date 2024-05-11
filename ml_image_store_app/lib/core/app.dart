import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store/model/theme/theme_config.dart';
import 'package:ml_image_store_app/data/model/server_config.dart';
import 'package:ml_image_store_app/di/app_module.dart';
import 'package:ml_image_store_app/presentation/navigation/routing.dart';
import 'package:ml_image_store_app/presentation/screens/app/app_navigation_provider.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_scroll_behavior.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_theme.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  final bool isAuthorized;
  final ServerConfig serverConfig;

  const App({super.key, required this.isAuthorized, required this.serverConfig});

  @override
  Widget build(BuildContext context) {
    return AppModule(
      serverConfig: serverConfig,
      builder: (context) => AppNavigationProvider(
        builder: (context) {
          final router = AppRouter(isAuthorized, context.read());
          return Builder(
            builder: (context) => MaterialApp.router(
              scrollBehavior: const AppScrollBehavior(),
              theme: AppTheme(context.watch<ThemeConfig>()).createTheme(),
              routerConfig: router.router,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}

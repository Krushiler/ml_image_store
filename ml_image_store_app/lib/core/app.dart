import 'package:flutter/material.dart';
import 'package:ml_image_store/model/theme/theme_config.dart';
import 'package:ml_image_store_app/di/app_module.dart';
import 'package:ml_image_store_app/presentation/navigation/routing.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_theme.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return AppModule(
      builder: (context) => MaterialApp.router(
        theme: AppTheme(context.watch<ThemeConfig>()).createTheme(),
        routerConfig: router.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

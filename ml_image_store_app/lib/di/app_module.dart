import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/data/storage/theme_config_storage.dart';
import 'package:ml_image_store_app/di/provider_module.dart';

class AppModule extends StatelessWidget {
  final WidgetBuilder builder;

  const AppModule({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => ThemeConfigStorage()),
      ],
      child: ProviderModule(builder: (context) => builder(context)),
    );
  }
}

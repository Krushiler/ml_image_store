import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/data/network/dio_factory.dart';
import 'package:ml_image_store_app/data/network/ml_image_api.dart';
import 'package:ml_image_store_app/data/repository/auth_repository.dart';
import 'package:ml_image_store_app/data/storage/auth_storage.dart';
import 'package:ml_image_store_app/data/storage/theme_config_storage.dart';
import 'package:ml_image_store_app/di/provider_module.dart';
import 'package:ml_image_store_app/interactor/auth_interactor.dart';

class AppModule extends StatelessWidget {
  final WidgetBuilder builder;

  const AppModule({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        /// Storage
        RepositoryProvider(create: (context) => ThemeConfigStorage()),
        RepositoryProvider(create: (context) => AuthStorage()),

        /// Api
        RepositoryProvider(create: (context) => DioFactory(context.read())),
        RepositoryProvider(
          create: (context) => MlImageApi(context.read<DioFactory>().create(), baseUrl: 'http://10.0.0.2:8080'),
        ),

        /// Repository
        RepositoryProvider(create: (context) => AuthRepository(context.read(), context.read())),

        /// Interactor
        RepositoryProvider(create: (context) => AuthInteractor(context.read())),
      ],
      child: ProviderModule(builder: (context) => builder(context)),
    );
  }
}

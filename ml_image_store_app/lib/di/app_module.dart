import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/data/model/server_config.dart';
import 'package:ml_image_store_app/data/network/dio_factory.dart';
import 'package:ml_image_store_app/data/network/ml_image_api.dart';
import 'package:ml_image_store_app/data/repository/auth_repository.dart';
import 'package:ml_image_store_app/data/repository/config_repository.dart';
import 'package:ml_image_store_app/data/repository/folders_repository.dart';
import 'package:ml_image_store_app/data/repository/images_repository.dart';
import 'package:ml_image_store_app/data/storage/auth_storage.dart';
import 'package:ml_image_store_app/data/storage/folders_storage.dart';
import 'package:ml_image_store_app/data/storage/theme_config_storage.dart';
import 'package:ml_image_store_app/di/provider_module.dart';
import 'package:ml_image_store_app/interactor/auth_interactor.dart';
import 'package:provider/provider.dart';

class AppModule extends StatelessWidget {
  final ServerConfig serverConfig;
  final WidgetBuilder builder;

  const AppModule({super.key, required this.builder, required this.serverConfig});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        /// Config
        Provider<ServerConfig>.value(value: serverConfig),

        /// Storage
        RepositoryProvider(create: (context) => ThemeConfigStorage()),
        RepositoryProvider(create: (context) => AuthStorage()),
        RepositoryProvider(create: (context) => FoldersStorage()),
        RepositoryProvider(create: (context) => FolderImagesStorage()),

        /// Api
        RepositoryProvider(create: (context) => DioFactory(context.read())),
        RepositoryProvider(
          create: (context) => MlImageApi(
            context.read<DioFactory>().create(),
            baseUrl: context.read<ServerConfig>().baseUrl,
          ),
        ),

        /// Repository
        RepositoryProvider(create: (context) => AuthRepository(context.read(), context.read())),
        RepositoryProvider(create: (context) => FoldersRepository(context.read(), context.read<FoldersStorage>())),
        RepositoryProvider(create: (context) => ImagesRepository(context.read(), context.read<FolderImagesStorage>())),
        RepositoryProvider(create: (context) => ConfigRepository(context.read())),

        /// Interactor
        RepositoryProvider(create: (context) => AuthInteractor(context.read())),
      ],
      child: ProviderModule(builder: (context) => builder(context)),
    );
  }
}

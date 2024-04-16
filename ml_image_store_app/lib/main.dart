import 'package:flutter/material.dart';
import 'package:ml_image_store_app/core/app.dart';
import 'package:ml_image_store_app/data/model/server_config.dart';
import 'package:ml_image_store_app/data/storage/auth_storage.dart';
import 'package:ml_image_store_app/data/storage/storage_initializer.dart';

void main() async {
  await StorageInitializer.init();
  WidgetsFlutterBinding.ensureInitialized();

  final AuthStorage storage = AuthStorage();
  final isAuthorized = (await storage.get()) != null;

  const serverConfig = ServerConfig(baseUrl: 'https://ml-store-backend.powerofpoint.online');

  runApp(App(isAuthorized: isAuthorized, serverConfig: serverConfig));
}

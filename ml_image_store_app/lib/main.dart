import 'package:flutter/material.dart';
import 'package:ml_image_store_app/core/app.dart';
import 'package:ml_image_store_app/data/storage/storage_initializer.dart';

void main() async {
  await StorageInitializer.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

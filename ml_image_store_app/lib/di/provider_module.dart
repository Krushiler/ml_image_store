import 'package:flutter/material.dart';
import 'package:ml_image_store/model/theme/theme_config.dart';
import 'package:ml_image_store_app/data/storage/theme_config_storage.dart';
import 'package:provider/provider.dart';

class ProviderModule extends StatelessWidget {
  final WidgetBuilder builder;

  const ProviderModule({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<ThemeConfig>.value(
          value: context.read<ThemeConfigStorage>().watch().map((event) => event ?? ThemeConfig.defaultTheme()),
          initialData: ThemeConfig.defaultTheme(),
        ),
      ],
      builder: (context, _) => builder(context),
    );
  }
}

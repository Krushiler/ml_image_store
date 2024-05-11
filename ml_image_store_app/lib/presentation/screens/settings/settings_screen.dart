import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/settings/bloc/settings_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/settings/widget/settings_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(context.read()),
      child: const SettingsWidget(),
    );
  }
}

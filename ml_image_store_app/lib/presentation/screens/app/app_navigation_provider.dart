import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/app/app_navigation_cubit.dart';

class AppNavigationProvider extends StatelessWidget {
  final WidgetBuilder builder;

  const AppNavigationProvider({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppNavigationCubit>(
      create: (context) => AppNavigationCubit(context.read()),
      child: Builder(builder: (context) => builder(context)),
    );
  }
}

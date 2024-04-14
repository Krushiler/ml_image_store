import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/home/bloc/home_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/home/widget/home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(context.read(), context.read())..add(const HomeEvent.started()),
      child: const HomeWidget(),
    );
  }
}

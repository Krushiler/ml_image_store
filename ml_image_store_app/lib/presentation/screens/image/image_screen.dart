import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/image/bloc/image_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/image/widget/image_widget.dart';

class ImageScreen extends StatelessWidget {
  final String imageId;

  const ImageScreen({super.key, required this.imageId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImageBloc>(
      create: (context) => ImageBloc(imageId, context.read())..add(const ImageEvent.started()),
      child: const ImageWidget(),
    );
  }
}

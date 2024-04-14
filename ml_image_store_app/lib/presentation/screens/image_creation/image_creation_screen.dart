import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/bloc/image_creation_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/image_creation_widget.dart';

class ImageCreationScreen extends StatelessWidget {
  final String folderId;

  const ImageCreationScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImageCreationBloc>(
      create: (context) => ImageCreationBloc(folderId, context.read(), context.read()),
      child: const ImageCreationWidget(),
    );
  }
}

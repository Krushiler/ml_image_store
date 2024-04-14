import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/folder/bloc/folder_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/folder/widget/folder_widget.dart';

class FolderScreen extends StatelessWidget {
  final String folderId;

  const FolderScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FolderBloc>(
      create: (context) => FolderBloc(folderId, context.read(), context.read())..add(const FolderEvent.started()),
      child: const FolderWidget(),
    );
  }
}

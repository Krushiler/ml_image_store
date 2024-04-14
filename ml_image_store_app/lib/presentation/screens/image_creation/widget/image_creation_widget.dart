import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/bloc/image_creation_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/tabs/editing_image_tab.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/tabs/picking_image_tab.dart';

class ImageCreationWidget extends StatefulWidget {
  const ImageCreationWidget({super.key});

  @override
  State<ImageCreationWidget> createState() => _ImageCreationWidgetState();
}

class _ImageCreationWidgetState extends State<ImageCreationWidget> {
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCreationBloc, ImageCreationState>(
      builder: (context, state) {
        return Scaffold(
          body: BlocListener<ImageCreationBloc, ImageCreationState>(
            listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
            listener: (context, state) {
              final page = switch (state) {
                PickingState() => 0,
                EditingState() => 1,
                CreatedState() => 2,
                ImageCreationState() => null,
              };
              if (page != null) {
                pageController.animateToPage(
                  page,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const PickingImageTab(),
                const EditingImageTab(),
                Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}

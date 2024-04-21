import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/bloc/image_creation_bloc.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/kit/gap.dart';

class PickingImageTab extends StatefulWidget {
  const PickingImageTab({super.key});

  @override
  State<PickingImageTab> createState() => _PickingImageTabState();
}

class _PickingImageTabState extends State<PickingImageTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCreationBloc, ImageCreationState>(
      buildWhen: (prev, curr) => curr is PickingState,
      builder: (context, s) {
        if (s is! PickingState) return Container();
        final state = s;
        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.md),
                  child: state.image != null
                      ? Image.memory(state.image!)
                      : Center(
                          child: TextButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final file = await picker.pickImage(source: ImageSource.gallery);
                              final bytes = await file?.readAsBytes();
                              if (context.mounted && bytes != null) {
                                context.read<ImageCreationBloc>().add(ImageCreationEvent.imagePicked(bytes));
                              }
                            },
                            child: const Text('Select File'),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: Dimens.md, left: Dimens.md, right: Dimens.md),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    Gap.md,
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.image != null
                            ? () {
                                context.read<ImageCreationBloc>().add(const ImageCreationEvent.imagePicked(null));
                              }
                            : null,
                        child: const Text('Clear'),
                      ),
                    ),
                    Gap.md,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.image != null
                            ? () {
                                context.read<ImageCreationBloc>().add(const ImageCreationEvent.editingRequested());
                              }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

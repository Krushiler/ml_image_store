import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:ml_image_store_app/presentation/screens/image/bloc/image_bloc.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';
import 'package:ml_image_store_app/presentation/widgets/image_painter.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ui.Image? image;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImageBloc, ImageState>(
      listenWhen: (prev, curr) => curr.image != null && curr.image != prev.image,
      listener: (context, state) async {
        final file = await http.get(Uri.parse(createImageUrl(context, state.image!.fileId)));
        final bytes = file.bodyBytes;
        ui.decodeImageFromList(bytes, (result) {
          if (context.mounted) {
            setState(() {
              image = result;
            });
          }
        });
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Image'),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: image != null
              ? CustomPaint(
                  painter: ImagePainter(image!, state.image!.features),
                  child: const SizedBox.expand(),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

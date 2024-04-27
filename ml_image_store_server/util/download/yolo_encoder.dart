import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:ml_image_store/model/image/image.dart';

import 'download_encoder.dart';
import 'package:archive/archive_io.dart' as archive;
import 'package:image/image.dart' as img_util;

class YoloEncoder implements DownloadEncoder {
  @override
  FutureOr<Uint8List> encode(String filePath, List<Image> images, int? width, int? height, bool maintainAspect) {
    final encoder = archive.ZipFileEncoder()..create(filePath);

    try {
      for (var i = 0; i < images.length; i++) {
        final image = resizeImage(images[i], width, height, maintainAspect);

        final encodedImage = img_util.encodePng(image.bytes);
        final pointsString = jsonEncode(image.image.features);

        encoder..addArchiveFile(archive.ArchiveFile('image-$i.png', encodedImage.length, encodedImage))..addArchiveFile(
            archive.ArchiveFile('points-$i.json', pointsString.codeUnits.length, pointsString));
      }

      encoder.close();

      return File(filePath).readAsBytesSync();
    } catch(_) {
      encoder.close();
      rethrow;
    }
  }
}

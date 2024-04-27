import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart' as archive;
import 'package:image/image.dart' as img_util;
import 'package:ml_image_store/model/image/image.dart';

import 'download_encoder.dart';

class JsonEncoder implements DownloadEncoder {
  @override
  FutureOr<Uint8List> encode(String filePath, List<Image> images, int? width, int? height, bool maintainAspect) {
    final encoder = archive.ZipFileEncoder()..create(filePath);

    try {
      final labels = <String, int>{};
      final labelsReversed = <int, String>{};
      var labelIndex = 0;

      for (var i = 0; i < images.length; i++) {
        final image = resizeImage(images[i], width, height, maintainAspect);

        final pointsBuffer = StringBuffer();

        for (final feature in image.image.features) {
          if (feature.points.length != 2) continue;
          if (labels[feature.className] == null) {
            labels[feature.className] = labelIndex;
            labelsReversed[labelIndex] = feature.className;
            labelIndex++;
          }
          final centerX = (feature.points[0].x + feature.points[1].x).abs() / 2;
          final centerY = (feature.points[0].y + feature.points[1].y).abs() / 2;
          final centerWidth = (feature.points[0].x - feature.points[1].x).abs();
          final centerHeight = (feature.points[0].y - feature.points[1].y).abs();

          final yoloCenterX = centerX / (width ?? image.bytes.width);
          final yoloCenterY = centerY / (height ?? image.bytes.height);
          final yoloWidth = centerWidth / (width ?? image.bytes.width);
          final yoloHeight = centerHeight / (height ?? image.bytes.height);
          pointsBuffer.writeln('${labels[feature.className]} $yoloCenterX $yoloCenterY $yoloWidth $yoloHeight');
        }

        final pointsString = pointsBuffer.toString();
        final encodedImage = img_util.encodePng(image.bytes);

        encoder
          ..addArchiveFile(archive.ArchiveFile('images/image-$i.png', encodedImage.length, encodedImage))
          ..addArchiveFile(archive.ArchiveFile('labels/image-$i.txt', pointsString.codeUnits.length, pointsString));
      }

      final classesBuffer = StringBuffer();

      for (var i = 0; i < labelIndex; i++) {
        classesBuffer.writeln(labelsReversed[i]);
      }

      final classesString = classesBuffer.toString();

      encoder
        ..addArchiveFile(archive.ArchiveFile('classes.txt', classesString.codeUnits.length, classesString))
        ..close();

      return File(filePath).readAsBytesSync();
    } catch (_) {
      encoder.close();
      rethrow;
    }
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart' as archive;
import 'package:image/image.dart' as img_util;
import 'package:ml_image_store/model/image/image.dart';

import 'download_encoder.dart';

class CsvEncoder implements DownloadEncoder {
  @override
  FutureOr<Uint8List> encode(String filePath, List<Image> images, int? width, int? height, bool maintainAspect) {
    final encoder = archive.ZipFileEncoder()..create(filePath);

    try {
      final labels = <String, int>{};
      final labelsReversed = <int, String>{};
      var labelIndex = 0;

      final imageAnnotations = StringBuffer();
      final imagesMaps = StringBuffer();
      final categoriesMaps = StringBuffer();

      imageAnnotations.writeln('id, image_id, x, y, width, height, class_id');
      imagesMaps.writeln('id, width, height, file_name');
      categoriesMaps.writeln('id, class_name');

      int featureId = 0;
      int imageId = 0;

      for (var i = 0; i < images.length; i++) {
        imageId++;
        final image = resizeImage(images[i], width, height, maintainAspect);

        for (var j = 0; j < image.image.features.length; j++) {
          featureId++;
          final feature = image.image.features[j];
          if (labels[feature.className] == null) {
            labels[feature.className] = labelIndex;
            labelsReversed[labelIndex] = feature.className;
            labelIndex++;
          }
          int minX = image.bytes.width, minY = image.bytes.height, maxX = 0, maxY = 0;

          final segmentation = <List<int>>[];

          for (final p in feature.points) {
            if (p.x < minX) {
              minX = feature.points[0].x;
            }
            if (p.y < minY) {
              minY = feature.points[0].y;
            }
            if (p.x > maxX) {
              maxX = feature.points[0].x;
            }
            if (p.y > maxY) {
              maxY = feature.points[0].y;
            }
            segmentation.add([p.x, p.y]);
          }

          final bbox = <int>[minX, minY, maxX - minX, maxY - minY];

          imageAnnotations.writeln(
            '${featureId}, ${imageId}, ${bbox[0]}, ${bbox[1]}, ${bbox[2]}, ${bbox[3]}, ${labels[feature.className]}',
          );
        }

        imagesMaps.writeln('${imageId}, ${image.bytes.width}, ${image.bytes.height}, images/image-$imageId.png');

        final encodedImage = img_util.encodePng(image.bytes);

        encoder.addArchiveFile(archive.ArchiveFile('images/image-$imageId.png', encodedImage.length, encodedImage));
      }

      for (var i = 0; i < labelIndex; i++) {
        categoriesMaps.writeln('${i}, ${labelsReversed[i]}');
      }

      final categoriesMapsString = categoriesMaps.toString();
      final imagesMapsString = imagesMaps.toString();
      final imageAnnotationsString = imageAnnotations.toString();

      encoder
        ..addArchiveFile(
          archive.ArchiveFile('categories.csv', categoriesMapsString.length, categoriesMapsString.codeUnits),
        )
        ..addArchiveFile(
          archive.ArchiveFile('images.csv', imagesMapsString.length, imagesMapsString.codeUnits),
        )
        ..addArchiveFile(
          archive.ArchiveFile('annotations.csv', imageAnnotationsString.length, imageAnnotationsString.codeUnits),
        )
        ..close();

      return File(filePath).readAsBytesSync();
    } catch (_) {
      encoder.close();
      rethrow;
    }
  }
}

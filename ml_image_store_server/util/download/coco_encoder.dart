import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart' as archive;
import 'package:image/image.dart' as img_util;
import 'package:ml_image_store/model/image/image.dart';

import 'download_encoder.dart';

class CocoEncoder implements DownloadEncoder {
  @override
  FutureOr<Uint8List> encode(String filePath, List<Image> images, int? width, int? height, bool maintainAspect) {
    final encoder = archive.ZipFileEncoder()..create(filePath);

    try {
      final labels = <String, int>{};
      final labelsReversed = <int, String>{};
      var labelIndex = 0;

      final imageAnnotations = <Map<String, dynamic>>[];
      final imagesMaps = <Map<String, dynamic>>[];
      final categoriesMaps = <Map<String, dynamic>>[];

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

          imageAnnotations.add(
            {
              'segmentation': segmentation,
              'bbox': bbox,
              'id': featureId,
              'image_id': imageId,
              'category_id': labels[feature.className],
            },
          );
        }

        imagesMaps.add(
          {
            'id': imageId,
            'file_name': 'images/image-$imageId.png',
            'width': width ?? image.bytes.width,
            'height': height ?? image.bytes.height,
            'date_captured': image.image.createdAt.toIso8601String(),
          },
        );

        final encodedImage = img_util.encodePng(image.bytes);

        encoder.addArchiveFile(archive.ArchiveFile('images/image-$imageId.png', encodedImage.length, encodedImage));
      }

      for (var i = 0; i < labelIndex; i++) {
        categoriesMaps.add(
          {
            'id': i,
            'name': labelsReversed[i],
          },
        );
      }

      final fullJson = <String, dynamic>{
        'images': imagesMaps,
        'annotations': imageAnnotations,
        'categories': categoriesMaps,
      };

      final encoded = jsonEncode(fullJson);

      encoder
        ..addArchiveFile(archive.ArchiveFile('dataset.json', encoded.length, encoded))
        ..close();

      return File(filePath).readAsBytesSync();
    } catch (_) {
      encoder.close();
      rethrow;
    }
  }
}

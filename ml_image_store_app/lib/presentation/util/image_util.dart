import 'package:flutter/cupertino.dart';
import 'package:ml_image_store_app/data/model/server_config.dart';
import 'package:provider/provider.dart';

String createImageUrl(BuildContext context, String imageId) {
  return '${context.read<ServerConfig>().baseUrl}/files/$imageId';
}

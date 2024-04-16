import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_image_store_app/presentation/navigation/routes.dart';

class Navigation {
  final BuildContext context;

  const Navigation(this.context);

  void navigateToHome() => context.goNamed(Routes.folders.name);

  void navigateToFolder(String id) => context.goNamed(Routes.folder.name, pathParameters: {'id': id});

  void navigateToImageCreation(String id) => context.goNamed(Routes.createImage.name, pathParameters: {'id': id});

  void navigateToImage(String folderId, String imageId) => context.goNamed(Routes.image.name, pathParameters: {
        'id': folderId,
        'imageId': imageId,
      });

  void navigateToAuth() => context.goNamed(Routes.auth.name);
}

extension NavigationExtension on BuildContext {
  Navigation get navigation => Navigation(this);
}

import 'dart:async';

import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/point.dart' as domain;
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import 'storage_initializer.dart';

class Storage {
  Future<Connection> _connect() => StorageInitializer.connect();

  Future<T> execute<T>(FutureOr<T> Function(Connection conn) run) async {
    final conn = await _connect();
    final result = await run(conn);
    await conn.close();
    return result;
  }

  Future<List<ResultRow>> getUserFolders(String userId) async {
    try {
      return execute((conn) async {
        final rows = await conn.execute(
          r'SELECT * FROM folders WHERE ownerId=$1',
          parameters: [userId],
        );
        return rows;
      });
    } catch (_) {
      return const [];
    }
  }

  Future<List<ResultRow>> getFolderImages(String folderId) async {
    try {
      return execute((conn) async {
        final rows = await conn.execute(
          r'SELECT * FROM images WHERE folderId=$1',
          parameters: [folderId],
        );
        return rows;
      });
    } catch (_) {
      return const [];
    }
  }

  Future<ResultRow?> getFolder(String folderId) async {
    try {
      return execute((conn) async {
        final rows = await conn.execute(
          r'SELECT * FROM folders WHERE id=$1',
          parameters: [folderId],
        );
        return rows.firstOrNull;
      });
    } catch (_) {
      return null;
    }
  }

  Future<List<ResultRow>> getFeatures(String imageId) async {
    try {
      return execute((conn) async {
        final rows = await conn.execute(
          r'SELECT * FROM features WHERE imageId=$1',
          parameters: [imageId],
        );
        return rows;
      });
    } catch (_) {
      return [];
    }
  }

  Future<List<ResultRow>> getPoints(String featureId) async {
    try {
      return execute((conn) async {
        final rows = await conn.execute(
          r'SELECT * FROM points WHERE featureId=$1',
          parameters: [featureId],
        );
        return rows;
      });
    } catch (_) {
      return [];
    }
  }

  Future<ResultRow?> getImage(String id) async {
    try {
      return execute((conn) async {
        final rows = await conn.execute(
          r'SELECT * FROM images WHERE id=$1',
          parameters: [id],
        );
        return rows.firstOrNull;
      });
    } catch (_) {
      return null;
    }
  }

  Future<ResultRow?> getUserByLogin(String name) async {
    try {
      return execute((conn) async {
        final userRows = await conn.execute(
          r'SELECT * FROM users WHERE name=$1',
          parameters: [name],
        );
        return userRows.firstOrNull;
      });
    } catch (_) {
      return null;
    }
  }

  Future<ResultRow?> getUserByToken(String token) async {
    try {
      return execute((conn) async {
        final userRows = await conn.execute(
          r'SELECT * FROM users WHERE token=$1',
          parameters: [token],
        );
        return userRows.firstOrNull;
      });
    } catch (_) {
      return null;
    }
  }

  Future<String?> createUser(String name, String password) async {
    return execute((conn) async {
      final token = const Uuid().v4();
      final id = const Uuid().v4();
      await conn.execute(
        r'''
INSERT INTO users (id, name, password, token)
      VALUES ($1, $2, $3, $4)
      ''',
        parameters: [id, name, password, token],
      );
      return token;
    });
  }

  Future<int> createFolder(String userId, String name) async {
    try {
      return execute((conn) async {
        final id = const Uuid().v4();
        final userRows = await conn.execute(
          r'''
INSERT INTO folders (id, name, ownerId)
      VALUES ($1, $2, $3)
      ''',
          parameters: [id, name, userId],
        );
        return userRows.affectedRows;
      });
    } catch (_) {
      return 0;
    }
  }

  Future<int> deleteFolder(String id) async {
    try {
      return execute((conn) async {
        final rows = await conn.execute(
          r'''DELETE FROM folders WHERE id=$1''',
          parameters: [id],
        );
        return rows.affectedRows;
      });
    } catch (_) {
      return 0;
    }
  }

  Future<void> deleteFolderImages(String folder) {
    return execute((conn) async {
      await conn.execute(
        r'''DELETE FROM images WHERE folderId=$1''',
        parameters: [folder],
      );
    });
  }

  Future<void> deleteFeaturePoints(String featureId) {
    return execute((conn) async {
      await conn.execute(
        r'''DELETE FROM points WHERE featureId=$1''',
        parameters: [featureId],
      );
    });
  }

  Future<void> deleteImageFeatures(String imageId) {
    return execute((conn) async {
      await conn.execute(
        r'''DELETE FROM features WHERE imageId=$1''',
        parameters: [imageId],
      );
    });
  }

  Future<void> deleteImage(String id) {
    return execute((conn) async {
      await conn.execute(
        r'''DELETE FROM images WHERE id=$1''',
        parameters: [id],
      );
    });
  }

  Future<void> createImage(
    String id,
    String path,
    String folderId,
  ) {
    return execute((conn) async {
      await conn.execute(
        r'''
INSERT INTO images (id, path, folderId)
      VALUES ($1, $2, $3)
      ''',
        parameters: [
          id,
          path,
          folderId,
        ],
      );
    });
  }

  Future<void> createFeature(
    String id,
    String imageId,
    Feature feature,
  ) {
    return execute((conn) async {
      await conn.execute(
        r'''
INSERT INTO features (id, imageId, classname, bbox)
      VALUES ($1, $2, $3, $4)
      ''',
        parameters: [
          id,
          imageId,
          feature.className,
          feature.isBbox,
        ],
      );
    });
  }

  Future<void> createPoint(
    String id,
    String featureId,
    domain.Point point,
  ) {
    return execute((conn) async {
      await conn.execute(
        r'''
INSERT INTO points (id, featureId, leftTopX, leftTopY, radius)
      VALUES ($1, $2, $3, $4, $5)
      ''',
        parameters: [
          id,
          featureId,
          point.x,
          point.y,
          point.radius,
        ],
      );
    });
  }
}

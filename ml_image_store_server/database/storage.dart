import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import 'storage_initializer.dart';
import 'package:ml_image_store/model/image/point.dart' as domain;

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
        await conn.execute(
          r'''DELETE FROM images WHERE folderId=$1''',
          parameters: [id],
        );
        return rows.affectedRows;
      });
    } catch (_) {
      return 0;
    }
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
    domain.Point leftTop,
    domain.Point rightBottom,
  ) {
    return execute((conn) async {
      await conn.execute(
        r'''
INSERT INTO images (id, path, folderId, leftTopX, leftTopY, rightBottomX, rightBottomY)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      ''',
        parameters: [
          id,
          path,
          folderId,
          leftTop.x,
          leftTop.y,
          rightBottom.x,
          rightBottom.y,
        ],
      );
    });
  }
}

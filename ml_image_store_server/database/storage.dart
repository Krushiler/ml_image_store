import 'dart:async';

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

  Future<void> createFolder(String userId, String name) async {
    return execute((conn) async {
      final id = const Uuid().v4();
      await conn.execute(
        r'''
INSERT INTO folders (id, name, ownerId)
      VALUES ($1, $2, $3)
      ''',
        parameters: [id, name, userId],
      );
    });
  }

  Future<void> createImage(
    String id,
    String path,
    String folderId,
    Point leftTop,
    Point rightBottom,
  ) {
    return execute((conn) {
      conn.execute(r'''
INSERT INTO images (id, path, folder, leftTop, rightBottom)
      VALUES ($1, $2, $3, $4, $5)
      ''');
    });
  }
}

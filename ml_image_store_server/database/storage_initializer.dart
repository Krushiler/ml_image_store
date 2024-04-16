import 'package:postgres/postgres.dart';

class StorageInitializer {
  const StorageInitializer._();

  static Future<Connection> connect() async {
    final conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'ml_image_store',
        username: 'postgres',
        password: 'password',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    return conn;
  }

  static Future<Connection> initializeDatabase() async {
    final conn = await connect();

    await conn.runTx((session) async {
      await session.execute(r'''
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'imagepoint') THEN
        CREATE TYPE imagePoint AS (x int, y int);
    END IF;
END$$;
      ''');
      await session.execute('''
CREATE TABLE IF NOT EXISTS users (
    id TEXT NOT NULL, 
    name TEXT NOT NULL,
    password TEXT NOT NULL,
    token TEXT NOT NULL
    )''');
      await session.execute('''
CREATE TABLE IF NOT EXISTS images(
     id TEXT NOT NULL,
     path TEXT NOT NULL, 
     folderId TEXT NOT NULL, 
     leftTop imagePoint NOT NULL, 
     rightBottom imagePoint NOT NULL)
    ''');
      await session.execute('''
CREATE TABLE IF NOT EXISTS folders (
    id TEXT NOT NULL,
    name TEXT NOT NULL, 
    ownerId TEXT NOT NULL
    )''');
    });
    return conn;
  }
}

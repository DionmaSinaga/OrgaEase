import 'package:postgres/postgres.dart';
import 'db_config.dart';

/// Singleton koneksi PostgreSQL untuk OrgaEase.
///
/// Contoh pakai:
/// ```dart
/// final db = await Database.instance.connection;
/// final rows = await db.execute('SELECT 1');
/// ```
class Database {
  Database._();
  static final Database instance = Database._();

  Connection? _conn;

  Future<Connection> get connection async {
    final existing = _conn;
    if (existing != null && existing.isOpen) return existing;
    final conn = await Connection.open(
      Endpoint(
        host: DbConfig.host,
        port: DbConfig.port,
        database: DbConfig.database,
        username: DbConfig.username,
        password: DbConfig.password,
      ),
      settings: ConnectionSettings(
        sslMode: DbConfig.useSsl ? SslMode.require : SslMode.disable,
        connectTimeout: const Duration(seconds: 10),
        queryTimeout: const Duration(seconds: 30),
      ),
    );
    _conn = conn;
    return conn;
  }

  /// Tes koneksi cepat. Return true jika SELECT 1 berhasil.
  Future<bool> ping() async {
    try {
      final conn = await connection;
      final res = await conn.execute('SELECT 1');
      return res.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> close() async {
    await _conn?.close();
    _conn = null;
  }
}

class DbConfig {
  static const String host = 'localhost';
  static const int port = 5432;
  static const String database = 'orgaease_app_db';
  static const String username = 'postgres';
  static const String password = String.fromEnvironment('DB_PASSWORD');
  static const bool useSsl = false;

  /// True jika password sudah diisi via --dart-define=DB_PASSWORD=...
  static bool get hasPassword => password.isNotEmpty;
}


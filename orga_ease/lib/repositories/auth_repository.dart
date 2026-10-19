import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import '../core/database.dart';
import '../models/app_user.dart';

/// Repository auth yang bicara langsung ke tabel public.users.
///
/// Skema tabel yang diharapkan (dibuat via sql/init.sql):
///   users(id SERIAL PK, name TEXT, email TEXT UNIQUE,
///         password_hash TEXT, created_at TIMESTAMPTZ DEFAULT now())
class AuthRepository {
  final Database _db;
  AuthRepository({Database? db}) : _db = db ?? Database.instance;

  /// SHA-256(password). Untuk production gunakan bcrypt/argon2 di backend.
  String hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final conn = await _db.connection;
    try {
      final res = await conn.execute(
        Sql.named('''
          INSERT INTO users (name, email, password_hash)
          VALUES (@name, @email, @hash)
          RETURNING id, name, email, created_at
        '''),
        parameters: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'hash': hashPassword(password),
        },
      );
      return AppUser.fromMap(res.first.toColumnMap());
    } on ServerException catch (e) {
      // 23505 = unique_violation (email sudah terdaftar)
      if (e.code == '23505') {
        throw Exception('Email sudah terdaftar. Silakan login.');
      }
      rethrow;
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final conn = await _db.connection;
    final res = await conn.execute(
      Sql.named('''
        SELECT id, name, email, created_at FROM users
        WHERE email = @email AND password_hash = @hash
        LIMIT 1
      '''),
      parameters: {
        'email': email.trim().toLowerCase(),
        'hash': hashPassword(password),
      },
    );
    if (res.isEmpty) {
      throw Exception('Email atau kata sandi salah.');
    }
    return AppUser.fromMap(res.first.toColumnMap());
  }

  Future<bool> emailExists(String email) async {
    final conn = await _db.connection;
    final res = await conn.execute(
      Sql.named('SELECT 1 FROM users WHERE email = @email LIMIT 1'),
      parameters: {'email': email.trim().toLowerCase()},
    );
    return res.isNotEmpty;
  }
}

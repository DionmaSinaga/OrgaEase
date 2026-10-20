import 'dart:convert';

import 'package:postgres/postgres.dart';
import '../core/database.dart';
import '../models/organization.dart';

/// Repository organisasi — bicara ke tabel `public.organizations`
/// dan `public.organization_members`.
///
/// Skema yang diharapkan (lihat sql/init.sql):
///   organizations(id SERIAL PK, name TEXT UNIQUE, instansi TEXT,
///                 category TEXT, logo_url TEXT, address TEXT,
///                 description TEXT, contacts TEXT (JSON),
///                 created_by INT, created_at TIMESTAMPTZ)
///   organization_members(org_id INT, user_id INT, role TEXT,
///                        joined_at TIMESTAMPTZ, PK(org_id, user_id))
class OrganizationRepository {
  final Database _db;
  OrganizationRepository({Database? db}) : _db = db ?? Database.instance;

  /// Role otomatis untuk pembuat organisasi.
  static const String kepalaRole = 'Kepala Organisasi';

  static const String _selectColumns = '''
      o.id, o.name, o.instansi, o.category, o.logo_url, o.address,
      o.description, o.contacts, o.created_by, o.created_at,
      m.role AS my_role,
      (SELECT COUNT(*) FROM organization_members om
        WHERE om.org_id = o.id) AS member_count''';

  /// Daftar organisasi yang diikuti user (untuk halaman "Organisasi Saya").
  Future<List<Organization>> fetchMyOrganizations(int userId) async {
    final conn = await _db.connection;
    final res = await conn.execute(
      Sql.named('''
        SELECT $_selectColumns
        FROM organizations o
        INNER JOIN organization_members m ON m.org_id = o.id
        WHERE m.user_id = @uid
        ORDER BY o.name ASC
      '''),
      parameters: {'uid': userId},
    );
    return res.map((r) => Organization.fromMap(r.toColumnMap())).toList();
  }

  /// Detail organisasi berdasarkan nama (kunci route halaman organisasi).
  /// Return null jika tidak ditemukan.
  Future<Organization?> fetchByName(String name, int userId) async {
    final conn = await _db.connection;
    final res = await conn.execute(
      Sql.named('''
        SELECT $_selectColumns
        FROM organizations o
        LEFT JOIN organization_members m
          ON m.org_id = o.id AND m.user_id = @uid
        WHERE o.name = @name
        LIMIT 1
      '''),
      parameters: {'name': name, 'uid': userId},
    );
    if (res.isEmpty) return null;
    return Organization.fromMap(res.first.toColumnMap());
  }

  /// Buat organisasi baru. Primary key `id` dibuat otomatis oleh database,
  /// dan pembuat ([creatorId]) otomatis tercatat sebagai Kepala Organisasi.
  Future<Organization> createOrganization({
    required int creatorId,
    required String name,
    required String category,
    String? instansi,
    String? logoUrl,
    String? address,
    String? description,
    Map<String, String> contacts = const {},
  }) async {
    final conn = await _db.connection;
    try {
      return await conn.runTx((tx) async {
        final res = await tx.execute(
          Sql.named('''
            INSERT INTO organizations
              (name, instansi, category, logo_url, address, description,
               contacts, created_by)
            VALUES
              (@name, @instansi, @category, @logo, @address, @description,
               @contacts, @uid)
            RETURNING id, name, instansi, category, logo_url, address,
              description, contacts, created_by, created_at
          '''),
          parameters: {
            'name': name.trim(),
            'instansi': _nullIfEmpty(instansi),
            'category': category.trim(),
            'logo': _nullIfEmpty(logoUrl),
            'address': _nullIfEmpty(address),
            'description': _nullIfEmpty(description),
            'contacts': jsonEncode(contacts),
            'uid': creatorId,
          },
        );
        final map = res.first.toColumnMap();
        await tx.execute(
          Sql.named('''
            INSERT INTO organization_members (org_id, user_id, role)
            VALUES (@orgId, @uid, @role)
          '''),
          parameters: {
            'orgId': map['id'],
            'uid': creatorId,
            'role': kepalaRole,
          },
        );
        map['my_role'] = kepalaRole;
        map['member_count'] = 1;
        return Organization.fromMap(map);
      });
    } on ServerException catch (e) {
      // 23505 = unique_violation (nama organisasi sudah dipakai)
      if (e.code == '23505') {
        throw Exception('Nama organisasi sudah digunakan. Pilih nama lain.');
      }
      rethrow;
    }
  }

  static String? _nullIfEmpty(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
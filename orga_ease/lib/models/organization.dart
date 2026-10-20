import 'dart:convert';

/// Model organisasi — mirror tabel `public.organizations` plus agregat
/// keanggotaan user yang sedang login ([myRole], [memberCount]).
///
/// [name] (nama organisasi) dipakai sebagai kunci route halaman organisasi.
class Organization {
  final int id;
  final String name;
  final String? instansi;
  final String category;
  final String? logoUrl;
  final String? address;
  final String? description;

  /// Kontak resmi organisasi, mis. {"Instagram": "@orgresmi"}.
  final Map<String, String> contacts;
  final int? createdBy;
  final DateTime createdAt;

  /// Jabatan user yang sedang login di organisasi ini (null = bukan anggota).
  final String? myRole;

  /// Jumlah anggota organisasi (dihitung dari organization_members).
  final int memberCount;

  const Organization({
    required this.id,
    required this.name,
    this.instansi,
    required this.category,
    this.logoUrl,
    this.address,
    this.description,
    this.contacts = const {},
    this.createdBy,
    required this.createdAt,
    this.myRole,
    this.memberCount = 0,
  });

  factory Organization.fromMap(Map<String, dynamic> m) => Organization(
        id: _toInt(m['id']),
        name: (m['name'] ?? '').toString(),
        instansi: _textOrNull(m['instansi']),
        category: (m['category'] ?? 'Lainnya').toString(),
        logoUrl: _textOrNull(m['logo_url']),
        address: _textOrNull(m['address']),
        description: _textOrNull(m['description']),
        contacts: _parseContacts(m['contacts']),
        createdBy: m['created_by'] == null ? null : _toInt(m['created_by']),
        createdAt: m['created_at'] is DateTime
            ? m['created_at'] as DateTime
            : DateTime.tryParse('${m['created_at']}') ?? DateTime.now(),
        myRole: _textOrNull(m['my_role']),
        memberCount: _toInt(m['member_count']),
      );

  /// Inisial (maks. 2 huruf) untuk avatar fallback saat logo tidak ada.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static int _toInt(dynamic v, [int fallback = 0]) {
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? fallback;
  }

  static String? _textOrNull(dynamic v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  static Map<String, String> _parseContacts(dynamic raw) {
    try {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry('$k', '$v'));
      }
      if (raw is String && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry('$k', '$v'));
        }
      }
    } catch (_) {
      // JSON tidak valid -> anggap tanpa kontak.
    }
    return {};
  }
}
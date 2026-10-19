/// Model user OrgaEase, mirror tabel public.users.
class AppUser {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] as int,
        name: (m['name'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        createdAt: m['created_at'] is DateTime
            ? m['created_at'] as DateTime
            : DateTime.tryParse('${m['created_at']}') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'created_at': createdAt.toIso8601String(),
      };
}

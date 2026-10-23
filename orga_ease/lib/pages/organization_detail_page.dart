import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/models/app_user.dart';
import 'package:orga_ease/models/organization.dart';
import 'package:orga_ease/repositories/organization_repository.dart';
import 'package:orga_ease/widgets/app_top_bar.dart';

class _OrgMember {
  final String name;
  final String role;
  final String division;
  final String initials;
  final Color avatarColor;
  const _OrgMember({
    required this.name,
    required this.role,
    required this.division,
    required this.initials,
    required this.avatarColor,
  });
}

final List<_OrgMember> _dummyMembers = const [
  _OrgMember(name: 'Budi Santoso', role: 'Ketua Umum',
      division: 'Pengurus Harian', initials: 'BS', avatarColor: Color(0xFF834DFB)),
  _OrgMember(name: 'Rina Saputra', role: 'Wakil Ketua',
      division: 'Pengurus Harian', initials: 'RS', avatarColor: Color(0xFFFBD100)),
  _OrgMember(name: 'Andi Wijaya', role: 'Sekretaris',
      division: 'Divisi Keuangan', initials: 'AW', avatarColor: Color(0xFF2ECC71)),
  _OrgMember(name: 'Siti Rahma', role: 'Bendahara',
      division: 'Divisi Keuangan', initials: 'SR', avatarColor: Color(0xFF2ECC71)),
  _OrgMember(name: 'Dewi Lestari', role: 'Kepala Divisi',
      division: 'Divisi Kegiatan', initials: 'DL', avatarColor: Color(0xFFE74C3C)),
  _OrgMember(name: 'Joko Prasetyo', role: 'Anggota',
      division: 'Divisi Kegiatan', initials: 'JP', avatarColor: Color(0xFFE74C3C)),
  _OrgMember(name: 'Aulia Putri', role: 'Kepala Divisi',
      division: 'Divisi Humas', initials: 'AP', avatarColor: Color(0xFF6B6390)),
  _OrgMember(name: 'Rizal Firmansyah', role: 'Anggota',
      division: 'Divisi Humas', initials: 'RF', avatarColor: Color(0xFF6B6390)),
  _OrgMember(name: 'Maya Indah', role: 'Kepala Divisi',
      division: 'Divisi Pendidikan', initials: 'MI', avatarColor: Color(0xFF9B6BFF)),
  _OrgMember(name: 'Fajar Hidayat', role: 'Anggota',
      division: 'Divisi Pendidikan', initials: 'FH', avatarColor: Color(0xFF9B6BFF)),
];

Map<String, List<_OrgMember>> _groupByDivision(List<_OrgMember> members) {
  final Map<String, List<_OrgMember>> grouped = {};
  for (final m in members) {
    grouped.putIfAbsent(m.division, () => []).add(m);
  }
  return grouped;
}

class OrganizationDetailPage extends StatefulWidget {
  final AppUser user;
  final String orgName;
  final Organization? initial;
  const OrganizationDetailPage({
    super.key,
    required this.user,
    required this.orgName,
    this.initial,
  });
  @override
  State<OrganizationDetailPage> createState() => _OrganizationDetailPageState();
}
class _OrganizationDetailPageState extends State<OrganizationDetailPage> {
  final _repo = OrganizationRepository();
  Organization? _org;
  bool _loading = true;
  String? _error;
  int _selectedMenu = 0;

  @override
  void initState() {
    super.initState();
    _org = widget.initial;
    _load();
  }

  Future<void> _load() async {
    if (_org == null) setState(() => _loading = true);
    try {
      final org = await _repo.fetchByName(widget.orgName, widget.user.id);
      if (!mounted) return;
      setState(() {
        _org = org;
        _loading = false;
        _error = org == null ? 'Organisasi "${widget.orgName}" tidak ditemukan.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_org == null) {
          _error = e.toString().replaceFirst('Exception: ', '');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = _org;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        title: org?.name ?? 'Detail Organisasi',
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.subInk(context))),
                  ),
                )
              : _layout(_org!),
    );
  }

  /// Layout 3 kolom (desktop lebar) atau 1 kolom (mobile sempit).
  Widget _layout(Organization org) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;
        if (!isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _centerContent(org),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 250,
              child: _leftSidebar(org),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _centerContent(org),
              ),
            ),
            const VerticalDivider(width: 1),
            SizedBox(
              width: 280,
              child: _rightSidebar(),
            ),
          ],
        );
      },
    );
  }

  /// Sidebar kiri — menu navigasi dalam organisasi.
  Widget _leftSidebar(Organization org) {
    final menus = [
      _SidebarMenuItem('Beranda', Icons.dashboard_rounded),
      _SidebarMenuItem('Anggota', Icons.people_rounded),
      _SidebarMenuItem('Keuangan', Icons.account_balance_wallet_rounded),
      _SidebarMenuItem('Kegiatan', Icons.event_note_rounded),
      _SidebarMenuItem('Dokumen', Icons.description_rounded),
      _SidebarMenuItem('Pengaturan', Icons.settings_rounded),
    ];
    return Container(
      color: AppColors.card(context),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatarSmall(org),
                const SizedBox(height: 10),
                Text(
                  org.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.ink(context),
                  ),
                ),
                if (org.instansi != null && org.instansi!.isNotEmpty)
                  Text(
                    org.instansi!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.subInk(context, 0.7),
                    ),
                  ),
                const SizedBox(height: 6),
                if (org.myRole != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Jabatan: ${org.myRole}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...menus.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final selected = _selectedMenu == i;
            return _SidebarTile(
              label: item.label,
              icon: item.icon,
              selected: selected,
              onTap: () => setState(() => _selectedMenu = i),
            );
          }),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _SidebarTile(
              label: 'Keluar Organisasi',
              icon: Icons.logout_rounded,
              selected: false,
              color: AppColors.error,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarSmall(Organization org) {
    final logo = org.logoUrl;
    final Widget inner;
    if (logo != null && logo.isNotEmpty) {
      inner = ClipOval(
        child: Image.network(
          logo,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsAvatarSmall(org),
        ),
      );
    } else {
      inner = _initialsAvatarSmall(org);
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondaryColor, width: 2),
      ),
      child: inner,
    );
  }

  Widget _initialsAvatarSmall(Organization org) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.onHeaderText.withValues(alpha: 0.85),
        shape: BoxShape.circle,
      ),
      child: Text(org.initials,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }

  /// Konten tengah — detail organisasi (tanpa SingleChildScrollView).
  Widget _centerContent(Organization org) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _headerCard(org),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Tentang Organisasi',
          icon: Icons.info_outline_rounded,
          child: Text(
            org.description ?? 'Belum ada deskripsi untuk organisasi ini.',
            style: TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: org.description == null
                    ? AppColors.subInk(context)
                    : AppColors.ink(context)),
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Informasi Umum',
          icon: Icons.domain_outlined,
          child: Column(children: [
            _infoRow(Icons.account_balance_outlined, 'Instansi',
                org.instansi ?? 'Tidak disebutkan'),
            _infoRow(Icons.category_rounded, 'Kategori', org.category),
            _infoRow(Icons.location_on_outlined, 'Alamat',
                org.address ?? 'Tidak dicantumkan'),
            _infoRow(Icons.people_outline_rounded, 'Jumlah Anggota',
                '${org.memberCount} anggota'),
            _infoRow(Icons.calendar_today_outlined, 'Dibuat pada',
                _formatDate(org.createdAt)),
          ]),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Kontak Resmi',
          icon: Icons.contact_mail_outlined,
          child: _contactList(org),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Sidebar kanan — daftar anggota per divisi / jabatan.
  Widget _rightSidebar() {
    final grouped = _groupByDivision(_dummyMembers);
    final isDark = AppColors.isDark(context);
    return Container(
      color: AppColors.card(context),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.group_rounded,
                  size: 18, color: AppColors.primary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anggota (${_dummyMembers.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.ink(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: grouped.entries.map((entry) {
                final division = entry.key;
                final members = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary(context).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary(context).withValues(alpha: 0.25)),
                      ),
                      child: Text(division,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary(context),
                          )),
                    ),
                    const SizedBox(height: 8),
                    ...members.map((m) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2B1F47)
                              : const Color(0xFFF6F3FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.border(context).withValues(alpha: 0.5)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: m.avatarColor,
                            child: Text(
                              m.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(m.name,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink(context))),
                          subtitle: Text(m.role,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.subInk(context, 0.7))),
                          dense: true,
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final m = (d.month >= 1 && d.month <= 12) ? months[d.month] : '${d.month}';
    return '${d.day} $m ${d.year}';
  }

  /// Kartu header gradien: logo, nama, instansi, role, kategori, anggota.
  Widget _headerCard(Organization org) {
    const onGradient = AppColors.onHeaderText;
    final sub = AppColors.onHeaderSubtext(0.80);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.headerGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _headerAvatar(org),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(org.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: onGradient)),
                const SizedBox(height: 2),
                Text(org.instansi ?? 'Tanpa instansi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: sub)),
              ],
            ),
          ),
        ]),
        if (org.myRole != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.onHeaderText.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: AppColors.onHeaderText.withValues(alpha: 0.35)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.workspace_premium_rounded,
                  size: 15, color: onGradient),
              const SizedBox(width: 6),
              Text('Jabatanmu: ${org.myRole}',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: onGradient)),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _headerChip(Icons.category_rounded, org.category, onGradient),
          _headerChip(Icons.people_outline_rounded,
              '${org.memberCount} anggota', onGradient),
        ]),
      ]),
    );
  }

  Widget _headerAvatar(Organization org) {
    final logo = org.logoUrl;
    final Widget inner;
    if (logo != null && logo.isNotEmpty) {
      inner = ClipOval(
        child: Image.network(
          logo,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsAvatar(org),
        ),
      );
    } else {
      inner = _initialsAvatar(org);
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondaryColor, width: 2),
      ),
      child: inner,
    );
  }

  Widget _initialsAvatar(Organization org) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.onHeaderText.withValues(alpha: 0.85),
        shape: BoxShape.circle,
      ),
      child: Text(org.initials,
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }

  Widget _headerChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.onHeaderText.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  /// Card section berjudul dengan ikon.
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow(context),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary(context)),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink(context))),
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 17, color: AppColors.mutedIcon(context)),
        const SizedBox(width: 10),
        SizedBox(
          width: 130,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: AppColors.subInk(context))),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 13, color: AppColors.ink(context))),
        ),
      ]),
    );
  }

  Widget _contactList(Organization org) {
    if (org.contacts.isEmpty) {
      return Text('Belum ada kontak resmi yang dicantumkan.',
          style: TextStyle(fontSize: 13, color: AppColors.subInk(context)));
    }
    return Column(
      children: [
        for (final entry in org.contacts.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Icon(_contactIcon(entry.key),
                  size: 17, color: AppColors.primary(context)),
              const SizedBox(width: 10),
              SizedBox(
                width: 130,
                child: Text(entry.key,
                    style:
                        TextStyle(fontSize: 13, color: AppColors.subInk(context))),
              ),
              Expanded(
                child: Text(entry.value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink(context))),
              ),
            ]),
          ),
      ],
    );
  }

  IconData _contactIcon(String label) {
    switch (label.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'whatsapp':
        return Icons.phone_android_outlined;
      case 'tiktok':
        return Icons.music_note_outlined;
      case 'x (twitter)':
      case 'twitter':
        return Icons.alternate_email;
      case 'facebook':
        return Icons.facebook_outlined;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'website':
        return Icons.language_outlined;
      case 'email':
        return Icons.email_outlined;
      default:
        return Icons.contact_mail_outlined;
    }
  }
}

/// Data satu item menu sidebar organisasi.
class _SidebarMenuItem {
  final String label;
  final IconData icon;
  _SidebarMenuItem(this.label, this.icon);
}

/// Tile menu di sidebar kiri organisasi.
class _SidebarTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _SidebarTile({
    required this.label,
    required this.icon,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: selected
            ? c.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon,
                    size: 18,
                    color: selected ? c : AppColors.mutedIcon(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected ? c : AppColors.ink(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                if (selected)
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/models/app_user.dart';
import 'package:orga_ease/models/organization.dart';
import 'package:orga_ease/repositories/organization_repository.dart';

/// Halaman detail sebuah organisasi.
///
/// [orgName] adalah kunci route (nama organisasi). Data dimuat ulang dari
/// database berdasarkan nama itu; [initial] (opsional) dipakai agar halaman
/// langsung tampil saat dibuka dari card "Organisasi Saya".
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
        // Jika data awal dari card masih ada, tetap tampilkan.
        if (_org == null) {
          _error = e.toString().replaceFirst('Exception: ', '');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_org?.name ?? 'Detail Organisasi',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.subInk(context))),
        ),
      );
    }
    final org = _org!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
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
          ),
        ),
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
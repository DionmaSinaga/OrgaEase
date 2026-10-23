import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/models/app_user.dart';
import 'package:orga_ease/repositories/organization_repository.dart';
import 'package:orga_ease/widgets/auth_components.dart';
import 'package:orga_ease/widgets/auth_textfield.dart';
import 'package:orga_ease/widgets/app_top_bar.dart';

/// Form pembuatan organisasi baru (dibuka dari FAB "Organisasi Saya").
///
/// Isi form:
/// 1. Primary key — otomatis dari database (tidak bisa diisi).
/// 2. Nama organisasi (wajib).
/// 3. Instansi (opsional).
/// 4. Kategori (wajib, pilih dari dropdown).
/// 5. Logo organisasi (opsional, berupa URL gambar).
/// 6. Kontak organisasi (opsional, pilih via checkbox: Instagram,
///    WhatsApp, TikTok, dst. — setiap centang muncul kolom isian).
/// 7. Alamat organisasi (opsional).
/// 8. Deskripsi singkat (opsional).
///
/// Pembuat otomatis tercatat sebagai Kepala Organisasi.
class CreateOrganizationPage extends StatefulWidget {
  final AppUser user;
  const CreateOrganizationPage({super.key, required this.user});

  @override
  State<CreateOrganizationPage> createState() => _CreateOrganizationPageState();
}

class _ContactOption {
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType keyboard;
  const _ContactOption(this.label, this.icon, this.hint, this.keyboard);
}

class _CreateOrganizationPageState extends State<CreateOrganizationPage> {
  static const List<String> _categories = [
    'Organisasi Kemahasiswaan',
    'Lembaga Kemahasiswaan',
    'Unit Kegiatan Mahasiswa',
    'Organisasi Profesi',
    'Komunitas',
    'Sosial & Lingkungan',
    'Olahraga',
    'Seni & Budaya',
    'Teknologi',
    'Pendidikan',
    'Lainnya',
  ];

  static const List<_ContactOption> _contactOptions = [
    _ContactOption('Instagram', Icons.camera_alt_outlined,
        '@username.resmi', TextInputType.url),
    _ContactOption('WhatsApp', Icons.phone_android_outlined,
        '628xxxxxxxxxx', TextInputType.phone),
    _ContactOption('TikTok', Icons.music_note_outlined,
        '@username', TextInputType.url),
    _ContactOption('X (Twitter)', Icons.alternate_email,
        '@username', TextInputType.url),
    _ContactOption('Facebook', Icons.facebook_outlined,
        'nama.profil', TextInputType.url),
    _ContactOption('YouTube', Icons.play_circle_outline,
        'nama-channel', TextInputType.url),
    _ContactOption('Website', Icons.language_outlined,
        'https://organisasi.ac.id', TextInputType.url),
    _ContactOption('Email', Icons.email_outlined,
        'nama@organisasi.ac.id', TextInputType.emailAddress),
  ];

  final _formKey = GlobalKey<FormState>();
  final _repo = OrganizationRepository();

  final _nameCtrl = TextEditingController();
  final _instansiCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  /// Teks statis untuk field primary key (tidak bisa diisi manual).
  final _pkCtrl = TextEditingController(text: 'Otomatis dari database');

  String? _category;
  final Map<String, bool> _contactSelected = {
    for (final o in _contactOptions) o.label: false,
  };
  final Map<String, TextEditingController> _contactCtrls = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Bangkitkan preview logo saat URL berubah.
    _logoCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instansiCtrl.dispose();
    _logoCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _pkCtrl.dispose();
    for (final c in _contactCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _contactCtrl(_ContactOption o) =>
      _contactCtrls.putIfAbsent(o.label, () => TextEditingController());

  String _prettyError(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    setState(() => _saving = true);
    try {
      final contacts = <String, String>{};
      for (final o in _contactOptions) {
        if (_contactSelected[o.label] != true) continue;
        final value = _contactCtrl(o).text.trim();
        if (value.isNotEmpty) contacts[o.label] = value;
      }
      final org = await _repo.createOrganization(
        creatorId: widget.user.id,
        name: _nameCtrl.text.trim(),
        category: _category!.trim(),
        instansi: _instansiCtrl.text,
        logoUrl: _logoCtrl.text,
        address: _addressCtrl.text,
        description: _descCtrl.text,
        contacts: contacts,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Organisasi "${org.name}" berhasil dibuat. Kamu tercatat sebagai '
            '${OrganizationRepository.kepalaRole}.'),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_prettyError(e)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        title: 'Buat Organisasi',
        showThemeSwitch: true,
        showNotification: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // _pkField(),
                    // const SizedBox(height: 16),
                    _nameField(),
                    const SizedBox(height: 16),
                    _instansiField(),
                    const SizedBox(height: 16),
                    _categoryField(),
                    const SizedBox(height: 16),
                    _logoField(),
                    _logoPreview(),
                    const SizedBox(height: 20),
                    _contactSection(),
                    const SizedBox(height: 16),
                    _addressField(),
                    const SizedBox(height: 16),
                    _descField(),
                    const SizedBox(height: 22),
                    _submitNote(),
                    GradientButton(
                      text: 'Buat Organisasi',
                      isLoading: _saving,
                      gradientColors: GradientButton.themeGradient(context),
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 1. Primary key — otomatis dari database, tidak bisa diisi manual.
  // Widget _pkField() {
  //   return AuthTextField(
  //     controller: _pkCtrl,
  //     label: 'Primary Key (Otomatis dari DB)',
  //     hint: 'Dibuat otomatis oleh database saat disimpan',
  //     prefixIcon: Icons.fingerprint_rounded,
  //     enabled: false,
  //   );
  // }

  // 2. Nama organisasi (wajib) — juga dipakai sebagai kunci route.
  Widget _nameField() {
    return AuthTextField(
      controller: _nameCtrl,
      label: 'Nama Organisasi (Wajib)',
      hint: 'Contoh: Himpunan Mahasiswa Teknik Informatika',
      prefixIcon: Icons.badge_outlined,
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Nama organisasi wajib diisi';
        if (t.length < 3) return 'Minimal 3 karakter';
        return null;
      },
    );
  }

  // 3. Instansi (opsional).
  Widget _instansiField() {
    return AuthTextField(
      controller: _instansiCtrl,
      label: 'Instansi (Opsional)',
      hint: 'Contoh: Universitas Rimbamedan',
      prefixIcon: Icons.account_balance_outlined,
    );
  }

  // 4. Kategori (wajib, dropdown).
  Widget _categoryField() {
    final ink = AppColors.ink(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori (Wajib)',
            style: TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w600, color: ink)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _category,
          hint: Text('Pilih kategori organisasi',
              style: TextStyle(
                  color: AppColors.subInk(context, 0.7), fontSize: 14)),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Kategori wajib dipilih' : null,
          onChanged: (v) => setState(() => _category = v),
          decoration: _dropdownDecoration(),
        ),
      ],
    );
  }

  // 5. Logo organisasi (opsional, URL gambar) + preview.
  Widget _logoField() {
    return AuthTextField(
      controller: _logoCtrl,
      label: 'Logo Organisasi (Opsional)',
      hint: 'https://…/logo-organisasi.png',
      prefixIcon: Icons.image_outlined,
      keyboardType: TextInputType.url,
    );
  }

  Widget _logoPreview() {
    final url = _logoCtrl.text.trim();
    if (url.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(children: [
        ClipOval(
          child: Image.network(
            url,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 64,
              height: 64,
              color: AppColors.error.withValues(alpha: 0.10),
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppColors.error, size: 26),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Preview logo organisasi',
              style:
                  TextStyle(fontSize: 12.5, color: AppColors.subInk(context))),
        ),
      ]),
    );
  }

  // 6. Kontak organisasi — pilih via checkbox, isian muncul per centangan.
  Widget _contactSection() {
    final ink = AppColors.ink(context);
    final checked =
        _contactOptions.where((o) => _contactSelected[o.label] == true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kontak Organisasi (Opsional)',
            style: TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w600, color: ink)),
        const SizedBox(height: 4),
        Text('Centang kontak yang tersedia, lalu isi akun/handlenya.',
            style: TextStyle(
                fontSize: 12, color: AppColors.subInk(context, 0.7))),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _contactOptions.map(_contactTile).toList(),
        ),
        if (checked.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (final o in checked) ...[
            AuthTextField(
              controller: _contactCtrl(o),
              label: 'Kontak ${o.label}',
              hint: o.hint,
              prefixIcon: o.icon,
              keyboardType: o.keyboard,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  Widget _contactTile(_ContactOption o) {
    final selected = _contactSelected[o.label] ?? false;
    void toggle() => setState(() => _contactSelected[o.label] = !selected);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withValues(alpha: 0.10)
              : AppColors.field(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primaryColor
                : AppColors.fieldBorder(context),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: selected,
              onChanged: (_) => toggle(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 6),
          Icon(o.icon,
              size: 16,
              color: selected
                  ? AppColors.primaryColor
                  : AppColors.mutedIcon(context)),
          const SizedBox(width: 6),
          Text(o.label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.primaryColor
                      : AppColors.ink(context))),
        ]),
      ),
    );
  }

  // 7. Alamat organisasi (opsional).
  Widget _addressField() {
    return AuthTextField(
      controller: _addressCtrl,
      label: 'Alamat Organisasi (Opsional)',
      hint: 'Jalan, nomor gedung, kecamatan, kota…',
      prefixIcon: Icons.location_on_outlined,
      maxLines: 3,
    );
  }

  // 8. Deskripsi singkat (opsional).
  Widget _descField() {
    return AuthTextField(
      controller: _descCtrl,
      label: 'Deskripsi Singkat (Opsional)',
      hint: 'Ceritakan singkat tentang organisasimu…',
      prefixIcon: Icons.notes_rounded,
      maxLines: 4,
    );
  }

  Widget _submitNote() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(Icons.info_outline_rounded,
            size: 16, color: AppColors.mutedIcon(context)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Kamu akan otomatis tercatat sebagai '
            '${OrganizationRepository.kepalaRole}.',
            style:
                TextStyle(fontSize: 12, color: AppColors.subInk(context)),
          ),
        ),
      ]),
    );
  }

  InputDecoration _dropdownDecoration() {
    OutlineInputBorder border(Color? c, [double w = 1.0]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              c == null ? BorderSide.none : BorderSide(color: c, width: w),
        );
    return InputDecoration(
      filled: true,
      fillColor: AppColors.field(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      prefixIcon: Icon(Icons.category_outlined,
          color: AppColors.primary(context), size: 20),
      border: border(null),
      enabledBorder: border(AppColors.fieldBorder(context)),
      focusedBorder: border(AppColors.primary(context), 1.6),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.6),
    );
  }
}
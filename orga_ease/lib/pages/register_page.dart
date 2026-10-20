import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/repositories/auth_repository.dart';
import 'package:orga_ease/widgets/auth_layout.dart';
import 'package:orga_ease/widgets/auth_textfield.dart';
import 'package:orga_ease/widgets/auth_components.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _conf = TextEditingController();
  bool _o1 = true, _o2 = true, _load = false, _agree = false;

  @override
  void dispose() {
    _name.dispose(); _email.dispose();
    _pass.dispose(); _conf.dispose();
    super.dispose();
  }

  Future<void> _reg() async {
    if (!_form.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Centang persetujuan S&K terlebih dahulu.'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _load = true);
    try {
      await AuthRepository().register(
        name: _name.text,
        email: _email.text,
        password: _pass.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Akun berhasil dibuat! Silakan login.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _load = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Buat Akun',
      subtitle: 'Daftar dan mulai kelola organisasimu',
      icon: Icons.person_add_alt_rounded,
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Daftar Akun', style: TextStyle(fontSize: 22,
              fontWeight: FontWeight.w800, color: AppColors.ink(context))),
            const SizedBox(height: 4),
            Text('Lengkapi data di bawah ini', style: TextStyle(fontSize: 13,
              color: AppColors.subInk(context))),
            const SizedBox(height: 18),
            AuthTextField(controller: _name, label: 'Nama',
              hint: 'Nama kamu', prefixIcon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 12),
            AuthTextField(controller: _email, label: 'Email',
              hint: 'nama@email.com', prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !v!.contains('@') ? 'Email salah' : null),
            const SizedBox(height: 12),
            AuthTextField(controller: _pass, label: 'Sandi',
              hint: 'Minimal 6 karakter', prefixIcon: Icons.lock_outline,
              obscureText: _o1,
              suffixIcon: IconButton(
                icon: Icon(_o1 ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
                  color: AppColors.secondary(context), size: 20),
                onPressed: () => setState(() => _o1 = !_o1)),
              validator: (v) => v!.length < 6 ? 'Minimal 6' : null),
            const SizedBox(height: 12),
            AuthTextField(controller: _conf, label: 'Konfirmasi',
              hint: 'Ulangi sandi', prefixIcon: Icons.lock_outline,
              obscureText: _o2,
              suffixIcon: IconButton(
                icon: Icon(_o2 ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
                  color: AppColors.secondary(context), size: 20),
                onPressed: () => setState(() => _o2 = !_o2)),
              validator: (v) => v != _pass.text ? 'Tidak sama' : null),
            Row(children: [
              Checkbox(value: _agree,
                activeColor: AppColors.secondary(context),
                onChanged: (v) => setState(() => _agree = v ?? false)),
              Expanded(child: Text('Setuju S&K OrgaEase',
                style: TextStyle(fontSize: 12.5,
                  color: AppColors.ink(context)))),
            ]),
            GradientButton(text: 'Daftar', isLoading: _load,
              onPressed: _reg,
              gradientColors: GradientButton.themeTealGradient(context)),
            const SizedBox(height: 12),
            // Wrap agar tidak overflow saat jendela disempitkan.
            Wrap(alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Sudah punya akun? ',
                  style: TextStyle(fontSize: 13,
                    color: AppColors.ink(context))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('Masuk',
                    style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context)))),
              ]),
          ],
        ),
      ),
    );
  }
}

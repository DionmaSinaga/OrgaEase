import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';
import 'package:orga_ease/repositories/auth_repository.dart';
import 'package:orga_ease/widgets/auth_layout.dart';
import 'package:orga_ease/widgets/auth_textfield.dart';
import 'package:orga_ease/widgets/auth_components.dart';
import 'package:orga_ease/pages/home_page.dart';
import 'package:orga_ease/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obsc = true, _rem = false, _load = false;

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _load = true);
    try {
      final user = await AuthRepository().login(
        email: _email.text,
        password: _pass.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login berhasil! Selamat datang, ${user.name}.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      final friendly = msg.contains('password')
          ? 'Password database belum diisi. Jalankan dengan --dart-define=DB_PASSWORD=...'
          : msg.contains('SocketException') || msg.contains('Connection')
              ? 'Tidak bisa terhubung ke orgaease_app_db. Pastikan PostgreSQL 18 berjalan.'
              : msg;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(friendly),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _load = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Selamat Datang',
      subtitle: 'Masuk untuk mengelola organisasimu',
      icon: Icons.waving_hand_rounded,
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Masuk Akun', style: TextStyle(fontSize: 22,
              fontWeight: FontWeight.w800, color: AppColors.ink(context))),
            const SizedBox(height: 4),
            Text('Silakan isi data di bawah ini', style: TextStyle(
              fontSize: 13,
              color: AppColors.subInk(context))),
            const SizedBox(height: 20),
            AuthTextField(controller: _email, label: 'Email',
              hint: 'nama@email.com', prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email wajib diisi';
                if (!v.contains('@')) return 'Email tidak valid';
                return null;
              }),
            const SizedBox(height: 14),
            AuthTextField(controller: _pass, label: 'Kata Sandi',
              hint: 'Masukkan kata sandi', prefixIcon: Icons.lock_outline,
              obscureText: _obsc,
              suffixIcon: IconButton(
                icon: Icon(_obsc ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
                  color: AppColors.secondary(context), size: 20),
                onPressed: () => setState(() => _obsc = !_obsc)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Sandi wajib diisi';
                if (v.length < 6) return 'Minimal 6 karakter';
                return null;
              }),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Checkbox(value: _rem,
                    activeColor: AppColors.secondary(context),
                    onChanged: (v) =>
                      setState(() => _rem = v ?? false)),
                  Text('Ingat saya',
                    style: TextStyle(fontSize: 13,
                      color: AppColors.ink(context))),
                ]),
                TextButton(onPressed: () {},
                  child: Text('Lupa sandi?',
                    style: TextStyle(color: AppColors.primary(context),
                      fontWeight: FontWeight.w600, fontSize: 13))),
              ]),
            GradientButton(text: 'Masuk', isLoading: _load, onPressed: _login,
              gradientColors: GradientButton.themeGradient(context)),
            const SizedBox(height: 14),
            // Wrap agar tidak overflow / newline aneh saat jendela sempit.
            Wrap(alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Belum punya akun? ',
                  style: TextStyle(fontSize: 13,
                    color: AppColors.ink(context))),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const RegisterPage())),
                  child: Text('Daftar',
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

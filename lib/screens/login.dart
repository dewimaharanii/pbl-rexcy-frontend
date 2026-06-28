import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:rempang_eco_city/providers/admin_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/mitra_api_service.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'register.dart';
import 'forgot_password.dart';
import 'home_screen.dart';
import 'produsen/produsen_shell.dart';
import 'package:rempang_eco_city/screens/admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool _obscure   = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _errorMsg  = null;
      _isLoading = true;
    });

    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      setState(() {
        _errorMsg  = 'Username dan password wajib diisi';
        _isLoading = false;
      });
      return;
    }

    final username = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    try {
      // ── Admin ──────────────────────────────────────────
      final adminResult = await MitraApiService.loginAdmin(
        username: username,
        password: password,
      );
      print('=== ADMIN: $adminResult');

      if (!mounted) return;

      if (adminResult['success'] == true) {
        // 🔒 Admin hanya boleh login lewat Flutter Web, tidak boleh di HP
        if (!kIsWeb) {
          // Batalkan: hapus token admin yang baru saja didapat, jangan lanjut.
          await MitraApiService.logoutAdmin();
          setState(() => _errorMsg =
              'Akun Admin hanya bisa login melalui Web, silakan gunakan browser di laptop/PC.');
          return;
        }

        final userData = adminResult['data'];
        context.read<UserProvider>().setUser(UserModel(
          name:     userData['Nama_Admin'] ?? userData['Username'] ?? '',
          email:    userData['Username']   ?? '',
          phone:    '',
          password: '',
          role:     'admin',
        ));
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (route) => false,
        );
        return;
      }

      // ── Mitra ──────────────────────────────────────────
      final mitraResult = await MitraApiService.loginMitra(
        username: username,
        password: password,
      );
      print('=== MITRA: $mitraResult');

      if (!mounted) return;

      if (mitraResult['success'] == true) {
        final userData = mitraResult['data'];
        context.read<UserProvider>().setUser(UserModel(
          name:     userData['Nama_Mitra'] ?? '',
          email:    userData['Username']   ?? '',
          phone:    userData['No_HP']      ?? '',
          password: '',
          role:     'mitra',
        ));
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
        return;
      }

      // ── Produsen ───────────────────────────────────────
      final produsenResult = await MitraApiService.loginProdusen(
        username: username,
        password: password,
      );
      print('=== PRODUSEN: $produsenResult');

      if (!mounted) return;

      if (produsenResult['success'] == true) {
        final userData = produsenResult['data'];
        context.read<UserProvider>().setUser(UserModel(
          name:     userData['Nama_Produsen'] ?? '',
          email:    userData['Username']      ?? '',
          phone:    userData['No_HP']         ?? '',
          password: '',
          role:     'produsen',
        ));
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ProdusenShell()),
          (route) => false,
        );
        return;
      }

      setState(() => _errorMsg = 'Username atau password salah');

    } catch (e) {
      print('=== ERROR LOGIN: $e');
      setState(() => _errorMsg = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(height: 80, white: false),
                const SizedBox(height: 32),
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk ke akun kamu',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),

                if (_errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.deleteRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.deleteRed.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.deleteRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMsg!,
                            style: const TextStyle(
                                color: AppColors.deleteRed,
                                fontSize: 13)),
                      ),
                    ]),
                  ),
                ],

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: const Text('Lupa Password?',
                        style: TextStyle(color: AppColors.blue)),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Masuk',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? ',
                        style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('Daftar',
                          style: TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
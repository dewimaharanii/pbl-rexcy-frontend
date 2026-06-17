// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/mitra_api_service.dart';
import '../theme/app_theme.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _namaCtrl       = TextEditingController();
  final _noHpCtrl       = TextEditingController();
  final _passBaruCtrl   = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureKonfirm = true;

  @override
  void initState() {
    super.initState();
    // Isi form dari data user yang sedang login
    final user = context.read<UserProvider>().user;
    _namaCtrl.text  = user?.name  ?? '';
    _noHpCtrl.text  = user?.phone ?? '';
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noHpCtrl.dispose();
    _passBaruCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpanProfile() async {
    // Validasi nama
    if (_namaCtrl.text.trim().isEmpty) {
      _snackbar('Nama tidak boleh kosong', isError: true);
      return;
    }

    // Validasi password baru (hanya kalau diisi)
    if (_passBaruCtrl.text.isNotEmpty) {
      if (_passBaruCtrl.text.length < 6) {
        _snackbar('Password baru minimal 6 karakter', isError: true);
        return;
      }
      if (_passBaruCtrl.text != _konfirmasiCtrl.text) {
        _snackbar('Konfirmasi password tidak cocok', isError: true);
        return;
      }
    }

    // Panggil API via provider
    final result = await context.read<UserProvider>().updateProfileApi(
      nama:         _namaCtrl.text.trim(),
      noHp:         _noHpCtrl.text.trim(),
      passwordBaru: _passBaruCtrl.text.isNotEmpty ? _passBaruCtrl.text : null,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      _passBaruCtrl.clear();
      _konfirmasiCtrl.clear();
      _snackbar('Profil berhasil diperbarui!');
    } else {
      _snackbar(result['message'] ?? 'Gagal memperbarui profil', isError: true);
    }
  }

  Future<void> _logout() async {
    await MitraApiService.logoutMitra();
    if (!mounted) return;
    context.read<UserProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _snackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.deleteRed : AppColors.successGreen,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final user     = provider.user;
    final loading  = provider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 18, color: AppColors.deleteRed),
            label: const Text('Keluar',
                style: TextStyle(color: AppColors.deleteRed, fontSize: 13)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Avatar ──────────────────────────────────────────────────
            Center(
              child: Column(children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.blue.withOpacity(0.15),
                  child: Text(
                    (user?.name.isNotEmpty == true)
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue),
                  ),
                ),
                const SizedBox(height: 8),
                Text(user?.email ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.role.toUpperCase() ?? 'MITRA',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 32),

            // ── Form Data Diri ───────────────────────────────────────────
            _sectionTitle('Data Diri'),
            const SizedBox(height: 16),

            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 6),
            _buildTextField(_namaCtrl, 'Nama lengkap', Icons.person_outline),
            const SizedBox(height: 16),

            _buildLabel('Nomor HP'),
            const SizedBox(height: 6),
            _buildTextField(_noHpCtrl, 'Nomor HP', Icons.phone_outlined,
                type: TextInputType.phone),
            const SizedBox(height: 24),

            // ── Ganti Password ───────────────────────────────────────────
            const Divider(),
            const SizedBox(height: 16),
            _sectionTitle('Ganti Password'),
            const SizedBox(height: 4),
            const Text(
              'Kosongkan jika tidak ingin mengganti password',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            _buildLabel('Password Baru'),
            const SizedBox(height: 6),
            _buildPasswordField(
              _passBaruCtrl, 'Minimal 6 karakter',
              _obscurePass,
              () => setState(() => _obscurePass = !_obscurePass),
            ),
            const SizedBox(height: 16),

            _buildLabel('Konfirmasi Password Baru'),
            const SizedBox(height: 6),
            _buildPasswordField(
              _konfirmasiCtrl, 'Ulangi password baru',
              _obscureKonfirm,
              () => setState(() => _obscureKonfirm = !_obscureKonfirm),
            ),
            const SizedBox(height: 32),

            // ── Tombol Simpan ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _simpanProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Simpan Perubahan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
      );

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary),
      );

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.iconGrey, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.iconGrey),
        ),
      );

  Widget _buildPasswordField(
    TextEditingController ctrl,
    String hint,
    bool obscure,
    VoidCallback toggle,
  ) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.iconGrey, fontSize: 14),
          prefixIcon:
              const Icon(Icons.lock_outline, color: AppColors.iconGrey),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.iconGrey,
            ),
            onPressed: toggle,
          ),
        ),
      );
}
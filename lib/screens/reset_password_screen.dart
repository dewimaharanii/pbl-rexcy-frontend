import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/mitra_api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;
  final bool isProdusen;
  const ResetPasswordScreen({Key? key, required this.email, required this.token, this.isProdusen = false}) : super(key: key);
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _reset() async {
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi'), backgroundColor: AppColors.deleteRed));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password minimal 6 karakter'), backgroundColor: AppColors.deleteRed));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password tidak cocok'), backgroundColor: AppColors.deleteRed));
      return;
    }

    setState(() => _isLoading = true);
    final res = await MitraApiService.resetPassword(widget.email, widget.token, password, isProdusen: widget.isProdusen);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password berhasil direset. Silakan login dengan password baru'),
        backgroundColor: AppColors.successGreen,
      ));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const _BackToLogin()), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Gagal mereset password'),
        backgroundColor: AppColors.deleteRed,
      ));
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Reset Password',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buat Password Baru',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${widget.email}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 28),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Password baru (min. 6 karakter)',
                prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.iconGrey),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.iconGrey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: 'Konfirmasi password baru',
                prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.iconGrey),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppColors.iconGrey),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _reset,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackToLogin extends StatelessWidget {
  const _BackToLogin();
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

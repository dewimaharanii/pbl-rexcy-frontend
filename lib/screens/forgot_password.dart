import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/mitra_api_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isProdusen;
  const ForgotPasswordScreen({Key? key, this.isProdusen = false}) : super(key: key);
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  late bool _isProdusen;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isProdusen = widget.isProdusen;
  }

  Future<void> _kirim() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan email'), backgroundColor: AppColors.deleteRed));
      return;
    }

    setState(() => _isLoading = true);
    final res = await MitraApiService.forgotPassword(email, isProdusen: _isProdusen);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email, token: res['token'] ?? '', isProdusen: _isProdusen)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Gagal mengirim token'),
        backgroundColor: AppColors.deleteRed,
      ));
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Lupa Password',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reset Password',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Masukkan email untuk mendapatkan token reset',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRoleChip('Mitra', false),
                const SizedBox(width: 8),
                _buildRoleChip('Produsen', true),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.iconGrey),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kirim,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Kirim Token Reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, bool isProdusen) {
    final selected = _isProdusen == isProdusen;
    return GestureDetector(
      onTap: () => setState(() => _isProdusen = isProdusen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.blue),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppColors.blue,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

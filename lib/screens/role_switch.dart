import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class RoleSwitch extends StatelessWidget { 
  const RoleSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.waves, color: AppColors.blue, size: 48),
              const SizedBox(height: 12),
              const Text('Pilih Peran', style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Masuk sebagai apa?',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 40),
              _RoleCard(
                title: 'Pembeli',
                subtitle: 'Beli produk laut segar',
                icon: Icons.shopping_bag_outlined,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => HomeScreen())), // Hapus const di sini
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Mitra / Penjual',
                subtitle: 'Kelola dan jual produk Anda',
                icon: Icons.store_outlined,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => HomeScreen())), // Hapus const di sini
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({required this.title, required this.subtitle,
      required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.blue.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.blue, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: AppColors.blue, size: 16),
          ],
        ),
      ),
    );
  }
}
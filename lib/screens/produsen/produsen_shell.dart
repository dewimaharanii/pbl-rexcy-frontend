import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'daftar_produksi_screen.dart';
import 'stok_saya_screen.dart';
import 'permintaan_masuk_screen.dart';
import 'riwayat_transaksi_screen.dart';
import '../profile_screen.dart';

class ProdusenShell extends StatefulWidget {
  final int initialIndex;
  const ProdusenShell({super.key, this.initialIndex = 0});

  @override
  State<ProdusenShell> createState() => _ProdusenShellState();
}

class _ProdusenShellState extends State<ProdusenShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DaftarProduksiScreen(),
    StokSayaScreen(),
    PermintaanMasukScreen(),
    RiwayatTransaksiScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _ProdusenNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _ProdusenNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _ProdusenNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded,          label: 'Dashboard',  index: 0, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.inventory_2_outlined,  label: 'Produksi',   index: 1, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.layers_outlined,       label: 'Stok',       index: 2, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.inbox_outlined,        label: 'Pesanan',    index: 3, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.history_outlined,      label: 'Riwayat',    index: 4, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_outline_rounded,label: 'Profil',     index: 5, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.iconGrey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primary : AppColors.iconGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../providers/user_provider.dart';
import '../../services/mitra_api_service.dart';
import 'riwayat_transaksi_screen.dart';
import 'daftar_produksi_screen.dart';
import 'permintaan_masuk_screen.dart'; // Nama file tetap, tapi class kita ubah
import '../profile_screen.dart';


class ProdusenHomeScreen extends StatefulWidget {
  const ProdusenHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProdusenHomeScreen> createState() => _ProdusenHomeScreenState();
}

class _ProdusenHomeScreenState extends State<ProdusenHomeScreen> {
  int _navIndex = 0;

  final List<Widget> _screens = const [
    ProdusenDashboardContent(),
    DaftarProduksiScreen(),
    PermintaanMasukScreen(),
    RiwayatTransaksiScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produksi',
          ),
          NavigationDestination(
            // Ikon bisa diganti agar lebih mewakili Pesanan/List
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Pesanan', // <-- INI SUDAH DIUBAH MENJADI PESANAN
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Content ──────────────────────────────────────────
class ProdusenDashboardContent extends StatefulWidget {
  const ProdusenDashboardContent({Key? key}) : super(key: key);

  @override
  State<ProdusenDashboardContent> createState() =>
      _ProdusenDashboardContentState();
}

class _ProdusenDashboardContentState
    extends State<ProdusenDashboardContent> {
  int _totalProduk       = 0;
  int _totalPermintaan   = 0;
  int _totalTransaksi    = 0;
  bool _isLoading        = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final produksi   = await MitraApiService.getProdusenProduksi();
      final permintaan = await MitraApiService.getProdusenPermintaan();
      final transaksi  = await MitraApiService.getProdusenTransaksi();

      if (!mounted) return;
      setState(() {
        _totalProduk     = (produksi['data']   as List).length;
        _totalPermintaan = (permintaan['data'] as List).length;
        _totalTransaksi  = (transaksi['data']  as List).length;
        _isLoading       = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  const AppLogo(height: 36, white: false),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: AppColors.blue.withOpacity(0.15),
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // Greeting
                Text(
                  'Halo, ${user?.name ?? 'Produsen'}!',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola produksi dan pesanan kamu',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Stats cards
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(children: [
                    _StatCard(
                      icon:  Icons.inventory_2_outlined,
                      label: 'Produk',
                      value: '$_totalProduk',
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon:  Icons.list_alt_outlined,
                      label: 'Pesanan', // Diubah menjadi Pesanan
                      value: '$_totalPermintaan',
                      color: AppColors.statusWaiting,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon:  Icons.receipt_long_outlined,
                      label: 'Transaksi',
                      value: '$_totalTransaksi',
                      color: AppColors.successGreen,
                    ),
                  ]),
                const SizedBox(height: 28),

                // Menu cepat
                const Text(
                  'Menu Cepat',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _MenuCard(
                      icon:  Icons.add_box_outlined,
                      label: 'Tambah Produksi',
                      color: AppColors.blue,
                      onTap: () {
                         // Aksi pindah tab bisa ditambahkan nanti
                      },
                    ),
                    _MenuCard(
                      icon:  Icons.pending_actions_outlined,
                      label: 'Lihat Pesanan', // Diubah menjadi Pesanan
                      color: AppColors.statusWaiting,
                      onTap: () {
                        // Aksi pindah tab bisa ditambahkan nanti
                      },
                    ),
                    _MenuCard(
                      icon:  Icons.local_shipping_outlined,
                      label: 'Transaksi',
                      color: AppColors.successGreen,
                      onTap: () {},
                    ),
                    _MenuCard(
                      icon:  Icons.person_outline,
                      label: 'Profil Saya',
                      color: AppColors.iconGrey,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
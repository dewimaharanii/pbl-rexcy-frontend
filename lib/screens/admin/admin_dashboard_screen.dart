import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import 'admin_data_produsen_screen.dart';
import 'admin_data_mitra_screen.dart';
import 'admin_data_produksi_screen.dart';
import 'admin_data_transaksi_screen.dart';
import 'admin_laporan_screen.dart';
import 'admin_kelola_akun_screen.dart';
import 'admin_pembayaran_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
  
}


class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.people, label: 'Produsen'),
    _NavItem(icon: Icons.store, label: 'Mitra Hilir'),
    _NavItem(icon: Icons.inventory_2, label: 'Produksi'),
    _NavItem(icon: Icons.swap_horiz, label: 'Transaksi'),
    _NavItem(icon: Icons.bar_chart, label: 'Laporan'),
    _NavItem(icon: Icons.manage_accounts, label: 'Kelola Akun'),
    _NavItem(icon: Icons.payment, label: 'Pembayaran'),
  ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardHome();
      case 1:
        return const AdminDataProdusenScreen();
      case 2:
        return const AdminDataMitraScreen();
      case 3:
        return const AdminDataProduksiScreen();
      case 4:
        return const AdminDataTransaksiScreen();
      case 5:
        return const AdminLaporanScreen();
      case 6:
        return const AdminKelolaAkunScreen();
      case 7:
        return const AdminPembayaranScreen();
      default:
        return const _DashboardHome();
    }
  }

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AdminProvider>().loadAll();
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Sidebar ──
          Container(
            width: 220,
            color: const Color.fromARGB(255, 58, 111, 158),
            child: Column(
              children: [
                // Logo / Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Rempang Eco City',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        'Admin Panel',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 8),
                // Nav Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _navItems.length,
                    itemBuilder: (ctx, i) {
                      final item = _navItems[i];
                      final selected = _selectedIndex == i;
                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white24 : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(item.icon,
                                  color: selected ? Colors.white : Colors.white60,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.white60,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Logout
                const Divider(color: Colors.white24, height: 1),
                InkWell(
                 onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white60, size: 20),
                        SizedBox(width: 12),
                        Text('Logout',
                            style: TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Main Content ──
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 60,
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        _navItems[_selectedIndex].label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 18,
                        child: Text('A',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      const Text('Admin',
                          style: TextStyle(fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─── Dashboard Home Widget ─────────────────────────────────────────────────────

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    final cards = [
      _StatCard('Total Produsen', admin.totalProdusen.toString(),
          Icons.people, AppColors.primary),
      _StatCard('Total Mitra Hilir', admin.totalMitra.toString(),
          Icons.store, AppColors.info),
      _StatCard('Data Produksi', admin.totalProduksi.toString(),
          Icons.inventory_2, AppColors.accent),
      _StatCard('Total Transaksi', admin.totalTransaksi.toString(),
          Icons.swap_horiz, AppColors.warning),
      _StatCard('Menunggu Pembayaran', admin.transaksiMenunggu.toString(),
          Icons.pending_actions, AppColors.error),
      _StatCard(
          'Total Pendapatan',
          'Rp ${_fmt(admin.totalPendapatan)}',
          Icons.account_balance_wallet,
          AppColors.success),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selamat Datang, Admin 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Sistem Informasi Rantai Pasok Pangan Rempang Eco City',
              style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map((c) => SizedBox(width: 280, child: c))
                .toList(),
          ),
          const SizedBox(height: 32),
          // Recent Transactions
          const Text('Transaksi Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AppColors.primary.withOpacity(0.08)),
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Produsen')),
                  DataColumn(label: Text('Mitra')),
                  DataColumn(label: Text('Produk')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Status')),
                ],
                rows: admin.transaksiList.map((t) {
                  return DataRow(cells: [
                    DataCell(Text(t.id)),
                    DataCell(Text(t.produsenNama)),
                    DataCell(Text(t.mitraNama)),
                    DataCell(Text(t.produk)),
                    DataCell(Text('Rp ${_fmt(t.totalHarga)}')),
                    DataCell(_StatusChip(t.status)),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Selesai':
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        break;
      case 'Ditolak':
        bg = AppColors.error.withOpacity(0.15);
        fg = AppColors.error;
        break;
      default:
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
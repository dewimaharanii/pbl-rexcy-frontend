import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/mitra_api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await MitraApiService.getTransaksi();
    if (!mounted) return;
    setState(() {
      _allOrders = result['data'] ?? [];
      _isLoading = false;
    });
  }

  // Filter Data
  List<dynamic> get _permintaan => _allOrders.where((o) => ['menunggu', 'pending'].contains((o['status'] ?? '').toString().toLowerCase())).toList();
  List<dynamic> get _ditolak => _allOrders.where((o) => (o['status'] ?? '').toString().toLowerCase() == 'ditolak').toList();
  List<dynamic> get _selesai => _allOrders.where((o) => (o['status'] ?? '').toString().toLowerCase() == 'selesai').toList();

  String _formatRp(int val) => val.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const AppLogo(height: 30, white: true),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Permintaan'),
            Tab(text: 'Di Tolak'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_permintaan, Icons.send_outlined, 'Belum ada permintaan'),
                _buildList(_ditolak, Icons.cancel_outlined, 'Belum ada pesanan ditolak'),
                _buildList(_selesai, Icons.check_circle_outline, 'Belum ada pesanan selesai'),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> orders, IconData emptyIcon, String emptyText) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: AppColors.iconGrey.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(emptyText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final order = orders[i];
          final namaProduk = order['produk'] != null ? order['produk']['Nama_Produk'] : (order['nama_produk'] ?? 'Produk Laut');
          final tgl = order['tanggal_permintaan'] ?? order['Tanggal_Permintaan'] ?? '';
          
          int totalBiaya = 0;
          if (order['total_harga'] != null) totalBiaya = int.tryParse(order['total_harga'].toString()) ?? 0;
          else if (order['estimasi_total'] != null) totalBiaya = int.tryParse(order['estimasi_total'].toString()) ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pesanan #${order['id_permintaan'] ?? order['Id_Permintaan'] ?? '-'}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Icon(Icons.history, size: 16, color: AppColors.iconGrey),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.divider)),
                Row(
                  children: [
                    const Icon(Icons.set_meal, size: 16, color: AppColors.blue),
                    const SizedBox(width: 8),
                    Text('$namaProduk (${order['jumlah_permintaan'] ?? order['Jumlah_Diminta'] ?? 0} kg)', 
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, size: 16, color: AppColors.successGreen),
                    const SizedBox(width: 8),
                    Text('Rp ${_formatRp(totalBiaya)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.iconGrey),
                    const SizedBox(width: 8),
                    Text(tgl.toString().length >= 10 ? tgl.toString().substring(0, 10) : '-', 
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
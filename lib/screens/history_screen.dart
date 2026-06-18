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
    // Tabnya diubah menjadi 3 sesuai request
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

  // FILTER DATA BARU
  List<dynamic> get _permintaan => _allOrders.where((o) => ['menunggu', 'pending'].contains((o['status'] ?? '').toString().toLowerCase())).toList();
  List<dynamic> get _ditolak => _allOrders.where((o) => (o['status'] ?? '').toString().toLowerCase() == 'ditolak').toList();
  List<dynamic> get _diProses => _allOrders.where((o) => ['diproses', 'proses'].contains((o['status'] ?? '').toString().toLowerCase())).toList();

  Color _statusColor(String status) {
    switch (status) {
      case 'menunggu':
      case 'pending':
        return AppColors.statusWaiting;
      case 'diproses':
      case 'proses':
        return AppColors.statusProcess;
      case 'selesai':
        return AppColors.statusDone;
      case 'ditolak':
        return AppColors.statusRejected;
      default:
        return AppColors.iconGrey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'menunggu':
      case 'pending':
        return 'Menunggu';
      case 'diproses':
      case 'proses':
        return 'Di Proses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status.toUpperCase();
    }
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          // PERUBAHAN TAB
          tabs: const [
            Tab(text: 'Permintaan'),
            Tab(text: 'Di Tolak'),
            Tab(text: 'Di Proses'),
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
                _buildList(_diProses, Icons.sync_outlined, 'Belum ada pesanan diproses'),
              ],
            ),
    );
  }

  // Tampilan List Diperbarui agar seragam dengan fungsi konfirmasi
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
          final idTrans = order['id_permintaan'] ?? order['Id_Permintaan'] ?? '-';
          final rawStatus = (order['status'] ?? order['Status'] ?? 'menunggu').toString().toLowerCase();
          final namaProduk = order['produk'] != null ? order['produk']['Nama_Produk'] : (order['nama_produk'] ?? 'Produk Laut');
          final tgl = order['tanggal_permintaan'] ?? order['Tanggal_Permintaan'] ?? '';
          final jumlah = order['jumlah_permintaan'] ?? order['Jumlah_Diminta'] ?? 0;
          
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
                    Text('Pesanan #$idTrans', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(rawStatus).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_statusLabel(rawStatus),
                          style: TextStyle(
                              color: _statusColor(rawStatus),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.divider)),
                
                _infoRow(Icons.set_meal_outlined, '$namaProduk ($jumlah kg)'),
                const SizedBox(height: 6),
                _infoRow(Icons.payments_outlined, 'Total: Rp ${_formatRp(totalBiaya)}'),
                const SizedBox(height: 6),
                _infoRow(Icons.calendar_today_outlined, tgl.toString().length >= 10 ? tgl.toString().substring(0, 10) : '-'),

                // Tombol Konfirmasi Muncul Khusus Untuk Tab Di Proses
                if (rawStatus == 'diproses' || rawStatus == 'proses') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => _showConfirmDialog(idTrans.toString()),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Konfirmasi Pesanan Sampai',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.iconGrey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      );

  // Fungsi Konfirmasi
  void _showConfirmDialog(String idTransaksi) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle_outline, color: AppColors.successGreen),
          SizedBox(width: 8),
          Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text('Apakah pesanan sudah sampai dan sesuai?',
            style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.iconGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await MitraApiService.konfirmasiPesananSelesai(idTransaksi);
              if (result['success'] == true) {
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pesanan berhasil diselesaikan!'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Gagal mengonfirmasi pesanan'),
                      backgroundColor: AppColors.deleteRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
            child: const Text('Ya, Sudah Sampai'),
          ),
        ],
      ),
    );
  }
}
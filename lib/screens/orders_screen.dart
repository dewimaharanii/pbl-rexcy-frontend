import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/mitra_api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    
    final result = await MitraApiService.getTransaksi();
    
    if (!mounted) return;
    setState(() {
      _allOrders = result['data'] ?? [];
      _isLoading = false;
    });
  }

  List<dynamic> get _menunggu => _allOrders.where((o) {
        final s = (o['status'] ?? o['Status'] ?? '').toString().toLowerCase();
        return s == 'menunggu' || s == 'pending';
      }).toList();

  List<dynamic> get _diProses => _allOrders.where((o) {
        final s = (o['status'] ?? o['Status'] ?? '').toString().toLowerCase();
        return s == 'diproses' || s == 'proses';
      }).toList();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        automaticallyImplyLeading: false,
        title: const AppLogo(height: 40, white: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins'),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Menunggu'),
            Tab(text: 'Di Proses'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_allOrders),
                _buildList(_menunggu),
                _buildList(_diProses),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.iconGrey),
            SizedBox(height: 12),
            Text('Belum ada pesanan',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final order  = orders[i];
          
          // PERBAIKAN: Membaca kunci data (keys) yang dikirim Laravel
          final idTrans = order['id_permintaan'] ?? order['Id_Permintaan'] ?? '-';
          final rawStatus = (order['status'] ?? order['Status'] ?? 'menunggu').toString().toLowerCase();
          final tgl = order['tanggal_permintaan'] ?? order['Tanggal_Permintaan'] ?? '-';
          final jumlah = order['jumlah_permintaan'] ?? order['Jumlah_Diminta'] ?? 0;
          
          // Mengambil Total Harga
          int totalBiaya = 0;
          if (order['total_harga'] != null) {
            totalBiaya = int.tryParse(order['total_harga'].toString()) ?? 0;
          } else if (order['estimasi_total'] != null) {
            totalBiaya = int.tryParse(order['estimasi_total'].toString()) ?? 0;
          }

          // Mengambil Nama Produk
          final namaProduk = order['nama_produk'] ?? 
              (order['produk'] != null ? order['produk']['Nama_Produk'] : 'Produk Laut');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pesanan #$idTrans',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
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
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 10),

                _infoRow(Icons.set_meal_outlined, '$namaProduk'),
                const SizedBox(height: 6),
                _infoRow(Icons.scale_outlined, 'Jumlah: $jumlah kg'),
                const SizedBox(height: 6),
                _infoRow(Icons.payments_outlined, 'Total: Rp ${_formatRp(totalBiaya)}'),
                const SizedBox(height: 6),
                _infoRow(Icons.calendar_today_outlined,
                    tgl.toString().length >= 10 ? tgl.toString().substring(0, 10) : '-'),

                if (rawStatus == 'diproses') ...[
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
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      );

  String _formatRp(int val) => val.toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

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
              
              // Panggil API dengan ID transaksi yang benar
              final result = await MitraApiService.konfirmasiPesananSelesai(idTransaksi);
              
              if (result['success'] == true) {
                await _loadOrders();
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
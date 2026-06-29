import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/mitra_api_service.dart';
import 'payment_screen.dart';

// ════════════════════════════════════════════════════════════
//  HALAMAN PESANAN AKTIF
//  Hanya tampil: menunggu, diterima, menunggu verifikasi, menunggu validasi, dibayar, diproses
//  Selesai/Ditolak → otomatis masuk Riwayat
// ════════════════════════════════════════════════════════════
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _rawPembelian  = [];
  List<dynamic> _rawPermintaan = [];
  bool _isLoading = true;

  // 🚀 FIX: Tambahkan 'menunggu validasi' agar datanya tidak hilang dari layar
  static const _aktif = [
    'menunggu',
    'pending',
    'diterima',
    'menungguverifikasi',
    'menunggu validasi', 
    'dibayar',
    'dikonfirmasi',
    'diproses',
    'proses',
    'selesai',
  ];

  List<dynamic> get _pembelianAktif =>
      _rawPembelian.where((o) => _aktif.contains(_status(o))).toList();
  List<dynamic> get _permintaanAktif =>
      _rawPermintaan.where((o) => _aktif.contains(_status(o))).toList();

  String _status(dynamic o) =>
      (o['status'] ?? o['Status'] ?? '').toString().toLowerCase();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final r1 = await MitraApiService.getMitraPembelian();
    final r2 = await MitraApiService.getMitraPermintaan();
    if (!mounted) return;
    setState(() {
      _rawPembelian  = List<dynamic>.from(r1['data'] ?? []);
      _rawPermintaan = List<dynamic>.from(r2['data'] ?? []);
      _isLoading = false;
    });
  }

  // ── HELPERS ────────────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s) {
      case 'menunggu': case 'pending': return AppColors.statusWaiting;
      case 'diterima': return Colors.blueAccent;
      // 🚀 FIX: Beri warna untuk status Menunggu Validasi (Admin)
      case 'menungguverifikasi': 
      case 'menunggu validasi': return Colors.orangeAccent;
      case 'dibayar': 
      case 'dikonfirmasi': return Colors.teal;
      case 'diproses': case 'proses': return AppColors.statusProcess;
      default: return AppColors.iconGrey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'menunggu': case 'pending': return 'Menunggu';
      case 'diterima': return 'Diterima';
      // 🚀 FIX: Beri label rapi untuk UI
      case 'menungguverifikasi': 
      case 'menunggu validasi': return 'Menunggu Validasi Admin';
      case 'dibayar': 
      case 'dikonfirmasi': return 'Pembayaran Dikonfirmasi';
      case 'diproses': case 'proses': return 'Di Proses';
      default: return s.toUpperCase();
    }
  }

  String _rp(dynamic v) => (int.tryParse(v.toString()) ?? 0)
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

  // ── BUILD ──────────────────────────────────────────────────
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
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          tabs: [
            _tab('Pembelian',  Icons.shopping_bag_outlined, _pembelianAktif.length),
            _tab('Permintaan', Icons.send_outlined,          _permintaanAktif.length),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  data:       _pembelianAktif,
                  emptyIcon:  Icons.shopping_bag_outlined,
                  emptyText:  'Tidak ada pembelian aktif',
                  label:      'Pembelian',
                  labelColor: AppColors.blue,
                  labelIcon:  Icons.shopping_bag_outlined,
                  idKey:      'Id_Transaksi',
                  isPermintaan: false,
                ),
                _buildList(
                  data:       _permintaanAktif,
                  emptyIcon:  Icons.send_outlined,
                  emptyText:  'Tidak ada permintaan aktif',
                  label:      'Permintaan',
                  labelColor: const Color(0xFF7C5CBF),
                  labelIcon:  Icons.send_outlined,
                  idKey:      'id_permintaan',
                  isPermintaan: true,
                ),
              ],
            ),
    );
  }

  Tab _tab(String text, IconData icon, int count) => Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 5),
            Text(text),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      );

  // ── LIST ───────────────────────────────────────────────────
  Widget _buildList({
    required List<dynamic> data,
    required IconData emptyIcon,
    required String emptyText,
    required String label,
    required Color labelColor,
    required IconData labelIcon,
    required String idKey,
    required bool isPermintaan,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: AppColors.iconGrey.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(emptyText,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),

          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (_, i) => _buildCard(
          order:      data[i],
          label:      label,
          labelColor: labelColor,
          labelIcon:  labelIcon,
          idKey:      idKey,
          isPermintaan: isPermintaan,
        ),
      ),
    );
  }

  Widget _buildCard({
    required dynamic order,
    required String label,
    required Color labelColor,
    required IconData labelIcon,
    required String idKey,
    required bool isPermintaan,
  }) {
    final id        = (order[idKey] ?? order['id_permintaan'] ?? order['Id_Transaksi'] ?? '-').toString();
    final rawStatus = _status(order);
    final produk    = (order['nama_produk'] ?? (order['produk'] != null ? order['produk']['Nama_Produk'] : null) ?? 'Produk Laut').toString();
    final tgl       = (order['tanggal_permintaan'] ?? order['Tanggal_Transaksi'] ?? order['Tanggal_Permintaan'] ?? '').toString();
    final jumlah    = order['jumlah_permintaan'] ?? order['Jumlah'] ?? order['Jumlah_Diminta'] ?? 0;
    final total     = order['total_harga'] ?? order['estimasi_total'] ?? order['Total_Harga'] ?? 0;

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
              Row(children: [
                Icon(labelIcon, size: 14, color: labelColor),
                const SizedBox(width: 6),
                Text('$label #$id',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: labelColor)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(rawStatus).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(rawStatus),
                    style: TextStyle(
                        color: _statusColor(rawStatus), fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _row(Icons.set_meal_outlined,      '$produk ($jumlah kg)'),
          const SizedBox(height: 6),
          _row(Icons.payments_outlined,      'Total: Rp ${_rp(total)}'),
          const SizedBox(height: 6),
          _row(Icons.calendar_today_outlined, tgl.length >= 10 ? tgl.substring(0, 10) : (tgl.isEmpty ? '-' : tgl)),

          // Tombol "Bayar Sekarang" hanya muncul untuk Permintaan yang sudah Diterima produsen
          if (isPermintaan && rawStatus == 'diterima') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => _goToPayment(order, id),
                icon: const Icon(Icons.payment, size: 16),
                label: const Text('Bayar Sekarang',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],

          // Tombol konfirmasi hanya muncul jika status diproses
          if (rawStatus == 'diproses' || rawStatus == 'proses') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => _confirmDialog(id),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Konfirmasi Pesanan Sampai',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.iconGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
        ],
      );

  void _goToPayment(dynamic order, String id) async {
    final produk = (order['nama_produk'] ??
            (order['produk'] != null ? order['produk']['Nama_Produk'] : null) ??
            'Produk Laut')
        .toString();
    final total = order['total_harga'] ?? order['estimasi_total'] ?? order['Total_Harga'] ?? 0;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          permintaanId: id,
          permintaanTotal: (int.tryParse(total.toString()) ?? 0),
          permintaanProdukNama: produk,
        ),
      ),
    );

    // Setelah balik dari PaymentScreen (atau kalau dipanggil ulang via HomeScreen),
    // refresh daftar supaya status terbaru muncul.
    if (mounted) await _load();
  }

  void _confirmDialog(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle_outline, color: AppColors.successGreen),
          SizedBox(width: 8),
          Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text('Apakah pesanan sudah sampai dan sesuai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.iconGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final res = await MitraApiService.konfirmasiPesananSelesai(id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(res['success'] == true
                    ? 'Pesanan berhasil diselesaikan!'
                    : (res['message'] ?? 'Gagal')),
                backgroundColor:
                    res['success'] == true ? AppColors.successGreen : AppColors.deleteRed,
              ));
              if (res['success'] == true) await _load();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
            child: const Text('Ya, Sudah Sampai'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/mitra_api_service.dart';

// ════════════════════════════════════════════════════════════
//  HALAMAN RIWAYAT SAYA
//  Hanya tampil: selesai & ditolak
// ════════════════════════════════════════════════════════════
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _rawPembelian  = [];
  List<dynamic> _rawPermintaan = [];
  bool _isLoading = true;

  static const _final = ['selesai', 'ditolak'];

  List<dynamic> get _pembelianFinal =>
      _rawPembelian.where((o) => _final.contains(_status(o))).toList();
  List<dynamic> get _permintaanFinal =>
      _rawPermintaan.where((o) => _final.contains(_status(o))).toList();

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
      case 'selesai': return AppColors.statusDone;
      case 'ditolak': return AppColors.statusRejected;
      default:        return AppColors.iconGrey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'selesai': return 'Selesai';
      case 'ditolak': return 'Ditolak';
      default:        return s.toUpperCase();
    }
  }

  String _rp(dynamic v) => (int.tryParse(v.toString()) ?? 0)
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Saya',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
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
            _tab('Pembelian',  Icons.shopping_bag_outlined, _pembelianFinal.length),
            _tab('Permintaan', Icons.send_outlined,          _permintaanFinal.length),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  data:       _pembelianFinal,
                  emptyIcon:  Icons.shopping_bag_outlined,
                  emptyText:  'Belum ada riwayat pembelian',
                  label:      'Pembelian',
                  labelColor: AppColors.blue,
                  labelIcon:  Icons.shopping_bag_outlined,
                  idKey:      'Id_Transaksi',
                ),
                _buildList(
                  data:       _permintaanFinal,
                  emptyIcon:  Icons.send_outlined,
                  emptyText:  'Belum ada riwayat permintaan',
                  label:      'Permintaan',
                  labelColor: const Color(0xFF7C5CBF),
                  labelIcon:  Icons.send_outlined,
                  idKey:      'id_permintaan',
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
            const SizedBox(height: 8),
            Text('Pesanan aktif ada di tab Pesanan',
                style: TextStyle(color: AppColors.iconGrey.withOpacity(0.6), fontSize: 12)),
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
        // Card agak redup untuk kesan "sudah selesai"
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(labelIcon, size: 14, color: labelColor.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text('$label #$id',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: labelColor.withOpacity(0.8))),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(rawStatus).withOpacity(0.1),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _row(Icons.set_meal_outlined,      '$produk ($jumlah kg)'),
          const SizedBox(height: 6),
          _row(Icons.payments_outlined,      'Total: Rp ${_rp(total)}'),
          const SizedBox(height: 6),
          _row(Icons.calendar_today_outlined, tgl.length >= 10 ? tgl.substring(0, 10) : (tgl.isEmpty ? '-' : tgl)),

          // Tombol Detail Pesanan
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDetailPesanan(order),
              icon: const Icon(Icons.info_outline, size: 13),
              label: const Text('Detail Pesanan', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: AppColors.blue),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),

          // Info tambahan jika ditolak
          if (rawStatus == 'ditolak') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.statusRejected.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 13, color: AppColors.statusRejected.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text('Pesanan ini ditolak oleh produsen',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.statusRejected.withOpacity(0.8))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDetailPesanan(dynamic order) {
    final namaPemesan = (order['nama_pemesan'] ?? '').toString();
    final noTelp = (order['no_telp'] ?? '').toString();
    final alamat = (order['alamat_pemesan'] ?? '').toString();
    final mitraNama = (order['nama_mitra'] ?? '-').toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.blue),
            SizedBox(width: 8),
            Text('Detail Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowDialog(Icons.person, 'Nama Pemesan', namaPemesan.isNotEmpty ? namaPemesan : mitraNama),
            const SizedBox(height: 12),
            _rowDialog(Icons.phone, 'No. Telepon', noTelp.isNotEmpty ? noTelp : '-'),
            const SizedBox(height: 12),
            _rowDialog(Icons.location_on, 'Alamat', alamat.isNotEmpty ? alamat : '-'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AppColors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _rowDialog(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.iconGrey),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.iconGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      );
}
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/mitra_api_service.dart';

// ════════════════════════════════════════════════════════════
//  RIWAYAT TRANSAKSI PRODUSEN
//  Tab: Pembelian (TRX selesai/ditolak) | Permintaan (PMT selesai/ditolak)
// ════════════════════════════════════════════════════════════
class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});
  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _rawPembelian  = [];
  List<dynamic> _rawPermintaan = [];
  bool _isLoading = true;

  // Filter hanya yang sudah final
  static const _final = ['selesai', 'ditolak'];

  List<dynamic> get _pembelian =>
      _rawPembelian.where((o) => _final.contains(_status(o))).toList();
  List<dynamic> get _permintaan =>
      _rawPermintaan.where((o) => _final.contains(_status(o))).toList();

  String _status(dynamic o) =>
      (o['status'] ?? o['Status'] ?? '').toString().toLowerCase();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final result = await MitraApiService.getProdusenRiwayatAll();
      if (!mounted) return;

      final allData = List<dynamic>.from(result['data'] ?? []);

      setState(() {
        // Pisah berdasarkan jenis_pesanan dari response backend
        _rawPembelian  = allData.where((o) => o['jenis_pesanan'] == 'pembelian').toList();
        _rawPermintaan = allData.where((o) => o['jenis_pesanan'] == 'permintaan').toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: AppColors.deleteRed),
      );
    }
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

  String _tgl(dynamic v) {
    final s = v?.toString() ?? '';
    return s.length >= 10 ? s.substring(0, 10) : (s.isEmpty ? '-' : s);
  }

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Transaksi',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
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
            _tab('Pembelian',  Icons.shopping_bag_outlined, _pembelian.length),
            _tab('Permintaan', Icons.send_outlined,          _permintaan.length),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  data:       _pembelian,
                  emptyText:  'Belum ada riwayat pembelian',
                  emptyIcon:  Icons.shopping_bag_outlined,
                  label:      'Pembelian',
                  labelColor: AppColors.blue,
                  labelIcon:  Icons.shopping_bag_outlined,
                  idKey:      'id_permintaan',
                ),
                _buildList(
                  data:       _permintaan,
                  emptyText:  'Belum ada riwayat permintaan',
                  emptyIcon:  Icons.send_outlined,
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
    required String emptyText,
    required IconData emptyIcon,
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
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
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
    final id        = (order[idKey] ?? '-').toString();
    final rawStatus = _status(order);
    final mitra     = (order['nama_mitra']   ?? 'Mitra').toString();
    final produk    = (order['nama_produk']  ?? '-').toString();
    final jumlah    = order['jumlah_permintaan'] ?? order['Jumlah'] ?? 0;
    final total     = order['total_harga'] ?? order['estimasi_total'] ?? 0;
    final tgl       = _tgl(order['tanggal_permintaan']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: label + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(labelIcon, size: 14, color: labelColor.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text('$label #$id',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: labelColor.withOpacity(0.9))),
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
          // Info rows
          _row(Icons.person_outline,         mitra),
          const SizedBox(height: 6),
          _row(Icons.set_meal_outlined,      '$produk ($jumlah kg)'),
          const SizedBox(height: 6),
          _row(Icons.payments_outlined,      'Rp ${_rp(total)}'),
          const SizedBox(height: 6),
          _row(Icons.calendar_today_outlined, tgl),

          // Banner ditolak
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
                  Text('Pesanan ini ditolak',
                      style: TextStyle(fontSize: 11, color: AppColors.statusRejected.withOpacity(0.8))),
                ],
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
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      );
}
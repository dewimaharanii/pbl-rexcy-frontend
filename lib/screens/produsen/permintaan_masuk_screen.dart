import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/mitra_api_service.dart';

class PermintaanMasukScreen extends StatefulWidget {
  const PermintaanMasukScreen({super.key});
  @override
  State<PermintaanMasukScreen> createState() => _PermintaanMasukScreenState();
}

class _PermintaanMasukScreenState extends State<PermintaanMasukScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _dataPembelian  = [];
  List<dynamic> _dataPermintaan = [];
  bool _isLoading = true;

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
    final resPermintaan = await MitraApiService.getProdusenPermintaan();
    final resTransaksi  = await MitraApiService.getProdusenTransaksi();
    if (!mounted) return;
    setState(() {
      _dataPermintaan = List<dynamic>.from(resPermintaan['data'] ?? []);
      _dataPembelian  = List<dynamic>.from(resTransaksi['data']  ?? []);
      _isLoading      = false;
    });
  }

  // ── AKSI API ───────────────────────────────────────────────────
  Future<void> _terima(String id) async {
    final res = await MitraApiService.terimaPermintaan(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['success'] == true ? 'Permintaan Diterima!' : (res['message'] ?? 'Gagal')),
      backgroundColor: res['success'] == true ? AppColors.blue : AppColors.deleteRed,
    ));
    if (res['success'] == true) _loadData();
  }

  Future<void> _proses(String id, bool isPembelian) async {
    final res = isPembelian ? await MitraApiService.prosesTransaksiProdusen(id) : await MitraApiService.prosesPermintaan(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['success'] == true ? 'Pesanan berhasil diproses!' : (res['message'] ?? 'Gagal')),
      backgroundColor: res['success'] == true ? AppColors.successGreen : AppColors.deleteRed,
    ));
    if (res['success'] == true) _loadData();
  }

  Future<void> _tolak(String id, bool isPembelian) async {
    final res = isPembelian ? await MitraApiService.tolakTransaksiProdusen(id) : await MitraApiService.tolakPermintaan(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['success'] == true ? 'Pesanan ditolak' : (res['message'] ?? 'Gagal')),
      backgroundColor: res['success'] == true ? AppColors.deleteRed : AppColors.iconGrey,
    ));
    if (res['success'] == true) _loadData();
  }

  // ── DIALOG KONFIRMASI ──────────────────────────────────────
  void _showConfirmDialog({required String title, required String content, required Color color, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────
  String _status(dynamic o) => (o['status'] ?? o['Status'] ?? '').toString().toLowerCase();
  
  Color _statusColor(String s) {
    switch (s) {
      case 'diterima': return AppColors.blue;
      case 'dibayar': case 'lunas': case 'dikonfirmasi': return AppColors.successGreen;
      case 'menunggu': case 'pending': return AppColors.statusWaiting;
      case 'menunggu validasi': case 'menungguverifikasi': return Colors.orangeAccent;
      case 'diproses': case 'proses':  return AppColors.statusProcess;
      case 'ditolak': return AppColors.statusRejected;
      case 'selesai': return AppColors.statusDone;
      default: return AppColors.iconGrey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'diterima': return 'Diterima';
      case 'dibayar': case 'lunas': case 'dikonfirmasi': return 'Telah Dibayar';
      case 'menunggu': case 'pending': return 'Menunggu';
      case 'menunggu validasi': case 'menungguverifikasi': return 'Menunggu Validasi Admin';
      case 'diproses': case 'proses':  return 'Di Proses';
      case 'ditolak': return 'Ditolak';
      case 'selesai': return 'Selesai';
      default: return s.toUpperCase();
    }
  }

  String _rp(dynamic v) => (int.tryParse(v.toString()) ?? 0).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  String _tgl(dynamic v) { final s = v?.toString() ?? ''; return s.length >= 10 ? s.substring(0, 10) : (s.isEmpty ? '-' : s); }

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

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Pesanan Masuk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData)],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          tabs: [
            _tab('Pembelian', Icons.shopping_bag_outlined, _dataPembelian.length),
            _tab('Permintaan', Icons.send_outlined, _dataPermintaan.length),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(data: _dataPembelian, isPembelian: true, emptyIcon: Icons.shopping_bag_outlined, emptyText: 'Belum ada pembelian masuk', label: 'Pembelian', labelColor: AppColors.blue, labelIcon: Icons.shopping_bag_outlined),
                _buildList(data: _dataPermintaan, isPembelian: false, emptyIcon: Icons.send_outlined, emptyText: 'Belum ada permintaan masuk', label: 'Permintaan', labelColor: const Color(0xFF7C5CBF), labelIcon: Icons.send_outlined),
              ],
            ),
    );
  }

  Tab _tab(String text, IconData icon, int count) => Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15), const SizedBox(width: 5), Text(text),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      );

  Widget _buildList({required List<dynamic> data, required bool isPembelian, required IconData emptyIcon, required String emptyText, required String label, required Color labelColor, required IconData labelIcon}) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: AppColors.iconGrey.withOpacity(0.4)), const SizedBox(height: 16),
            Text(emptyText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (_, i) => _buildCard(order: data[i], isPembelian: isPembelian, label: label, labelColor: labelColor, labelIcon: labelIcon),
      ),
    );
  }

  Widget _buildCard({required dynamic order, required bool isPembelian, required String label, required Color labelColor, required IconData labelIcon}) {
    // Ambil ID secara dinamis untuk PMT atau TRX
    final idStr     = (order['id_permintaan'] ?? order['Id_Transaksi'] ?? '-').toString();
    final rawStatus = _status(order);
    
    final isPending = rawStatus == 'menunggu' || rawStatus == 'pending';
    final isMenungguValidasi = rawStatus == 'menunggu validasi' || rawStatus == 'menungguverifikasi';
    final isDibayar = rawStatus == 'dibayar' || rawStatus == 'lunas' || rawStatus == 'dikonfirmasi';
    
    final mitra     = (order['nama_mitra']  ?? 'Mitra Hilir').toString();
    final produk    = (order['nama_produk'] ?? order['produk']?['Nama_Produk'] ?? '-').toString();
    final jumlah    = order['jumlah_permintaan'] ?? order['Jumlah'] ?? 0;
    final total     = order['estimasi_total'] ?? order['total_harga'] ?? order['Total_Harga'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(labelIcon, size: 14, color: labelColor), const SizedBox(width: 6), Text('$label #$idStr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: labelColor))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _statusColor(rawStatus).withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text(_statusLabel(rawStatus), style: TextStyle(color: _statusColor(rawStatus), fontSize: 11, fontWeight: FontWeight.w600))),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.divider)),
          _row(Icons.person_outline, mitra), const SizedBox(height: 6),
          _row(Icons.set_meal_outlined, '$produk ($jumlah kg)'), const SizedBox(height: 6),
          _row(Icons.payments_outlined, 'Rp ${_rp(total)}'), const SizedBox(height: 6),
          _row(Icons.calendar_today_outlined, _tgl(order['tanggal_permintaan'] ?? order['Tanggal_Transaksi'])),

          // Tombol Detail Pesanan
          const SizedBox(height: 6),
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

          // ── LOGIKA TOMBOL BERDASARKAN STATUS DAN JENIS ──
          if (isPembelian) ...[
            // 🛒 ALUR PEMBELIAN (Tolak Dihapus, Proses Saja dengan status enable/disable)
            if (isPending || isMenungguValidasi || isDibayar) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: _btnProses(order, isPembelian, mitra, jumlah, enabled: isDibayar),
              ),
            ],
          ] else ...[
            // 📝 ALUR PERMINTAAN (Terima, Tolak, Proses)
            if (isPending) ...[
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _btnTolak(order, isPembelian, mitra)), const SizedBox(width: 10),
                Expanded(child: _btnTerima(idStr, mitra, jumlah)),
              ]),
            ] else if (rawStatus == 'diterima') ...[
              const SizedBox(height: 10),
              _infoBox(Icons.access_time, 'Menunggu mitra mengunggah bukti pembayaran', AppColors.statusWaiting),
            ] else if (isMenungguValidasi || isDibayar) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity, 
                child: _btnProses(order, isPembelian, mitra, jumlah, enabled: isDibayar),
              ),
            ],
          ],

          // ── Info sedang diproses (Berlaku untuk keduanya) ──
          if (rawStatus == 'diproses' || rawStatus == 'proses') ...[
            const SizedBox(height: 10),
            _infoBox(Icons.local_shipping_outlined, 'Sedang diproses, menunggu konfirmasi mitra', AppColors.statusProcess),
          ],
        ],
      ),
    );
  }

  // ── WIDGET KECIL PEMBANTU ──
  Widget _row(IconData icon, String text) => Row(children: [Icon(icon, size: 14, color: AppColors.iconGrey), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)))]);
  
  Widget _infoBox(IconData icon, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [Icon(icon, size: 14, color: color.withOpacity(0.8)), const SizedBox(width: 8), Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color.withOpacity(0.9), fontWeight: FontWeight.w500)))]),
      );

  Widget _btnTolak(dynamic order, bool isPembelian, String mitra) => OutlinedButton.icon(
        onPressed: () => _showConfirmDialog(
            title: 'Tolak Pesanan?', 
            content: 'Pesanan dari $mitra akan ditolak. Tindakan ini tidak bisa dibatalkan.', 
            color: AppColors.deleteRed, 
            onConfirm: () => _tolak(order['id_permintaan']?.toString() ?? '', isPembelian)),
        icon: const Icon(Icons.close, size: 14, color: AppColors.deleteRed),
        label: const Text('Tolak', style: TextStyle(fontSize: 12, color: AppColors.deleteRed, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.deleteRed), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      );

  Widget _btnTerima(String id, String mitra, dynamic jumlah) => ElevatedButton.icon(
        onPressed: () => _showConfirmDialog(
            title: 'Terima Permintaan?', 
            content: 'Terima permintaan $jumlah kg dari $mitra dan lanjutkan ke tahap pembayaran?', 
            color: AppColors.blue, 
            onConfirm: () => _terima(id)),
        icon: const Icon(Icons.check, size: 14),
        label: const Text('Terima', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      );

  // 🚀 FUNGSI TOMBOL PROSES (Dilengkapi dengan parameter enable/disable)
  Widget _btnProses(dynamic order, bool isPembelian, String mitra, dynamic jumlah, {required bool enabled}) => ElevatedButton.icon(
        onPressed: enabled 
            ? () => _showConfirmDialog(
                title: isPembelian ? 'Proses Pembelian?' : 'Proses Permintaan?', 
                content: 'Pesanan dari $mitra sebanyak $jumlah kg akan mulai diproses.', 
                color: AppColors.successGreen, 
                onConfirm: () => _proses(order['id_permintaan']?.toString() ?? order['Id_Transaksi']?.toString() ?? '', isPembelian))
            : null, // Jika null, tombol jadi abu-abu dan tidak bisa diklik
        icon: const Icon(Icons.inventory, size: 14),
        label: Text(enabled ? 'Proses Sekarang' : 'Menunggu Validasi Admin', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.successGreen : Colors.grey.shade300,
          disabledBackgroundColor: Colors.grey.shade300, // Warna abu-abu saat didisable
          foregroundColor: enabled ? Colors.white : Colors.grey.shade600, // Warna teks
          padding: const EdgeInsets.symmetric(vertical: 10), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
        ),
      );
}
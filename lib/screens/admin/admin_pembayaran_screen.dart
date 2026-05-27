import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaksi_provider.dart';
import 'package:rempang_eco_city/theme/app_theme.dart';
import 'package:rempang_eco_city/widgets/shared_widget.dart';

class AdminPembayaranScreen extends StatefulWidget {
  const AdminPembayaranScreen({super.key});

  @override
  State<AdminPembayaranScreen> createState() => _AdminPembayaranScreenState();
}

class _AdminPembayaranScreenState extends State<AdminPembayaranScreen> {
  String _filterStatus = 'Semua';

  final List<String> _filterOptions = [
    'Semua',
    'Menunggu Konfirmasi',
    'Dikonfirmasi',
    'Ditolak',
  ];

  // Data dummy — nanti diganti dengan data dari provider/API
  final List<Map<String, dynamic>> _dataPembayaran = [
    {
      'id_pembayaran':     'PAY001',
      'id_transaksi':      'TRX001',
      'mitra':             'CV Mitra Bahari',
      'produsen':          'KUB Nelayan Rempang',
      'produk':            'Ikan Kerapu',
      'jumlah_produk':     80,
      'jumlah_bayar':      3000000,
      'tanggal_bayar':     '15 Apr 2026',
      'bank_tujuan':       'BRI',
      'no_rekening':       '1234-5678-9012-3456',
      'atas_nama':         'KUB Nelayan Rempang',
      'status_pembayaran': 'Menunggu Konfirmasi',
      'bukti_transfer':    'https://placehold.co/600x400/e8f5ee/1d6a3e?text=Bukti+Transfer',
    },
    {
      'id_pembayaran':     'PAY002',
      'id_transaksi':      'TRX002',
      'mitra':             'PT Seafood Nusantara',
      'produsen':          'KUB Bahari Galang',
      'produk':            'Udang Vaname',
      'jumlah_produk':     50,
      'jumlah_bayar':      4250000,
      'tanggal_bayar':     '14 Apr 2026',
      'bank_tujuan':       'BCA',
      'no_rekening':       '9876-5432-1098-7654',
      'atas_nama':         'KUB Bahari Galang',
      'status_pembayaran': 'Menunggu Konfirmasi',
      'bukti_transfer':    null,
    },
    {
      'id_pembayaran':     'PAY003',
      'id_transaksi':      'TRX003',
      'mitra':             'UD Bahari Jaya',
      'produsen':          'UD Hasil Laut',
      'produk':            'Kakap Merah',
      'jumlah_produk':     30,
      'jumlah_bayar':      1350000,
      'tanggal_bayar':     '12 Apr 2026',
      'bank_tujuan':       'Mandiri',
      'no_rekening':       '5555-6666-7777-8888',
      'atas_nama':         'UD Hasil Laut',
      'status_pembayaran': 'Dikonfirmasi',
      'bukti_transfer':    'https://placehold.co/600x400/e8f5ee/1d6a3e?text=Bukti+Transfer',
    },
    {
      'id_pembayaran':     'PAY004',
      'id_transaksi':      'TRX004',
      'mitra':             'Toko Rempah Nusantara',
      'produsen':          'KUB Nelayan Rempang',
      'produk':            'Cumi-cumi',
      'jumlah_produk':     20,
      'jumlah_bayar':      800000,
      'tanggal_bayar':     '10 Apr 2026',
      'bank_tujuan':       'BNI',
      'no_rekening':       '1111-2222-3333-4444',
      'atas_nama':         'KUB Nelayan Rempang',
      'status_pembayaran': 'Ditolak',
      'bukti_transfer':    'https://placehold.co/600x400/e8f5ee/1d6a3e?text=Bukti+Transfer',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filterStatus == 'Semua') return _dataPembayaran;
    return _dataPembayaran
        .where((d) => d['status_pembayaran'] == _filterStatus)
        .toList();
  }

  String _formatRupiah(int n) => 'Rp ${n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';

  Color _statusColor(String status) {
    switch (status) {
      case 'Dikonfirmasi':       return AppColors.badgeGreenText;
      case 'Ditolak':            return AppColors.badgeRedText;
      case 'Menunggu Konfirmasi': return AppColors.badgeAmberText;
      default:                   return AppColors.textSecondary;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Dikonfirmasi':       return AppColors.badgeGreenBg;
      case 'Ditolak':            return AppColors.badgeRedBg;
      case 'Menunggu Konfirmasi': return AppColors.badgeAmberBg;
      default:                   return AppColors.chipDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: buildAppBar('Verifikasi Pembayaran'),
      body: Column(
        children: [
          // ── Stat ringkasan ──────────────────────────────
          Container(
            color: AppColors.bgWhite,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(
                  label: 'Menunggu',
                  value: _dataPembayaran
                      .where((d) =>
                          d['status_pembayaran'] == 'Menunggu Konfirmasi')
                      .length
                      .toString(),
                  color: AppColors.badgeAmberText,
                  bgColor: AppColors.badgeAmberBg,
                  icon: Icons.hourglass_empty_rounded,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Dikonfirmasi',
                  value: _dataPembayaran
                      .where(
                          (d) => d['status_pembayaran'] == 'Dikonfirmasi')
                      .length
                      .toString(),
                  color: AppColors.badgeGreenText,
                  bgColor: AppColors.badgeGreenBg,
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Ditolak',
                  value: _dataPembayaran
                      .where((d) => d['status_pembayaran'] == 'Ditolak')
                      .length
                      .toString(),
                  color: AppColors.badgeRedText,
                  bgColor: AppColors.badgeRedBg,
                  icon: Icons.cancel_outlined,
                ),
              ],
            ),
          ),
          const AppDivider(),

          // ── Filter status ───────────────────────────────
          Container(
            color: AppColors.bgWhite,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((s) {
                  final isActive = _filterStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterStatus = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.chipDefault,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : AppColors.chipDefaultText,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const AppDivider(),

          // ── List pembayaran ─────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 48, color: AppColors.borderCard),
                        SizedBox(height: 12),
                        Text('Tidak ada data pembayaran.',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final d = _filtered[i];
                      return _PembayaranCard(
                        data: d,
                        formatRupiah: _formatRupiah,
                        statusColor: _statusColor,
                        statusBgColor: _statusBgColor,
                        onTap: () => _bukaDetail(context, d),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _bukaDetail(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PembayaranDetailSheet(
        data: data,
        formatRupiah: _formatRupiah,
        onKonfirmasi: () {
          setState(() {
            final idx = _dataPembayaran.indexWhere(
                (x) => x['id_pembayaran'] == data['id_pembayaran']);
            if (idx != -1) {
              _dataPembayaran[idx]['status_pembayaran'] = 'Dikonfirmasi';
            }
          });
        },
        onTolak: () {
          setState(() {
            final idx = _dataPembayaran.indexWhere(
                (x) => x['id_pembayaran'] == data['id_pembayaran']);
            if (idx != -1) {
              _dataPembayaran[idx]['status_pembayaran'] = 'Ditolak';
            }
          });
        },
      ),
    );
  }
}

// ── Card item list ─────────────────────────────────────────────

class _PembayaranCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String Function(int) formatRupiah;
  final Color Function(String) statusColor;
  final Color Function(String) statusBgColor;
  final VoidCallback onTap;

  const _PembayaranCard({
    required this.data,
    required this.formatRupiah,
    required this.statusColor,
    required this.statusBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status       = data['status_pembayaran'] as String;
    final sudahUpload  = data['bukti_transfer'] != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['mitra'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data['id_pembayaran'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge status
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const AppDivider(),

            // Info produk & harga
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Produk',
                      value: data['produk'],
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Jumlah',
                      value: '${data['jumlah_produk']} kg',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Total Harga',
                      value: formatRupiah(data['jumlah_bayar']),
                      valueColor: AppColors.primary,
                      isBold: true,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Tanggal',
                      value: data['tanggal_bayar'],
                    ),
                  ),
                ],
              ),
            ),

            // Info transfer bank
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.borderCard, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${data['bank_tujuan']} — ${data['no_rekening']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Indikator bukti transfer
                  Row(
                    children: [
                      Icon(
                        sudahUpload
                            ? Icons.image_outlined
                            : Icons.image_not_supported_outlined,
                        size: 14,
                        color: sudahUpload
                            ? AppColors.badgeGreenText
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sudahUpload ? 'Bukti tersedia' : 'Belum ada bukti',
                        style: TextStyle(
                          fontSize: 11,
                          color: sudahUpload
                              ? AppColors.badgeGreenText
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tombol lihat detail
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: AppColors.borderCard, width: 0.5)),
              ),
              child: TextButton(
                onPressed: onTap,
                child: const Text(
                  'Lihat Bukti & Proses Pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet detail ────────────────────────────────────────

class _PembayaranDetailSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  final String Function(int) formatRupiah;
  final VoidCallback onKonfirmasi;
  final VoidCallback onTolak;

  const _PembayaranDetailSheet({
    required this.data,
    required this.formatRupiah,
    required this.onKonfirmasi,
    required this.onTolak,
  });

  @override
  State<_PembayaranDetailSheet> createState() =>
      _PembayaranDetailSheetState();
}

class _PembayaranDetailSheetState extends State<_PembayaranDetailSheet> {
  bool _isProcessing = false;

  bool get _bisaKonfirmasi =>
      widget.data['status_pembayaran'] == 'Menunggu Konfirmasi' &&
      widget.data['bukti_transfer'] != null;

  bool get _sudahDiproses =>
      widget.data['status_pembayaran'] == 'Dikonfirmasi' ||
      widget.data['status_pembayaran'] == 'Ditolak';

  void _konfirmasi() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    widget.onKonfirmasi();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran berhasil dikonfirmasi.'),
        backgroundColor: AppColors.badgeGreenText,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _tolak() async {
    // Tampilkan konfirmasi dulu
    final yakin = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: const Text('Tolak Pembayaran',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
            'Yakin ingin menolak pembayaran ini? Mitra hilir akan diminta mengupload ulang bukti transfer.',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.badgeRedText,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Tolak'),
          ),
        ],
      ),
    );

    if (yakin != true) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    widget.onTolak();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran ditolak.'),
        backgroundColor: AppColors.badgeRedText,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _perbesar(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data         = widget.data;
    final sudahUpload  = data['bukti_transfer'] != null;
    final status       = data['status_pembayaran'] as String;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderCard,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),

            // Header sheet
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Detail Pembayaran · ${data['id_pembayaran']}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const AppDivider(),

            // Isi konten
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Info transaksi ─────────────────────
                  _SheetSection(
                    title: 'Informasi Transaksi',
                    child: Column(
                      children: [
                        _SheetRow('Mitra Hilir',  data['mitra']),
                        _SheetRow('Produsen',     data['produsen']),
                        _SheetRow('Produk',       data['produk']),
                        _SheetRow('Jumlah',       '${data['jumlah_produk']} kg'),
                        _SheetRow('Tanggal Bayar',data['tanggal_bayar']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Info transfer ──────────────────────
                  _SheetSection(
                    title: 'Detail Transfer Bank',
                    child: Column(
                      children: [
                        _SheetRow('Bank Tujuan',  data['bank_tujuan']),
                        _SheetRow('No. Rekening', data['no_rekening'],
                            isMono: true),
                        _SheetRow('Atas Nama',    data['atas_nama']),
                        _SheetRow(
                          'Jumlah Transfer',
                          widget.formatRupiah(data['jumlah_bayar']),
                          isBold: true,
                          valueColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Status ─────────────────────────────
                  _SheetSection(
                    title: 'Status Pembayaran',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: status == 'Dikonfirmasi'
                            ? AppColors.badgeGreenBg
                            : status == 'Ditolak'
                                ? AppColors.badgeRedBg
                                : AppColors.badgeAmberBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status == 'Dikonfirmasi'
                                ? Icons.check_circle_outline
                                : status == 'Ditolak'
                                    ? Icons.cancel_outlined
                                    : Icons.hourglass_empty_rounded,
                            size: 16,
                            color: status == 'Dikonfirmasi'
                                ? AppColors.badgeGreenText
                                : status == 'Ditolak'
                                    ? AppColors.badgeRedText
                                    : AppColors.badgeAmberText,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: status == 'Dikonfirmasi'
                                  ? AppColors.badgeGreenText
                                  : status == 'Ditolak'
                                      ? AppColors.badgeRedText
                                      : AppColors.badgeAmberText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Bukti transfer ─────────────────────
                  _SheetSection(
                    title: 'Bukti Transfer',
                    child: sudahUpload
                        ? Column(
                            children: [
                              // Preview gambar
                              GestureDetector(
                                onTap: () =>
                                    _perbesar(data['bukti_transfer']),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Image.network(
                                        data['bukti_transfer'],
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (_, child, progress) {
                                          if (progress == null)
                                            return child;
                                          return Container(
                                            height: 200,
                                            color: AppColors.bgPage,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: AppColors.bgPage,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .broken_image_outlined,
                                                  size: 36,
                                                  color: AppColors
                                                      .textSecondary,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Gambar tidak bisa dimuat.',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Overlay perbesar
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.zoom_in,
                                                color: Colors.white,
                                                size: 14),
                                            SizedBox(width: 4),
                                            Text(
                                              'Tap untuk perbesar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 32),
                            decoration: BoxDecoration(
                              color: AppColors.bgPage,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.borderCard,
                                  width: 0.5),
                            ),
                            child: const Column(children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: AppColors.borderCard,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Mitra hilir belum mengupload\nbukti transfer.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ]),
                          ),
                  ),

                  // Warning kalau belum upload
                  if (!sudahUpload &&
                      status == 'Menunggu Konfirmasi') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.badgeAmberBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_outlined,
                              color: AppColors.badgeAmberText, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pembayaran belum bisa dikonfirmasi karena mitra hilir belum mengupload bukti transfer.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.badgeAmberText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // ── Tombol aksi ─────────────────────────────
            if (!_sudahDiproses)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: const BoxDecoration(
                  color: AppColors.bgWhite,
                  border: Border(
                      top: BorderSide(
                          color: AppColors.borderCard, width: 0.5)),
                ),
                child: Row(
                  children: [
                    // Tolak
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.badgeRedText,
                          side: const BorderSide(
                              color: AppColors.badgeRedText),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isProcessing ? null : _tolak,
                        child: const Text('Tolak',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Konfirmasi
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _bisaKonfirmasi
                              ? AppColors.primary
                              : AppColors.borderCard,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed:
                            (_isProcessing || !_bisaKonfirmasi)
                                ? null
                                : _konfirmasi,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Icon(
                                Icons.check_circle_outline,
                                size: 18),
                        label: const Text(
                          'Konfirmasi Pembayaran',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Widget helper ──────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _SheetSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isMono;
  final Color? valueColor;

  const _SheetRow(this.label, this.value,
      {this.isBold = false, this.isMono = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.w500,
                fontFamily: isMono ? 'monospace' : null,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _InfoItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isBold ? FontWeight.w600 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
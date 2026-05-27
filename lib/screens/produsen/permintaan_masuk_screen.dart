import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../models/transaksi_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widget.dart';

class PermintaanMasukScreen extends StatefulWidget {
  const PermintaanMasukScreen({super.key});
  @override
  State<PermintaanMasukScreen> createState() => _PermintaanMasukScreenState();
}

class _PermintaanMasukScreenState extends State<PermintaanMasukScreen> {
  final List<_PermintaanItem> _items = [
    // Menunggu = pesanan masuk, belum ada validasi admin
    _PermintaanItem(
      id: 1,
      mitra: 'CV Mitra Bahari',
      produk: 'Ikan Kerapu',
      jumlah: '80 kg',
      harga: 'Rp 3.600.000',
      tanggal: '15 Apr 2026',
      statusPesanan: 'Menunggu',
      statusPembayaran: 'Menunggu',
      catatanAdmin: null,
    ),
    // Pembayaran sudah divalidasi admin, produsen bisa proses
    _PermintaanItem(
      id: 2,
      mitra: 'PT Seafood Nusantara',
      produk: 'Udang Vaname',
      jumlah: '50 kg',
      harga: 'Rp 4.250.000',
      tanggal: '14 Apr 2026',
      statusPesanan: 'Menunggu',
      statusPembayaran: 'Tervalidasi',
      catatanAdmin: 'Pembayaran telah dikonfirmasi. Silakan proses pesanan.',
    ),
    // Sudah diproses produsen
    _PermintaanItem(
      id: 3,
      mitra: 'UD Bahari Jaya',
      produk: 'Kakap Merah',
      jumlah: '30 kg',
      harga: 'Rp 1.350.000',
      tanggal: '12 Apr 2026',
      statusPesanan: 'Diproses',
      statusPembayaran: 'Tervalidasi',
      catatanAdmin: 'Pembayaran telah dikonfirmasi.',
    ),
    // Ditolak produsen
    _PermintaanItem(
      id: 4,
      mitra: 'CV Sumber Laut',
      produk: 'Cumi-cumi',
      jumlah: '20 kg',
      harga: 'Rp 1.000.000',
      tanggal: '11 Apr 2026',
      statusPesanan: 'Ditolak',
      statusPembayaran: 'Tervalidasi',
      catatanAdmin: 'Pembayaran telah dikonfirmasi.',
      alasanTolak: 'Stok tidak tersedia',
    ),
  ];

  String _hariIni() {
    final now = DateTime.now();
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei',
      'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${now.day} ${bulan[now.month]} ${now.year}';
  }

  // Proses pesanan setelah admin validasi pembayaran
  void _prosesPesanan(_PermintaanItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Proses Pesanan?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Text(
          'Pesanan dari ${item.mitra} untuk ${item.produk} (${item.jumlah}) akan diproses.\n\nPastikan produk siap untuk dikirim.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final idx = _items.indexWhere((e) => e.id == item.id);
                if (idx != -1) {
                  _items[idx] = _items[idx].copyWith(statusPesanan: 'Diproses');
                }
              });
              context.read<TransaksiProvider>().tambah(TransaksiModel(
                id: 'trx-${DateTime.now().millisecondsSinceEpoch}',
                mitra: item.mitra,
                produk: item.produk,
                jumlah: item.jumlah,
                harga: item.harga,
                tanggal: _hariIni(),
                status: 'Selesai',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan sedang diproses'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Proses'),
          ),
        ],
      ),
    );
  }

  // Tolak pesanan
  void _showPopupTolak(BuildContext context, _PermintaanItem item) {
    final alasanCtrl = TextEditingController();
    final List<String> alasanList = [
      'Stok tidak tersedia',
      'Harga tidak sesuai',
      'Lokasi pengiriman terlalu jauh',
      'Kualitas produk tidak memenuhi syarat',
      'Lainnya',
    ];
    String? alasanDipilih;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('Alasan Penolakan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesanan dari ${item.mitra} akan ditolak.\nPilih alasan penolakan:',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ...alasanList.map((alasan) => GestureDetector(
                        onTap: () => setStateDialog(() => alasanDipilih = alasan),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: alasanDipilih == alasan
                                ? AppColors.badgeRedBg
                                : AppColors.bgPage,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: alasanDipilih == alasan
                                  ? AppColors.textDanger
                                  : AppColors.borderCard,
                              width: alasanDipilih == alasan ? 1.5 : 0.5,
                            ),
                          ),
                          child: Row(children: [
                            Icon(
                              alasanDipilih == alasan
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 16,
                              color: alasanDipilih == alasan
                                  ? AppColors.textDanger
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(alasan,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: alasanDipilih == alasan
                                          ? AppColors.textDanger
                                          : AppColors.textPrimary,
                                      fontWeight: alasanDipilih == alasan
                                          ? FontWeight.w500
                                          : FontWeight.normal)),
                            ),
                          ]),
                        ),
                      )),
                  if (alasanDipilih == 'Lainnya') ...[
                    const SizedBox(height: 4),
                    TextField(
                      controller: alasanCtrl,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan alasan lainnya...',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.bgPage,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderInput, width: 0.5)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderInput, width: 0.5)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.textDanger, width: 1.5)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: alasanDipilih == null
                    ? null
                    : () {
                        final alasanFinal =
                            alasanDipilih == 'Lainnya' && alasanCtrl.text.isNotEmpty
                                ? alasanCtrl.text
                                : alasanDipilih!;
                        Navigator.pop(ctx);
                        setState(() {
                          final idx = _items.indexWhere((e) => e.id == item.id);
                          if (idx != -1) {
                            _items[idx] = _items[idx].copyWith(
                                statusPesanan: 'Ditolak', alasanTolak: alasanFinal);
                          }
                        });
                        context.read<TransaksiProvider>().tambah(TransaksiModel(
                          id: 'trx-${DateTime.now().millisecondsSinceEpoch}',
                          mitra: item.mitra,
                          produk: item.produk,
                          jumlah: item.jumlah,
                          harga: item.harga,
                          tanggal: _hariIni(),
                          status: 'Ditolak',
                          alasanTolak: alasanFinal,
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pesanan ditolak'),
                            backgroundColor: AppColors.textDanger,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: alasanDipilih == null
                      ? AppColors.borderCard
                      : AppColors.textDanger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  disabledBackgroundColor: AppColors.borderCard,
                ),
                child: const Text('Konfirmasi Tolak'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menunggu = _items.where((e) => e.statusPesanan == 'Menunggu').length;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Permintaan Masuk',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222))),
            Text('$menunggu pesanan menunggu diproses',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        toolbarHeight: 64,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE4E4E4)),
        ),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 52, color: AppColors.textSecondary),
                  SizedBox(height: 10),
                  Text('Belum ada permintaan masuk',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _items.map((item) => _buildCard(item)).toList(),
            ),
    );
  }

  Widget _buildCard(_PermintaanItem item) {
    final isMenunggu     = item.statusPesanan == 'Menunggu';
    final isTervalidasi  = item.statusPembayaran == 'Tervalidasi';
    final isDiproses     = item.statusPesanan == 'Diproses';
    final isDitolak      = item.statusPesanan == 'Ditolak';

    // Warna & badge status pesanan
    BadgeType badgePesanan;
    if (isDiproses) {
      badgePesanan = BadgeType.green;
    } else if (isDitolak) {
      badgePesanan = BadgeType.red;
    } else {
      badgePesanan = BadgeType.amber;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        opacity: (isDiproses || isDitolak) ? 0.7 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item.mitra,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ),
                StatusBadge(item.statusPesanan, type: badgePesanan),
              ],
            ),
            const SizedBox(height: 10),

            // ── Detail pesanan ────────────────────────────────────────
            Row(children: [
              _DetailCell(label: 'Produk', value: item.produk),
              _DetailCell(label: 'Jumlah', value: item.jumlah),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _DetailCell(
                  label: 'Total harga',
                  value: item.harga,
                  valueColor: AppColors.textSuccess),
              _DetailCell(label: 'Tanggal', value: item.tanggal),
            ]),
            const SizedBox(height: 12),

            // ── Status pembayaran dari admin ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isTervalidasi
                    ? AppColors.badgeGreenBg
                    : AppColors.badgeAmberBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isTervalidasi
                      ? AppColors.badgeGreenText.withOpacity(0.3)
                      : AppColors.badgeAmberText.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isTervalidasi
                        ? Icons.verified_outlined
                        : Icons.hourglass_empty_outlined,
                    size: 16,
                    color: isTervalidasi
                        ? AppColors.badgeGreenText
                        : AppColors.badgeAmberText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTervalidasi
                              ? 'Pembayaran tervalidasi oleh admin'
                              : 'Menunggu validasi pembayaran oleh admin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isTervalidasi
                                ? AppColors.badgeGreenText
                                : AppColors.badgeAmberText,
                          ),
                        ),
                        // Catatan dari admin kalau ada
                        if (item.catatanAdmin != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.catatanAdmin!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isTervalidasi
                                  ? AppColors.badgeGreenText
                                  : AppColors.badgeAmberText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Alasan tolak ──────────────────────────────────────────
            if (isDitolak && item.alasanTolak != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.badgeRedBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.textDanger.withOpacity(0.3), width: 0.5),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.textDanger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Alasan ditolak:',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDanger)),
                      const SizedBox(height: 2),
                      Text(item.alasanTolak!,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textDanger)),
                    ]),
                  ),
                ]),
              ),
            ],

            // ── Tombol aksi ───────────────────────────────────────────
            // Hanya tampil kalau pembayaran sudah tervalidasi admin
            // dan pesanan masih Menunggu
            if (isMenunggu && isTervalidasi) ...[
              const SizedBox(height: 12),
              Row(children: [
                // Tolak
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPopupTolak(context, item),
                    icon: const Icon(Icons.close, size: 14, color: AppColors.textDanger),
                    label: const Text('Tolak',
                        style: TextStyle(fontSize: 12, color: AppColors.textDanger)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.textDanger),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Proses
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _prosesPesanan(item),
                    icon: const Icon(Icons.local_shipping_outlined, size: 14),
                    label: const Text('Proses', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ]),
            ],

            // Pesanan menunggu validasi admin — tidak ada tombol aksi
            if (isMenunggu && !isTervalidasi) ...[
              const SizedBox(height: 10),
              const Row(children: [
                Icon(Icons.info_outline, size: 13, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tombol proses akan muncul setelah admin memvalidasi pembayaran.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ]),
            ],

            // Status diproses
            if (isDiproses) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.metricAccentBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(children: [
                  Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.textSuccess),
                  SizedBox(width: 6),
                  Text('Pesanan sedang diproses',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSuccess)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────
class _DetailCell extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailCell({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary)),
      ]),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _PermintaanItem {
  final int id;
  final String mitra, produk, jumlah, harga, tanggal;
  final String statusPesanan;    // 'Menunggu' | 'Diproses' | 'Ditolak'
  final String statusPembayaran; // 'Menunggu' | 'Tervalidasi'
  final String? catatanAdmin;    // catatan dari admin setelah validasi
  final String? alasanTolak;

  const _PermintaanItem({
    required this.id,
    required this.mitra,
    required this.produk,
    required this.jumlah,
    required this.harga,
    required this.tanggal,
    required this.statusPesanan,
    required this.statusPembayaran,
    this.catatanAdmin,
    this.alasanTolak,
  });

  _PermintaanItem copyWith({
    String? statusPesanan,
    String? statusPembayaran,
    String? catatanAdmin,
    String? alasanTolak,
  }) =>
      _PermintaanItem(
        id: id,
        mitra: mitra,
        produk: produk,
        jumlah: jumlah,
        harga: harga,
        tanggal: tanggal,
        statusPesanan: statusPesanan ?? this.statusPesanan,
        statusPembayaran: statusPembayaran ?? this.statusPembayaran,
        catatanAdmin: catatanAdmin ?? this.catatanAdmin,
        alasanTolak: alasanTolak ?? this.alasanTolak,
      );
}
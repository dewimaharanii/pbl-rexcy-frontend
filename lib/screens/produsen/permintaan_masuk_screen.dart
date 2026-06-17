import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widget.dart';
import '../../services/mitra_api_service.dart';

class PermintaanMasukScreen extends StatefulWidget {
  const PermintaanMasukScreen({super.key});

  @override
  State<PermintaanMasukScreen> createState() =>
      _PermintaanMasukScreenState();
}

class _PermintaanMasukScreenState extends State<PermintaanMasukScreen> {
  List<dynamic> _items = [];
  bool _isLoading      = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await MitraApiService.getProdusenPermintaan();
    if (!mounted) return;
    setState(() {
      _items     = result['data'] ?? [];
      _isLoading = false;
    });
  }

  Future<void> _proses(String idPermintaan) async {
    final result = await MitraApiService.prosesPermintaan(
        idPermintaan);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Permintaan berhasil diproses!'),
        backgroundColor: AppColors.primary,
      ));
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Gagal'),
        backgroundColor: AppColors.textDanger,
      ));
    }
  }

  Future<void> _tolak(String idPermintaan) async {
    final result = await MitraApiService.tolakPermintaan(
        idPermintaan);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Permintaan ditolak'),
        backgroundColor: AppColors.textDanger,
      ));
      _loadData();
    }
  }

  void _showProsesDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Text('Proses Permintaan?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        content: Text(
          'Permintaan dari ${item['nama_mitra'] ?? 'Mitra'} '
          'sebanyak ${item['jumlah_permintaan'] ?? '-'} kg '
          'akan diproses.',
          style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proses(item['id_permintaan']?.toString() ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Proses'),
          ),
        ],
      ),
    );
  }

  void _showTolakDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Text('Tolak Permintaan?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        content: const Text(
          'Permintaan ini akan ditolak.',
          style: TextStyle(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tolak(item['id_permintaan']?.toString() ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menunggu = _items
        .where((e) => e['status']?.toString().toLowerCase() == 'pending')
        .length;

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
            Text('$menunggu permintaan menunggu',
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        toolbarHeight: 64,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _loadData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE4E4E4)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 52, color: AppColors.textSecondary),
                      SizedBox(height: 10),
                      Text('Belum ada permintaan masuk',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final item   = _items[i];
                      final status = item['status']
                              ?.toString()
                              .toLowerCase() ??
                          '';
                      final isPending  = status == 'pending';
                      final isDiproses = status == 'diproses';
                      final isDitolak  = status == 'ditolak';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['nama_mitra'] ?? 'Mitra',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary),
                                    ),
                                  ),
                                  StatusBadge(
                                    isPending
                                        ? 'Menunggu'
                                        : isDiproses
                                            ? 'Diproses'
                                            : 'Ditolak',
                                    type: isPending
                                        ? BadgeType.amber
                                        : isDiproses
                                            ? BadgeType.green
                                            : BadgeType.red,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const AppDivider(),
                              const SizedBox(height: 10),

                              // Detail
                              Row(children: [
                                _DetailCell(
                                  label: 'Produk',
                                  value: item['nama_produk'] ?? '-',
                                ),
                                _DetailCell(
                                  label: 'Jumlah',
                                  value:
                                      '${item['jumlah_permintaan'] ?? '-'} kg',
                                ),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                _DetailCell(
                                  label: 'Tanggal',
                                  value: item['tanggal_permintaan']
                                          ?.toString()
                                          .substring(0, 10) ??
                                      '-',
                                ),
                                _DetailCell(
                                  label: 'Estimasi Total',
                                  value:
                                      'Rp ${_formatRp(item['estimasi_total'] ?? 0)}',
                                  valueColor: AppColors.textSuccess,
                                ),
                              ]),

                              // Tombol aksi
                              if (isPending) ...[
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _showTolakDialog(item),
                                      icon: const Icon(Icons.close,
                                          size: 14,
                                          color: AppColors.textDanger),
                                      label: const Text('Tolak',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppColors.textDanger)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: AppColors.textDanger),
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showProsesDialog(item),
                                      icon: const Icon(
                                          Icons.local_shipping_outlined,
                                          size: 14),
                                      label: const Text('Proses',
                                          style: TextStyle(
                                              fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8)),
                                      ),
                                    ),
                                  ),
                                ]),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatRp(dynamic val) {
    final v = int.tryParse(val.toString()) ?? 0;
    return v
        .toString()
        .replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }
}

class _DetailCell extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailCell(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
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
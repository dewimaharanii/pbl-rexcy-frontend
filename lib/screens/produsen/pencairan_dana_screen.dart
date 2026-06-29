import 'package:flutter/material.dart';
import '../../services/mitra_api_service.dart';
import '../../theme/app_theme.dart';

class PencairanDanaScreen extends StatefulWidget {
  final int saldoTersedia;

  const PencairanDanaScreen({super.key, this.saldoTersedia = 0});

  @override
  State<PencairanDanaScreen> createState() => _PencairanDanaScreenState();
}

class _PencairanDanaScreenState extends State<PencairanDanaScreen> {
  List<dynamic> _riwayat = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await MitraApiService.getRiwayatPencairan();
    if (result['success'] == true) {
      setState(() => _riwayat = result['data'] ?? []);
    } else {
      setState(() => _errorMessage = result['message']?.toString() ?? 'Gagal memuat data (kosong)');
    }
    setState(() => _isLoading = false);
  }

  String _formatRp(dynamic val) {
    final num = int.tryParse(val.toString()) ?? 0;
    return num.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  void _showFormAjukan() {
    final formKey = GlobalKey<FormState>();
    final jumlahController = TextEditingController();
    final bankController = TextEditingController();
    final rekeningController = TextEditingController();
    final namaRekeningController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ajukan Pencairan Dana',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Saldo tersedia: Rp ${_formatRp(widget.saldoTersedia)}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Dana (Rp)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        final jumlah = int.tryParse(v) ?? 0;
                        if (jumlah <= 0) return 'Jumlah harus lebih dari 0';
                        if (jumlah > widget.saldoTersedia) {
                          return 'Saldo tidak cukup (maks Rp ${_formatRp(widget.saldoTersedia)})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: bankController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Bank',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: rekeningController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Rekening',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: namaRekeningController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pemilik Rekening',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSubmitting = true);

                                final result = await MitraApiService.ajukanPencairan(
                                  jumlahDana: int.tryParse(jumlahController.text) ?? 0,
                                  namaBank: bankController.text,
                                  noRekening: rekeningController.text,
                                  namaPemilikRekening: namaRekeningController.text,
                                );

                                setModalState(() => isSubmitting = false);

                                if (!mounted) return;
                                if (result['success'] == true) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(result['message'] ?? 'Pengajuan berhasil dikirim'),
                                    backgroundColor: AppColors.successGreen,
                                  ));
                                  _loadData();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(result['message'] ?? 'Gagal mengajukan'),
                                    backgroundColor: AppColors.deleteRed,
                                  ));
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Ajukan Sekarang',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _statusInfo(String rawStatus) {
    switch (rawStatus) {
      case 'Disetujui':
        return {'color': AppColors.blue, 'label': 'Disetujui'};
      case 'Selesai':
        return {'color': AppColors.successGreen, 'label': 'Selesai'};
      case 'Ditolak':
        return {'color': AppColors.deleteRed, 'label': 'Ditolak'};
      default:
        return {'color': AppColors.warning, 'label': 'Menunggu'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        title: const Text('Pencairan Dana',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        onPressed: _showFormAjukan,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo Tersedia',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Rp ${_formatRp(widget.saldoTersedia)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.blue)),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(_errorMessage,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      )
                    : _riwayat.isEmpty
                        ? const Center(
                            child: Text('Belum ada pengajuan pencairan dana',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: _riwayat.length,
                              itemBuilder: (context, index) {
                                final item = _riwayat[index];
                                final info = _statusInfo(item['status']?.toString() ?? 'Menunggu');

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text('#${item['id_pencairan']}',
                                                  style: const TextStyle(
                                                      color: AppColors.blue,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12)),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: (info['color'] as Color).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(info['label'],
                                                  style: TextStyle(
                                                      color: info['color'],
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        Text('Rp ${_formatRp(item['jumlah_dana'])}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.successGreen)),
                                        const SizedBox(height: 8),
                                        Text('Bank: ${item['nama_bank'] ?? '-'}',
                                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        Text('No. Rek: ${item['no_rekening'] ?? '-'}',
                                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        Text('a.n: ${item['nama_pemilik_rekening'] ?? '-'}',
                                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        if (item['keterangan_admin'] != null &&
                                            item['keterangan_admin'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text('Keterangan Admin: ${item['keterangan_admin']}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.deleteRed,
                                                  fontStyle: FontStyle.italic)),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
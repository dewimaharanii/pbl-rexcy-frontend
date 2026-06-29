import 'package:flutter/material.dart';
import '../../services/mitra_api_service.dart';
import '../../theme/app_theme.dart';

class AdminPencairanScreen extends StatefulWidget {
  const AdminPencairanScreen({super.key});

  @override
  State<AdminPencairanScreen> createState() => _AdminPencairanScreenState();
}

class _AdminPencairanScreenState extends State<AdminPencairanScreen> {
  List<dynamic> _listPencairan = [];
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

    final result = await MitraApiService.adminGetPencairan();
    if (result['success'] == true) {
      setState(() => _listPencairan = result['data'] ?? []);
    } else {
      setState(() => _errorMessage = result['message'] ?? 'Gagal memuat data (kosong)');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _proses(String id, String action) async {
    final result = await MitraApiService.adminProsesPencairan(id, action);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['message'] ??
          (action == 'terima' ? 'Pengajuan disetujui' : 'Pengajuan ditolak')),
      backgroundColor: result['success'] == true
          ? (action == 'terima' ? AppColors.successGreen : AppColors.deleteRed)
          : AppColors.deleteRed,
    ));

    if (result['success'] == true) _loadData();
  }

  Future<void> _selesaikan(String id) async {
    final result = await MitraApiService.adminSelesaikanPencairan(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['message'] ?? 'Pencairan ditandai selesai'),
      backgroundColor: result['success'] == true ? AppColors.successGreen : AppColors.deleteRed,
    ));

    if (result['success'] == true) _loadData();
  }

  String _formatRp(dynamic val) {
    final num = int.tryParse(val.toString()) ?? 0;
    return num.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          backgroundColor: AppColors.blue,
          title: const Text('Pencairan Dana',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(_errorMessage,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        title: const Text('Pencairan Dana',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _listPencairan.isEmpty
          ? const Center(
              child: Text('Belum ada pengajuan pencairan dana',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _listPencairan.length,
                itemBuilder: (context, index) {
                  final item = _listPencairan[index];
                  final rawStatus = item['status']?.toString() ?? 'Menunggu';

                  Color statusColor = AppColors.warning;
                  String statusLabel = 'Menunggu';
                  if (rawStatus == 'Disetujui') {
                    statusColor = AppColors.blue;
                    statusLabel = 'Disetujui';
                  } else if (rawStatus == 'Selesai') {
                    statusColor = AppColors.successGreen;
                    statusLabel = 'Selesai';
                  } else if (rawStatus == 'Ditolak') {
                    statusColor = AppColors.deleteRed;
                    statusLabel = 'Ditolak';
                  }

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
                              Text(statusLabel,
                                  style: TextStyle(
                                      color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const Divider(height: 24),
                          Text('Produsen: ${item['nama_produsen'] ?? '-'}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Rp ${_formatRp(item['jumlah_dana'])}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.successGreen)),
                          const SizedBox(height: 8),
                          Text('Bank: ${item['nama_bank'] ?? '-'}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text('No. Rek: ${item['no_rekening'] ?? '-'}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text('a.n: ${item['nama_pemilik_rekening'] ?? '-'}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 16),

                          if (rawStatus == 'Menunggu') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _proses(item['id_pencairan'].toString(), 'tolak'),
                                    child: const Text('Tolak', style: TextStyle(color: AppColors.deleteRed)),
                                  ),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _proses(item['id_pencairan'].toString(), 'terima'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.successGreen,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Setujui', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (rawStatus == 'Disetujui') ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _selesaikan(item['id_pencairan'].toString()),
                                icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                                label: const Text('Tandai Selesai (Sudah Transfer)',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(statusLabel,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                            ),
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
}
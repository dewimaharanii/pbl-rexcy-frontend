import 'package:flutter/material.dart';
import '../../theme/app_theme.dart'; 
import '../../services/mitra_api_service.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});
  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  List<dynamic> _allData = [];
  bool _isLoading = true;
  String _selectedTab = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await MitraApiService.getProdusenTransaksi();
    if (!mounted) return;
    setState(() {
      _allData = result['data'] ?? [];
      _isLoading = false;
    });
  }

  List<dynamic> get _filteredData {
    if (_selectedTab == 'Selesai') return _allData.where((e) => e['status'] == 'selesai').toList();
    if (_selectedTab == 'Diproses') return _allData.where((e) => e['status'] == 'diproses').toList();
    return _allData;
  }

  String _formatRp(dynamic val) {
    final v = int.tryParse(val.toString()) ?? 0;
    return v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  // Penerjemah warna dan teks badge status
  Widget _buildBadge(String status) {
    Color bgColor = AppColors.bgPage;
    Color textColor = AppColors.textSecondary;
    String label = '-';

    switch (status.toLowerCase()) {
      case 'selesai':
        bgColor = AppColors.successGreen.withOpacity(0.15);
        textColor = AppColors.successGreen;
        label = 'Selesai';
        break;
      case 'diproses':
        bgColor = AppColors.blue.withOpacity(0.15);
        textColor = AppColors.blue;
        label = 'Diproses';
        break;
      case 'ditolak':
        bgColor = AppColors.deleteRed.withOpacity(0.15);
        textColor = AppColors.deleteRed;
        label = 'Ditolak';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredData;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Transaksi', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${_allData.length} total transaksi', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.grey), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['Semua', 'Selesai', 'Diproses'].map((tab) {
                final isSelected = _selectedTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.blue : AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tab, style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.blue,
                        fontSize: 13, fontWeight: FontWeight.w600,
                      )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4E4E4)),
          
          // List Transaksi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? const Center(child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final item = list[i];
                          // Tangkap total_harga dengan aman
                          final harga = item['total_harga'] ?? item['estimasi_total'] ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE4E4E4)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Info Kiri
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['nama_mitra'] ?? 'Mitra', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('${item['nama_produk'] ?? '-'} · ${item['jumlah_permintaan'] ?? 0} kg', 
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(item['tanggal_permintaan']?.toString().substring(0, 10) ?? '-', 
                                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                                // Harga & Badge Kanan
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Rp ${_formatRp(harga)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    _buildBadge(item['status'] ?? ''),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
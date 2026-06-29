import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class AdminPembayaranScreen extends StatefulWidget {
  const AdminPembayaranScreen({super.key});

  @override
  State<AdminPembayaranScreen> createState() => _AdminPembayaranScreenState();
}

class _AdminPembayaranScreenState extends State<AdminPembayaranScreen> {
  List<dynamic> _listPembayaran = [];
  bool _isLoading = true;
  String _errorMessage = ''; 

  // Sesuaikan dengan IP komputermu
  final String baseUrl = 'http://localhost:8000/api'; 
  final String storageUrl = 'http://localhost:8000/storage/';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token') ?? prefs.getString('token') ?? '';

    if (token.isEmpty) {
      setState(() {
        _errorMessage = "GAGAL AKSES: Token tidak ditemukan. Silakan Login ulang!";
        _isLoading = false;
      });
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/admin/pembayaran-pending'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          setState(() => _listPembayaran = data['data'] ?? []);
        } else {
          setState(() => _errorMessage = data['message']);
        }
      } else {
        setState(() => _errorMessage = "ERROR SERVER (${res.statusCode}):\n${res.body}");
      }
    } catch (e) {
      setState(() => _errorMessage = "GAGAL KONEKSI:\nDetail: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validasi(String id, String jenis, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token') ?? prefs.getString('token') ?? '';

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/admin/pembayaran/validasi/$jenis/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'action': action}),
      );

      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(action == 'terima' ? 'Pembayaran Dikonfirmasi!' : 'Pembayaran Ditolak!'),
          backgroundColor: action == 'terima' ? AppColors.successGreen : AppColors.deleteRed,
        ));
        _loadData(); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _lihatBuktiDialog(String? imagePath) {
    String fileName = imagePath?.split('/').last ?? '';
    // Memanggil API Bypass CORS
    String bypassCorsUrl = '$baseUrl/file/bukti-transfer/$fileName'; 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bukti Pembayaran', style: TextStyle(fontSize: 16)),
        content: imagePath != null && imagePath.isNotEmpty
            ? Image.network(
                bypassCorsUrl, 
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image, color: Colors.red, size: 50),
                    const SizedBox(height: 8),
                    Text('Gagal memuat: $bypassCorsUrl', style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
              )
            : const Text('Tidak ada gambar bukti pembayaran yang diunggah. (Data di Database kosong)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  String _formatRp(dynamic val) {
    final num = int.tryParse(val.toString()) ?? 0;
    return num.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  String _formatTgl(dynamic val) {
    final s = val?.toString() ?? '';
    if (s.isEmpty) return '-';
    try {
      final dt = DateTime.parse(s);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return s.length >= 10 ? s.substring(0, 10) : s;
    }
  }

  Widget _buildListContent(String filterJenis) {
    final filteredList = _listPembayaran.where((item) => item['jenis'].toString().toUpperCase() == filterJenis).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text('Belum ada riwayat $filterJenis', 
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final item = filteredList[index];
          final jenis = item['jenis'].toString().toUpperCase();
          
          final rawStatus = item['status']?.toString() ?? 'Menunggu Konfirmasi';
          Color statusColor = AppColors.warning;
          String statusLabel = 'Menunggu Validasi';
          bool isPending = true;

          if (rawStatus.toLowerCase() == 'dikonfirmasi') {
            statusColor = AppColors.successGreen;
            statusLabel = 'Dikonfirmasi';
            isPending = false;
          } else if (rawStatus.toLowerCase() == 'ditolak') {
            statusColor = AppColors.deleteRed;
            statusLabel = 'Ditolak';
            isPending = false;
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
                        decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text('$jenis #${item['id_pesanan']}', style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 24),
                  Text('Mitra: ${item['mitra']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Produk: ${item['produk']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Total Transfer: Rp ${_formatRp(item['total'])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.successGreen)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.iconGrey),
                      const SizedBox(width: 6),
                      Text('Dibuat: ${_formatTgl(item['tanggal_pembuatan'] ?? item['tanggal'])}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _lihatBuktiDialog(item['bukti']),
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('Lihat Bukti'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                      const Spacer(),
                      
                      if (isPending) ...[
                        TextButton(
                          onPressed: () => _validasi(item['id_pesanan'].toString(), item['jenis'], 'tolak'),
                          child: const Text('Tolak', style: TextStyle(color: AppColors.deleteRed)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _validasi(item['id_pesanan'].toString(), item['jenis'], 'terima'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('Validasi', style: TextStyle(color: Colors.white)),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center)));
    }

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // 🚀 PERBAIKAN: Menggunakan Scaffold agar muncul AppBar + Tombol Refresh
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          backgroundColor: AppColors.blue,
          title: const Text('Data Pembayaran', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false, // Matikan back button jika ini tab
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData,
              tooltip: 'Refresh Data',
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Pembelian'),
              Tab(text: 'Permintaan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListContent('PEMBELIAN'),
            _buildListContent('PERMINTAAN'),
          ],
        ),
      ),
    );
  }
}
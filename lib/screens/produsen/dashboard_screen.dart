import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widget.dart';
import '../../providers/user_provider.dart';
import '../../services/mitra_api_service.dart';
import 'pencairan_dana_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalProduksi   = 0;
  int _totalPermintaan = 0;
  int _totalTransaksi  = 0;
  int _saldoTersedia   = 0;
  bool _isLoading      = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final produksi   = await MitraApiService.getProdusenProduksi();
      final permintaan = await MitraApiService.getProdusenPermintaan();
      final transaksi  = await MitraApiService.getProdusenTransaksi();
      final saldo      = await MitraApiService.getSaldoProdusen();

      if (!mounted) return;
      setState(() {
        _totalProduksi   = (produksi['data']   as List).length;
        _totalPermintaan = (permintaan['data'] as List).length;
        _totalTransaksi  = (transaksi['data']  as List).length;
        _saldoTersedia   = saldo['success'] == true
             ? (saldo['data']['saldo_tersedia'] ?? 0): 0;
        _isLoading       = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatRp(int val) {
    return val.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222))),
            Text('Selamat datang, ${user?.name ?? 'Produsen'}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    MetricCard(
                      label: 'Total Produksi',
                      value: '$_totalProduksi',
                      unit: 'item',
                      accent: true,
                    ),
                    const SizedBox(width: 10),
                    MetricCard(
                      label: 'Permintaan Masuk',
                      value: '$_totalPermintaan',
                      valueColor: AppColors.badgeBlueText,
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    MetricCard(
                      label: 'Total Transaksi',
                      value: '$_totalTransaksi',
                    ),
                    const SizedBox(width: 10),
                    const MetricCard(
                      label: 'Status',
                      value: 'Aktif',
                    ),
                  ]),
                  const SizedBox(height: 16),
                  const AppDivider(),
                  const SizedBox(height: 12),
                  const Text('Ringkasan',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  AppCard(
                    child: Column(children: [
                      _SummaryRow(
                        icon: Icons.inventory_2_outlined,
                        label: 'Total Produksi',
                        value: '$_totalProduksi item',
                        color: AppColors.primary,
                      ),
                      const AppDivider(),
                      _SummaryRow(
                        icon: Icons.inbox_outlined,
                        label: 'Permintaan Masuk',
                        value: '$_totalPermintaan permintaan',
                        color: AppColors.badgeBlueText,
                      ),
                      const AppDivider(),
                      _SummaryRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'Total Transaksi',
                        value: '$_totalTransaksi transaksi',
                        color: AppColors.textSuccess,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  const AppDivider(),
                  const SizedBox(height: 12),
                  const Text('Keuangan',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Tersedia',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Rp ${_formatRp(_saldoTersedia)}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PencairanDanaScreen(
                            saldoTersedia: _saldoTersedia,
                          ),
                        ),
                      ).then((_) => _loadData());
                    },
                    child: AppCard(
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance_wallet_outlined,
                              color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Ajukan Pencairan Dana',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textPrimary)),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.iconGrey, size: 20),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color)),
      ]),
    );
  }
}
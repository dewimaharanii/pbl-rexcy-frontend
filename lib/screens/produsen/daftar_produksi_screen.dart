import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/produksi_provider.dart';
import '../../models/produksi_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widget.dart';
import 'input_produksi_screen.dart';

class DaftarProduksiScreen extends StatefulWidget {
  const DaftarProduksiScreen({super.key});
  @override
  State<DaftarProduksiScreen> createState() => _DaftarProduksiScreenState();
}

class _DaftarProduksiScreenState extends State<DaftarProduksiScreen> {
  String _filter = 'Semua';
  final _filterList = ['Semua', 'Ikan', 'Udang', 'Cumi'];

  String _rupiah(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  Color _kategoriColor(String k) {
    if (k == 'Ikan')  return const Color(0xFF1D9E75);
    if (k == 'Udang') return const Color(0xFF288AE7);
    return const Color(0xFFEF9F27);
  }

  @override
  Widget build(BuildContext context) {
    final provider   = context.watch<ProduksiProvider>();
    final filtered   = _filter == 'Semua'
        ? provider.list
        : provider.list.where((e) => e.kategori == _filter).toList();
    final totalKg    = filtered.fold(0.0, (s, e) => s + e.jumlahKg);
    final totalNilai = filtered.fold(0.0, (s, e) => s + e.totalHarga);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar Produksi',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222))),
            Text('${filtered.length} data tercatat',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        toolbarHeight: 64,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE4E4E4)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              MetricCard(
                  label: 'Total produksi',
                  value: '${totalKg.toStringAsFixed(0)} kg',
                  accent: true),
              const SizedBox(width: 10),
              MetricCard(label: 'Total nilai', value: _rupiah(totalNilai)),
            ]),
          ),
          const SizedBox(height: 12),

          // Filter chip
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => CategoryChip(
                _filterList[i],
                isActive: _filter == _filterList[i],
                onTap: () => setState(() => _filter = _filterList[i]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AppDivider()),
          const SizedBox(height: 4),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inbox_outlined,
                            size: 52, color: AppColors.textSecondary),
                        SizedBox(height: 10),
                        Text('Belum ada data produksi',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text('Tap tombol + untuk menambahkan',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ProduksiCard(
                      item: filtered[i],
                      rupiah: _rupiah,
                      kategoriColor: _kategoriColor(filtered[i].kategori),
                      onHapus: () => _hapus(context, filtered[i]),
                    ),
                  ),
          ),
        ],
      ),

      // ← FAB pakai Navigator.push langsung, BUKAN pushNamed
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const InputProduksiScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produksi',
            style: TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _hapus(BuildContext context, ProduksiModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Hapus Data?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        content: Text(
            'Data "${item.jenisProduk}" (${item.kategori}) pada ${item.tanggal} akan dihapus.',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProduksiProvider>().hapus(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Data berhasil dihapus'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _ProduksiCard extends StatelessWidget {
  final ProduksiModel item;
  final String Function(double) rupiah;
  final Color kategoriColor;
  final VoidCallback onHapus;
  const _ProduksiCard(
      {required this.item,
      required this.rupiah,
      required this.kategoriColor,
      required this.onHapus});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: kategoriColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(item.kategori,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: kategoriColor)),
                    ),
                    const SizedBox(height: 6),
                    Text(item.jenisProduk,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Color(0xFF288AE7),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(item.tanggal,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ]),
                  ]),
            ),
            GestureDetector(
              onTap: onHapus,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_outline,
                    size: 16, color: Colors.red),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const AppDivider(),
        const SizedBox(height: 10),
        Row(children: [
          _InfoCell(
              label: 'Jumlah',
              value: '${item.jumlahKg.toStringAsFixed(0)} kg'),
          _InfoCell(label: 'Harga /kg', value: rupiah(item.hargaPerKg)),
          _InfoCell(
              label: 'Total nilai',
              value: rupiah(item.totalHarga),
              highlight: true),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.location_on_outlined,
              size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Expanded(
              child: Text(item.lokasiTangkap,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary))),
        ]),
        if (item.catatan.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.notes_outlined,
                size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
                child: Text(item.catatan,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary))),
          ]),
        ],
      ]),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _InfoCell(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: highlight
                    ? AppColors.textSuccess
                    : AppColors.textPrimary)),
      ]),
    );
  }
}
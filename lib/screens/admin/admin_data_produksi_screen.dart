import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';

class AdminDataProduksiScreen extends StatefulWidget {
  const AdminDataProduksiScreen({super.key});
  @override
  State<AdminDataProduksiScreen> createState() => _State();
}

class _State extends State<AdminDataProduksiScreen> {
  String _search = '';

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final list = admin.produksiList
        .where((p) =>
            p.namaProduk.toLowerCase().contains(_search.toLowerCase()) ||
            p.produsenNama.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Cari produksi...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                          AppColors.primary.withOpacity(0.08)),
                      columns: const [
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Produsen')),
                        DataColumn(label: Text('Produk')),
                        DataColumn(label: Text('Stok')),
                        DataColumn(label: Text('Harga/unit')),
                        DataColumn(label: Text('Lokasi')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: list.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(
                              '${p.dibuatPada.day}/${p.dibuatPada.month}/${p.dibuatPada.year}')),
                          DataCell(Text(p.produsenNama)),
                          DataCell(Text(p.namaProduk)),
                          DataCell(Text('${p.jumlahStok}')),
                          DataCell(Text('Rp ${_fmt(p.hargaProduksi)}')),
                          DataCell(Text(p.lokasiTangkap ?? '-')),
                          DataCell(_StokChip(p.statusStok)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StokChip extends StatelessWidget {
  final String status;
  const _StokChip(this.status);
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case 'Tersedia':
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        break;
      case 'Habis':
        bg = AppColors.error.withOpacity(0.15);
        fg = AppColors.error;
        break;
      default:
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
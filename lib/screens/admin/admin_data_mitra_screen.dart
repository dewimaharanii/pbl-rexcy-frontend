import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';

class AdminDataMitraScreen extends StatefulWidget {
  const AdminDataMitraScreen({super.key});
  @override
  State<AdminDataMitraScreen> createState() => _State();
}

class _State extends State<AdminDataMitraScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final list = admin.mitraList
        .where((m) => m.nama.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Cari mitra hilir...',
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
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nama Mitra')),
                        DataColumn(label: Text('No. HP')),
                        DataColumn(label: Text('Alamat')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: list.map((m) {
                        return DataRow(cells: [
                          DataCell(Text(m.id)),
                          DataCell(Text(m.nama)),
                          DataCell(Text(m.noHp)),
                          DataCell(SizedBox(
                              width: 160,
                              child: Text(m.alamat,
                                  overflow: TextOverflow.ellipsis))),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete,
                                color: AppColors.error, size: 20),
                            onPressed: () =>
                                _confirmDelete(context, admin, m.id),
                          )),
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

  void _confirmDelete(BuildContext ctx, AdminProvider admin, String id) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Mitra'),
        content: const Text('Yakin ingin menghapus data mitra ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await admin.hapusMitra(id);
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(result['message'] ?? ''),
                  backgroundColor: result['success'] == true
                      ? AppColors.success
                      : AppColors.error,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
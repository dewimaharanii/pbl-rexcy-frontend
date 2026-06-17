import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produksi_model.dart';
import '../../providers/produksi_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widget.dart';

class EditProduksiScreen extends StatefulWidget {
  final ProduksiModel item;
  const EditProduksiScreen({super.key, required this.item});

  @override
  State<EditProduksiScreen> createState() => _EditProduksiScreenState();
}

class _EditProduksiScreenState extends State<EditProduksiScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _kategori;
  late final TextEditingController _jenisCtrl;
  late final TextEditingController _jumlahCtrl;
  late final TextEditingController _hargaCtrl;
  late final TextEditingController _lokasiCtrl;
  late final TextEditingController _catatanCtrl;

  final _kategoriList = ['Ikan', 'Udang', 'Cumi'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pisah kategori dan jenis dari Nama_Produk (format: "Ikan - Kakap")
    final parts = widget.item.jenisProduk.split(' - ');
    _kategori  = parts.length >= 2 ? parts[0].trim() : 'Ikan';
    final jenis = parts.length >= 2 ? parts.sublist(1).join(' - ').trim() : widget.item.jenisProduk;

    _jenisCtrl  = TextEditingController(text: jenis);
    _jumlahCtrl = TextEditingController(text: widget.item.jumlahKg.toStringAsFixed(0));
    _hargaCtrl  = TextEditingController(text: widget.item.hargaPerKg.toStringAsFixed(0));
    _lokasiCtrl = TextEditingController(text: widget.item.lokasiTangkap);
    _catatanCtrl = TextEditingController(text: widget.item.catatan);
  }

  @override
  void dispose() {
    _jenisCtrl.dispose();
    _jumlahCtrl.dispose();
    _hargaCtrl.dispose();
    _lokasiCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final jumlah = double.tryParse(_jumlahCtrl.text.replaceAll(',', '.')) ?? 0;
    final harga  = double.tryParse(_hargaCtrl.text.replaceAll(',', '.')) ?? 0;

    final result = await context.read<ProduksiProvider>().editProduksi(
      id:            widget.item.id,
      namaProduk:    '$_kategori - ${_jenisCtrl.text.trim()}',
      hargaPerKg:    harga,
      jumlahKg:      jumlah,
      lokasiTangkap: _lokasiCtrl.text.trim(),
      catatan:       _catatanCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data produksi berhasil diperbarui!'),
          backgroundColor: Color(0xFF1D9E75),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memperbarui data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Produksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE4E4E4)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            fieldLabel('Kategori'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.borderInput, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _kategori,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  dropdownColor: AppColors.bgCard,
                  items: _kategoriList
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _kategori = v!;
                    _jenisCtrl.clear();
                  }),
                ),
              ),
            ),
            const SizedBox(height: 14),
            fieldLabel('Jenis $_kategori'),
            TextFormField(
              controller: _jenisCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: fieldDeco(
                _kategori == 'Ikan'
                    ? 'Contoh: Kerapu, Kakap, Tongkol...'
                    : _kategori == 'Udang'
                        ? 'Contoh: Vaname, Windu, Galah...'
                        : 'Contoh: Cumi Putih, Sotong...',
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Jenis wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('Jumlah (kg)'),
                    TextFormField(
                      controller: _jumlahCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                      decoration: fieldDeco('0'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(v) == null) return 'Angka saja';
                        if (double.parse(v) <= 0) return 'Harus > 0';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('Harga jual /kg (Rp)'),
                    TextFormField(
                      controller: _hargaCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                      decoration: fieldDeco('0'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(v) == null) return 'Angka saja';
                        if (double.parse(v) <= 0) return 'Harus > 0';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 14),
            fieldLabel('Lokasi tangkap'),
            TextFormField(
              controller: _lokasiCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: fieldDeco('Masukkan lokasi tangkap'),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            fieldLabel('Catatan (opsional)'),
            TextFormField(
              controller: _catatanCtrl,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: fieldDeco('Tuliskan catatan tambahan...'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _simpan,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined, size: 16),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
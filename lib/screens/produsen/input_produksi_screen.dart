import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/produksi_provider.dart';
import '../../models/produksi_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widget.dart';

class InputProduksiScreen extends StatefulWidget {
  const InputProduksiScreen({super.key});
  @override
  State<InputProduksiScreen> createState() => _InputProduksiScreenState();
}

class _InputProduksiScreenState extends State<InputProduksiScreen> {
  final _formKey     = GlobalKey<FormState>();
  String _kategori   = 'Ikan';
  final _jenisCtrl   = TextEditingController();
  final _tanggalCtrl = TextEditingController();
  final _jumlahCtrl  = TextEditingController();
  final _hargaCtrl   = TextEditingController();
  final _lokasiCtrl  = TextEditingController();
  final _catatanCtrl = TextEditingController();

  final _kategoriList = ['Ikan', 'Udang', 'Cumi'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _tanggalCtrl.text =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    _jenisCtrl.dispose();
    _tanggalCtrl.dispose();
    _jumlahCtrl.dispose();
    _hargaCtrl.dispose();
    _lokasiCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final jumlah = double.tryParse(_jumlahCtrl.text.replaceAll(',', '.')) ?? 0;
    final harga  = double.tryParse(_hargaCtrl.text.replaceAll(',', '.')) ?? 0;

    context.read<ProduksiProvider>().tambah(ProduksiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tanggal: _tanggalCtrl.text,
      kategori: _kategori,
      jenisProduk: _jenisCtrl.text.trim(),
      jumlahKg: jumlah,
      hargaPerKg: harga,
      lokasiTangkap: _lokasiCtrl.text.trim(),
      catatan: _catatanCtrl.text.trim(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data produksi berhasil disimpan!'),
        backgroundColor: Color(0xFF1D9E75),
        duration: Duration(seconds: 2),
      ),
    );

    // ← Cukup pop balik ke ProdusenShell
    // DaftarProduksiScreen sudah ada di tab index 1
    // data baru otomatis muncul karena pakai Provider
    Navigator.pop(context);
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
          'Input Produksi',
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

            // Tanggal
            fieldLabel('Tanggal produksi'),
            TextFormField(
              controller: _tanggalCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: fieldDeco('DD/MM/YYYY'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Kategori dropdown
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
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary),
                  dropdownColor: AppColors.bgCard,
                  items: _kategoriList
                      .map((k) =>
                          DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _kategori = v!;
                    _jenisCtrl.clear();
                  }),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Jenis diketik manual
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
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Jenis wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Jumlah & Harga
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

            // Lokasi
            fieldLabel('Lokasi tangkap'),
            TextFormField(
              controller: _lokasiCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: fieldDeco('Masukkan lokasi tangkap'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Catatan
            fieldLabel('Catatan (opsional)'),
            TextFormField(
              controller: _catatanCtrl,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: fieldDeco('Tuliskan catatan tambahan...'),
            ),
            const SizedBox(height: 24),

            // Tombol simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Simpan Data Produksi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
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
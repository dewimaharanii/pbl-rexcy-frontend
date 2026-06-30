class ProduksiModel {
  final String id;
  final String tanggal;
  final String kategori;
  final String jenisProduk;
  final double jumlahKg;
  final double hargaPerKg;
  final String lokasiTangkap;
  final String catatan;
  final String? gambar;
  final String? gambarUrl;

  ProduksiModel({
    required this.id,
    required this.tanggal,
    required this.kategori,
    required this.jenisProduk,
    required this.jumlahKg,
    required this.hargaPerKg,
    required this.lokasiTangkap,
    required this.catatan,
    this.gambar,
    this.gambarUrl,
  });

  double get totalHarga => jumlahKg * hargaPerKg;

  factory ProduksiModel.fromJson(Map<String, dynamic> e) => ProduksiModel(
        id:            e['Id_Produk']?.toString() ?? e['Id_Produksi']?.toString() ?? '',
        tanggal:       (e['Dibuat_Pada'] ?? '').toString().length >= 10
                           ? e['Dibuat_Pada'].toString().substring(0, 10)
                           : '',
        kategori:      _extractKategori(e['Nama_Produk'] ?? ''),
        jenisProduk:   e['Nama_Produk']    ?? '',
        jumlahKg:      double.tryParse((e['Jumlah_Stok'] ?? 0).toString()) ?? 0,
        hargaPerKg:    double.tryParse((e['Harga_Produksi'] ?? 0).toString()) ?? 0,
        lokasiTangkap: e['Lokasi_Tangkap'] ?? '',
        catatan:       e['Catatan']        ?? '',
        gambar:        e['Gambar'],
        gambarUrl:     e['gambar_url'],
      );

  static String _extractKategori(String namaProduk) {
    if (namaProduk.startsWith('Ikan')) return 'Ikan';
    if (namaProduk.startsWith('Udang')) return 'Udang';
    if (namaProduk.startsWith('Cumi')) return 'Cumi';
    return 'Ikan';
  }

  Map<String, dynamic> toJson() => {
        'Nama_Produk':    jenisProduk,
        'Harga_Produksi': hargaPerKg.toInt(),
        'Jumlah_Stok':    jumlahKg.toInt(),
        'Lokasi_Tangkap': lokasiTangkap,
        'Catatan':        catatan,
      };
}
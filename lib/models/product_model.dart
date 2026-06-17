class ProductModel {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String image;
  final String producerName;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.image,
    required this.producerName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['Id_Produksi'] ?? '',
      name: json['Nama_Produk'] ?? 'Tanpa Nama',
      price: int.tryParse(json['Harga_Produksi'].toString()) ?? 0,
      stock: int.tryParse(json['Jumlah_Stok'].toString()) ?? 0,
      image: json['gambar_url'] ?? '', // Mengambil dari Accessor Laravel
      producerName: json['produsen'] != null ? json['produsen']['Nama_Produsen'] : 'Tidak Diketahui',
    );
  }
}
class UserModel {
  String name;
  String email;
  String phone;
  String birthDate;
  String password;
  String role;

  // ← Field tambahan khusus produsen
  String namaUsaha;
  String jenisUsaha;
  String alamatUsaha;
  String nomorNIB;
  String deskripsiUsaha;
  String statusVerifikasi; // 'pending' | 'disetujui' | 'ditolak'

  UserModel({
    required this.name,
    required this.email,
    this.phone = '',
    this.birthDate = '',
    required this.password,
    this.role = 'mitra',
    this.namaUsaha = '',
    this.jenisUsaha = '',
    this.alamatUsaha = '',
    this.nomorNIB = '',
    this.deskripsiUsaha = '',
    this.statusVerifikasi = 'disetujui', // default disetujui untuk mitra & admin
  });
}
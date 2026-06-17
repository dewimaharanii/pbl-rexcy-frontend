import 'package:flutter/material.dart';
import '../services/mitra_api_service.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class ProdusenModel {
  final String id, nama, noHp, alamat, jenisUsaha;

  // Alias kompatibilitas screen lama
  String get email => '';
  bool   get aktif => true;

  ProdusenModel({
    required this.id,
    required this.nama,
    required this.noHp,
    required this.alamat,
    required this.jenisUsaha,
  });

  factory ProdusenModel.fromJson(Map<String, dynamic> j) => ProdusenModel(
        id:         j['Id_Produsen']   ?? '',
        nama:       j['Nama_Produsen'] ?? '',
        noHp:       j['No_HP']         ?? '',
        alamat:     j['Alamat']        ?? '',
        jenisUsaha: j['Jenis_Usaha']   ?? '',
      );
}

class MitraModel {
  final String id, nama, noHp, alamat;

  // Alias kompatibilitas screen lama
  String get namaUsaha  => nama;
  String get kontak     => noHp;
  String get jenisUsaha => '';

  MitraModel({
    required this.id,
    required this.nama,
    required this.noHp,
    required this.alamat,
  });

  factory MitraModel.fromJson(Map<String, dynamic> j) => MitraModel(
        id:     j['Id_Mitra']   ?? '',
        nama:   j['Nama_Mitra'] ?? '',
        noHp:   j['No_HP']      ?? '',
        alamat: j['Alamat']     ?? '',
      );
}

class ProduksiModel {
  final String id, produsenId, produsenNama, namaProduk;
  final int jumlahStok;
  final double hargaProduksi;
  final String? lokasiTangkap;
  final DateTime dibuatPada;

  // Alias kompatibilitas screen lama
  String   get produk     => namaProduk;
  double   get jumlahKg   => jumlahStok.toDouble();
  double   get hargaPerKg => hargaProduksi;
  double   get totalHarga => jumlahStok * hargaProduksi;
  String   get statusStok => jumlahStok > 0 ? 'Tersedia' : 'Habis';
  DateTime get tanggal    => dibuatPada;

  ProduksiModel({
    required this.id,
    required this.produsenId,
    required this.produsenNama,
    required this.namaProduk,
    required this.jumlahStok,
    required this.hargaProduksi,
    required this.dibuatPada,
    this.lokasiTangkap,
  });

  factory ProduksiModel.fromJson(Map<String, dynamic> j) => ProduksiModel(
        id:            j['Id_Produksi']   ?? '',
        produsenId:    j['Id_Produsen']   ?? '',
        produsenNama:  j['Nama_Produsen'] ?? '',
        namaProduk:    j['Nama_Produk']   ?? '',
        jumlahStok:    j['Jumlah_Stok']  ?? 0,
        hargaProduksi: double.tryParse(j['Harga_Produksi'].toString()) ?? 0,
        lokasiTangkap: j['Lokasi_Tangkap'],
        dibuatPada:    DateTime.tryParse(j['Dibuat_Pada'] ?? '') ?? DateTime.now(),
      );
}

class TransaksiModel {
  final String id, produsenId, produsenNama, mitraId, mitraNama, namaProduk;
  final String statusTransaksi, statusKonfirmasi;
  final double totalHarga;
  final DateTime tanggal;

  // Alias kompatibilitas screen lama
  String  get produk          => namaProduk;
  double  get jumlah          => 0;
  String  get status          => statusTransaksi;
  String? get konfirmasiMitra => statusKonfirmasi == 'Sudah_Diterima' ? 'sudah_sampai' : null;
  String? get konfirmasiAdmin => statusTransaksi == 'Selesai'
      ? 'dikonfirmasi'
      : statusTransaksi == 'Dibatalkan'
          ? 'ditolak'
          : null;

  TransaksiModel({
    required this.id,
    required this.produsenId,
    required this.produsenNama,
    required this.mitraId,
    required this.mitraNama,
    required this.namaProduk,
    required this.statusTransaksi,
    required this.statusKonfirmasi,
    required this.totalHarga,
    required this.tanggal,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> j) => TransaksiModel(
        id:               j['Id_Transaksi']    ?? '',
        produsenId:       j['Id_Produsen']      ?? '',
        produsenNama:     j['Nama_Produsen']    ?? '',
        mitraId:          j['Id_Mitra']         ?? '',
        mitraNama:        j['Nama_Mitra']       ?? '',
        namaProduk:       j['Nama_Produk']      ?? '',
        statusTransaksi:  j['Status_Transaksi'] ?? '',
        statusKonfirmasi: j['Status_Konfirmasi'] ?? '',
        totalHarga:       double.tryParse(j['Total_Harga'].toString()) ?? 0,
        tanggal:          DateTime.tryParse(j['Tanggal_Transaksi'] ?? '') ?? DateTime.now(),
      );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

class AdminProvider extends ChangeNotifier {
  List<ProdusenModel>  _produsenList  = [];
  List<MitraModel>     _mitraList     = [];
  List<ProduksiModel>  _produksiList  = [];
  List<TransaksiModel> _transaksiList = [];

  bool    _isLoading = false;
  String? _error;

  int    _totalProdusen     = 0;
  int    _totalMitra        = 0;
  int    _totalProduksi     = 0;
  int    _totalTransaksi    = 0;
  int    _transaksiMenunggu = 0;
  double _totalPendapatan   = 0;

  List<ProdusenModel>  get produsenList      => List.unmodifiable(_produsenList);
  List<MitraModel>     get mitraList         => List.unmodifiable(_mitraList);
  List<ProduksiModel>  get produksiList      => List.unmodifiable(_produksiList);
  List<TransaksiModel> get transaksiList     => List.unmodifiable(_transaksiList);
  bool                 get isLoading         => _isLoading;
  String?              get error             => _error;
  int                  get totalProdusen     => _totalProdusen;
  int                  get totalMitra        => _totalMitra;
  int                  get totalProduksi     => _totalProduksi;
  int                  get totalTransaksi    => _totalTransaksi;
  int                  get transaksiMenunggu => _transaksiMenunggu;
  double               get totalPendapatan   => _totalPendapatan;

  // ── Load semua data ───────────────────────────────────────

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      loadDashboard(),
      loadProdusen(),
      loadMitra(),
      loadProduksi(),
      loadTransaksi(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // ── Dashboard ─────────────────────────────────────────────

  Future<void> loadDashboard() async {
    final result = await MitraApiService.adminGetDashboard();
    if (result['success'] == true) {
      final d = result['data'];
      _totalProdusen     = d['total_produsen']    ?? 0;
      _totalMitra        = d['total_mitra']        ?? 0;
      _totalProduksi     = d['total_produksi']     ?? 0;
      _totalTransaksi    = d['total_transaksi']    ?? 0;
      _transaksiMenunggu = d['transaksi_menunggu'] ?? 0;
      _totalPendapatan   = double.tryParse(d['total_pendapatan'].toString()) ?? 0;
      notifyListeners();
    }
  }

  // ── Produsen ──────────────────────────────────────────────

  Future<void> loadProdusen() async {
    final result = await MitraApiService.adminGetProdusen();
    if (result['success'] == true) {
      _produsenList = (result['data'] as List)
          .map((e) => ProdusenModel.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> tambahProdusen({
    required String nama,
    required String username,
    required String password,
    required String noHp,
    required String alamat,
    required String jenisUsaha,
  }) async {
    final result = await MitraApiService.adminTambahProdusen(
      nama: nama, username: username, password: password,
      noHp: noHp, alamat: alamat, jenisUsaha: jenisUsaha,
    );
    if (result['success'] == true) await loadProdusen();
    return result;
  }

  Future<Map<String, dynamic>> updateProdusen({
    required String id,
    required String nama,
    required String noHp,
    required String alamat,
    required String jenisUsaha,
    String? password,
  }) async {
    final result = await MitraApiService.adminUpdateProdusen(
      id: id, nama: nama, noHp: noHp,
      alamat: alamat, jenisUsaha: jenisUsaha, password: password,
    );
    if (result['success'] == true) await loadProdusen();
    return result;
  }

  Future<Map<String, dynamic>> hapusProdusen(String id) async {
    final result = await MitraApiService.adminHapusProdusen(id);
    if (result['success'] == true) {
      _produsenList.removeWhere((p) => p.id == id);
      notifyListeners();
    }
    return result;
  }

  // Alias kompatibilitas screen lama
  void toggleStatusProdusen(String id) => notifyListeners();

  // ── Mitra ─────────────────────────────────────────────────

  Future<void> loadMitra() async {
    final result = await MitraApiService.adminGetMitra();
    if (result['success'] == true) {
      _mitraList = (result['data'] as List)
          .map((e) => MitraModel.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> hapusMitra(String id) async {
    final result = await MitraApiService.adminHapusMitra(id);
    if (result['success'] == true) {
      _mitraList.removeWhere((m) => m.id == id);
      notifyListeners();
    }
    return result;
  }

  // Alias kompatibilitas screen lama
  void tambahMitra(MitraModel m) => notifyListeners();
  void updateMitra(MitraModel m) => notifyListeners();

  // ── Produksi ──────────────────────────────────────────────

  Future<void> loadProduksi() async {
    final result = await MitraApiService.adminGetProduksi();
    if (result['success'] == true) {
      _produksiList = (result['data'] as List)
          .map((e) => ProduksiModel.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  // Alias kompatibilitas screen lama
  void tambahProduksi(ProduksiModel p) => notifyListeners();
  void hapusProduksi(String id)        => notifyListeners();

  // ── Transaksi ─────────────────────────────────────────────

  Future<void> loadTransaksi() async {
    final result = await MitraApiService.adminGetTransaksi();
    if (result['success'] == true) {
      _transaksiList = (result['data'] as List)
          .map((e) => TransaksiModel.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  // Alias kompatibilitas screen lama
  void konfirmasiPembayaran(String id, bool dikonfirmasi) => notifyListeners();
}
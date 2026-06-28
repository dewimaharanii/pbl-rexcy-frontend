import 'package:flutter/material.dart';
import '../services/mitra_api_service.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class ProdusenModel {
  final String id, nama, noHp, alamat, jenisUsaha;

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

  factory ProduksiModel.fromJson(Map<String, dynamic> j) {
    // ✅ FIX: Produsen bisa nested (from with('produsen')) atau flat
    final produsenData = j['produsen'];
    final produsenNama = produsenData != null
        ? (produsenData['Nama_Produsen'] ?? '')
        : (j['Nama_Produsen'] ?? '');
    final produsenId = produsenData != null
        ? (produsenData['Id_Produsen'] ?? '')
        : (j['Id_Produsen'] ?? '');

    return ProduksiModel(
      id:            j['Id_Produksi']   ?? '',
      produsenId:    produsenId,
      produsenNama:  produsenNama,
      namaProduk:    j['Nama_Produk']   ?? '',
      jumlahStok:    j['Jumlah_Stok']  ?? 0,
      hargaProduksi: double.tryParse(j['Harga_Produksi'].toString()) ?? 0,
      lokasiTangkap: j['Lokasi_Tangkap'],
      dibuatPada:    DateTime.tryParse(j['Dibuat_Pada'] ?? '') ?? DateTime.now(),
    );
  }
}

class TransaksiModel {
  final String id, produsenNama, mitraNama, produk;
  final double jumlah, totalHarga;
  final String status;
  final DateTime tanggal;
  final String? konfirmasiMitra, konfirmasiAdmin;
  final String jenis; // 'pembelian' atau 'permintaan'

  TransaksiModel({
    required this.id,
    required this.produsenNama,
    required this.mitraNama,
    required this.produk,
    required this.jumlah,
    required this.totalHarga,
    required this.status,
    required this.tanggal,
    required this.jenis,
    this.konfirmasiMitra,
    this.konfirmasiAdmin,
  });

  // ✅ FIX: Baca field sesuai response API baru dari AdminController
  factory TransaksiModel.fromJson(Map<String, dynamic> j) => TransaksiModel(
        id:              j['id']             ?? j['Id_Transaksi'] ?? j['id_permintaan'] ?? '',
        produsenNama:    j['nama_produsen']  ?? j['Nama_Produsen'] ?? '-',
        mitraNama:       j['nama_mitra']     ?? j['Nama_Mitra']    ?? '-',
        produk:          j['nama_produk']    ?? j['Nama_Produk']   ?? '-',
        jumlah:          double.tryParse((j['jumlah'] ?? j['Jumlah'] ?? 0).toString()) ?? 0,
        totalHarga:      double.tryParse((j['total_harga'] ?? j['Total_Harga'] ?? 0).toString()) ?? 0,
        status:          j['status']         ?? j['Status']        ?? '-',
        tanggal:         DateTime.tryParse((j['tanggal'] ?? j['Tanggal_Transaksi'] ?? j['tanggal_permintaan'] ?? '').toString()) ?? DateTime.now(),
        jenis:           j['jenis']          ?? 'pembelian',
        konfirmasiMitra: j['konfirmasi_mitra'],
        konfirmasiAdmin: j['konfirmasi_admin'],
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

  // ✅ Tambah: transaksi terbaru dari dashboard
  List<TransaksiModel> _transaksiTerbaru = [];

  List<ProdusenModel>  get produsenList      => List.unmodifiable(_produsenList);
  List<MitraModel>     get mitraList         => List.unmodifiable(_mitraList);
  List<ProduksiModel>  get produksiList      => List.unmodifiable(_produksiList);
  List<TransaksiModel> get transaksiList     => List.unmodifiable(_transaksiList);
  List<TransaksiModel> get transaksiTerbaru  => List.unmodifiable(_transaksiTerbaru);
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

      // ✅ Load transaksi terbaru dari dashboard response
      if (d['transaksi_terbaru'] != null) {
        _transaksiTerbaru = (d['transaksi_terbaru'] as List)
            .map((e) => TransaksiModel.fromJson(e))
            .toList();
      }

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

  void konfirmasiPembayaran(String id, bool dikonfirmasi) => notifyListeners();
}
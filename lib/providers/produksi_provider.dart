import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/produksi_model.dart';
import '../services/mitra_api_service.dart';

class ProduksiProvider extends ChangeNotifier {
  List<ProduksiModel> _list = [];
  bool _isLoading           = false;
  String? _errorMsg;

  List<ProduksiModel> get list      => List.unmodifiable(_list);
  bool get isLoading                => _isLoading;
  String? get errorMsg              => _errorMsg;

  Future<void> loadProduksi() async {
    _isLoading = true;
    _errorMsg  = null;
    notifyListeners();

    try {
      final result = await MitraApiService.getProdusenProduksi();
      if (result['success'] == true) {
        final List data = result['data'] ?? [];
        _list = data.map((e) => ProduksiModel.fromJson(e)).toList();
      } else {
        _errorMsg = result['message'] ?? 'Gagal memuat data';
      }
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> tambahProduksi({
    required String namaProduk,
    required double hargaPerKg,
    required double jumlahKg,
    required String lokasiTangkap,
    String? catatan,
    Uint8List? gambarBytes,
    String? gambarNama,
  }) async {
    try {
      final result = await MitraApiService.tambahProduksi(
        namaProduk:    namaProduk,
        hargaProduksi: hargaPerKg.toInt(),
        stok:          jumlahKg.toInt(),
        lokasiTangkap: lokasiTangkap,
        catatan:       catatan,
        gambarBytes:   gambarBytes,
        gambarNama:    gambarNama,
      );
      if (result['success'] == true) await loadProduksi();
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  

  Future<Map<String, dynamic>> editProduksi({
    required String id,
    required String namaProduk,
    required double hargaPerKg,
    required double jumlahKg,
    required String lokasiTangkap,
    String? catatan,
    Uint8List? gambarBytes,
    String? gambarNama,
  }) async {
    try {
      final result = await MitraApiService.updateProduksi(
        id:            id,
        namaProduk:    namaProduk,
        hargaProduksi: hargaPerKg.toInt(),
        stok:          jumlahKg.toInt(),
        lokasiTangkap: lokasiTangkap,
        catatan:       catatan,
        gambarBytes:   gambarBytes,
        gambarNama:    gambarNama,
      );
      print('== EDIT RESULT: $result');
      print('== Id yang dikirim: $id');
      if (result['success'] == true) await loadProduksi();
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> hapus(String id) async {
    try {
      final result = await MitraApiService.hapusProduksi(id);
      if (result['success'] == true) {
        _list.removeWhere((e) => e.id == id);
        notifyListeners();
      }
    } catch (_) {
      _list.removeWhere((e) => e.id == id);
      notifyListeners();
    }
  }
}
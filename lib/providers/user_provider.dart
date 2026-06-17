// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/mitra_api_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user      => _user;
  bool get isLoggedIn      => _user != null;
  String get role          => _user?.role ?? 'mitra';
  bool get isLoading       => _isLoading;

  // Dipanggil setelah login berhasil
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // Update profile → kirim ke API → update state lokal
  Future<Map<String, dynamic>> updateProfileApi({
    required String nama,
    required String noHp,
    String? passwordBaru,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await MitraApiService.updateProfile(
        nama:         nama,
        noHp:         noHp,
        passwordBaru: passwordBaru,
      );

      if (result['success'] == true) {
        final userData = result['user'];

        _user = UserModel(
          name:     userData?['Nama_Mitra'] ?? nama,
          email:    userData?['Username']   ?? _user?.email ?? '',
          phone:    userData?['No_HP']      ?? noHp,
          role:     _user?.role             ?? 'mitra',
          password: '',
        );
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
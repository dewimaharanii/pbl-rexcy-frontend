import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class MitraApiService {
  static const String baseUrl      = 'http://127.0.0.1:8000/api/produsen';
  static const String mitraBaseUrl = 'http://127.0.0.1:8000/api/mitra';
  static const String adminBaseUrl = 'http://127.0.0.1:8000/api/admin';

  // ── TOKEN PRODUSEN ─────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('produsen_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('produsen_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('produsen_token');
  }
static Future<Map<String, String>> _adminAuthHeaders() async {
  final token = await getAdminToken();
  return {
    'Accept':        'application/json',
    'Content-Type':  'application/json',
    'Authorization': 'Bearer $token',
  };
}

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Accept':        'application/json',
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── TOKEN MITRA ────────────────────────────────────────────
  static Future<void> saveMitraToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mitra_token', token);
  }

  static Future<String?> getMitraToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mitra_token');
  }

  static Future<void> clearMitraToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mitra_token');
  }

  static Future<Map<String, String>> _mitraAuthHeaders() async {
    final token = await getMitraToken();
    return {
      'Accept':        'application/json',
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── TOKEN ADMIN ────────────────────────────────────────────
  static Future<void> saveAdminToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
  }

  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_token');
  }

  static Future<void> clearAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
  }


  // ══════════════════════════════════════════════════════════
  //  ADMIN
  // ══════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> loginAdmin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$adminBaseUrl/login'),
        headers: {
          'Accept':       'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Username':   username,
          'Kata_Sandi': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        await saveAdminToken(data['token']);
      }
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'token':   data['token'],
        'data':    data['user'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> logoutAdmin() async {
    try {
      final token = await getAdminToken();
      if (token != null) {
        await http.post(
          Uri.parse('$adminBaseUrl/logout'),
          headers: {
            'Accept':        'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (_) {}
    await clearAdminToken();
  }

  // ══════════════════════════════════════════════════════════
  //  PRODUSEN
  // ══════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> loginProdusen({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept':       'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Username':   username,
          'Kata_Sandi': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        await saveToken(data['token']);
      }
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'token':   data['token'],
        'data':    data['user'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> logoutProdusen() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept':        'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (_) {}
    await clearToken();
  }

// ══════════════════════════════════════════════════════════
//  ADMIN - API CALLS
// ══════════════════════════════════════════════════════════

static Future<Map<String, dynamic>> adminGetDashboard() async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.get(
      Uri.parse('$adminBaseUrl/dashboard'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return {'success': data['success'] ?? false, 'data': data['data']};
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> adminGetProdusen() async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.get(
      Uri.parse('$adminBaseUrl/produsen'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return {'success': data['success'] ?? false, 'data': data['data'] ?? []};
  } catch (e) {
    return {'success': false, 'data': [], 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> adminTambahProdusen({
  required String nama,
  required String username,
  required String password,
  required String noHp,
  required String alamat,
  required String jenisUsaha,
}) async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.post(
      Uri.parse('$adminBaseUrl/produsen'),
      headers: headers,
      body: jsonEncode({
        'Nama_Produsen': nama,
        'Username':      username,
        'Kata_Sandi':    password,
        'No_HP':         noHp,
        'Alamat':        alamat,
        'Jenis_Usaha':   jenisUsaha,
      }),
    );
    final data = jsonDecode(response.body);
    return {
      'success': data['success'] ?? false,
      'message': data['message'] ?? '',
      'data':    data['data'],
    };
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> getProdusenProduksi() async {
  try {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/produk'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    print('=== RAW PRODUKSI: ${data['data']}'); // tambah ini
    return {
      'success': data['success'] ?? false,
      'data':    data['data'] ?? [],
    };
  } catch (e) {
    return {'success': false, 'data': [], 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> adminUpdateProdusen({
  required String id,
  required String nama,
  required String noHp,
  required String alamat,
  required String jenisUsaha,
  String? password,
}) async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.put(
      Uri.parse('$adminBaseUrl/produsen/$id'),
      headers: headers,
      body: jsonEncode({
        'Nama_Produsen': nama,
        'No_HP':         noHp,
        'Alamat':        alamat,
        'Jenis_Usaha':   jenisUsaha,
        if (password != null && password.isNotEmpty) 'Kata_Sandi': password,
      }),
    );
    final data = jsonDecode(response.body);
    return {
      'success': data['success'] ?? false,
      'message': data['message'] ?? '',
    };
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> adminHapusProdusen(String id) async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.delete(
      Uri.parse('$adminBaseUrl/produsen/$id'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return {'success': data['success'] ?? false, 'message': data['message'] ?? ''};
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> adminGetMitra() async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.get(
      Uri.parse('$adminBaseUrl/mitra'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return {'success': data['success'] ?? false, 'data': data['data'] ?? []};
  } catch (e) {
    return {'success': false, 'data': [], 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> adminHapusMitra(String id) async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.delete(
      Uri.parse('$adminBaseUrl/mitra/$id'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return {'success': data['success'] ?? false, 'message': data['message'] ?? ''};
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> adminGetProduksi() async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.get(
      Uri.parse('$adminBaseUrl/produksi'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return {'success': data['success'] ?? false, 'data': data['data'] ?? []};
  } catch (e) {
    return {'success': false, 'data': [], 'message': e.toString()};
  }
}

static Future<Map<String, dynamic>> adminGetTransaksi() async {
  try {
    final headers = await _adminAuthHeaders();
    final response = await http.get(
      Uri.parse('$adminBaseUrl/transaksi'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return {'success': data['success'] ?? false, 'data': data['data'] ?? []};
  } catch (e) {
    return {'success': false, 'data': [], 'message': e.toString()};
  }
}

  static Future<Map<String, dynamic>> tambahProduksi({
  required String namaProduk,
  required int hargaProduksi,
  required int stok,
  String? lokasiTangkap,
  String? catatan,
  Uint8List? gambarBytes,
  String? gambarNama,
}) async {
  try {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/produk');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept']        = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['Nama_Produk']    = namaProduk
      ..fields['Jumlah_Stok']    = stok.toString()
      ..fields['Harga_Produksi'] = hargaProduksi.toString()
      ..fields['Lokasi_Tangkap'] = lokasiTangkap ?? ''
      ..fields['Catatan']        = catatan ?? '';

    if (gambarBytes != null && gambarNama != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'Gambar',
        gambarBytes,
        filename: gambarNama,
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(response.body);

    return {
      'success': data['success'] ?? false,
      'message': data['message'] ?? '',
      'data':    data['data'],
    };
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}

  static Future<Map<String, dynamic>> updateProduksi({
    required String id,
    required String namaProduk,
    required int hargaProduksi,
    required int stok,
    String? lokasiTangkap,
    String? catatan,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/produk/$id'),
        headers: headers,
        body: jsonEncode({
          'Nama_Produk':    namaProduk,
          'Jumlah_Stok':    stok,
          'Harga_Produksi': hargaProduksi,
          'Lokasi_Tangkap': lokasiTangkap ?? '',
          'Catatan':        catatan ?? '',
        }),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'data':    data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> hapusProduksi(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/produk/$id'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getProdusenPermintaan() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/permintaan'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'data':    data['data'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'data': [], 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> prosesPermintaan(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/permintaan/$id/proses'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> tolakPermintaan(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/permintaan/$id/tolak'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getProdusenTransaksi() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/transaksi'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'data':    data['data'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'data': [], 'message': e.toString()};
    }
  }

  // ══════════════════════════════════════════════════════════
  //  MITRA
  // ══════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> loginMitra({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$mitraBaseUrl/login'),
        headers: {
          'Accept':       'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Username':   username,
          'Kata_Sandi': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        await saveMitraToken(data['token']);
      }
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'token':   data['token'],
        'data':    data['user'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> logoutMitra() async {
    try {
      final token = await getMitraToken();
      if (token != null) {
        await http.post(
          Uri.parse('$mitraBaseUrl/logout'),
          headers: {
            'Accept':        'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (_) {}
    await clearMitraToken();
  }

  static Future<Map<String, dynamic>> registerMitra({
    required String nama,
    required String email,
    required String password,
    String? noHp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$mitraBaseUrl/register'),
        headers: {
          'Accept':       'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Nama_Mitra': nama,
          'Username':   email,
          'Kata_Sandi': password,
          'No_HP':      noHp ?? '',
        }),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? data['status'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String noHp,
    String? passwordBaru,
  }) async {
    try {
      final headers = await _mitraAuthHeaders();
      final response = await http.put(
        Uri.parse('$mitraBaseUrl/profile'),
        headers: headers,
        body: jsonEncode({
          'Nama_Mitra': nama,
          'No_HP':      noHp,
          if (passwordBaru != null && passwordBaru.isNotEmpty)
            'Kata_Sandi_Baru': passwordBaru,
        }),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'user':    data['user'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getProduk() async {
    try {
      final headers = await _mitraAuthHeaders();
      final response = await http.get(
        Uri.parse('$mitraBaseUrl/produk'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'data':    data['data'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'data': [], 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getTransaksi() async {
    try {
      final headers = await _mitraAuthHeaders();
      final response = await http.get(
        Uri.parse('$mitraBaseUrl/permintaan'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'data':    data['data'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'data': [], 'message': e.toString()};
    }
  }

   static Future<Map<String, dynamic>> buatTransaksi({
    required String idProduksi,
    required int jumlah,
    int? totalHarga,
    String? catatan,
  }) async {
    try {
      final headers = await _mitraAuthHeaders();
      final response = await http.post(
        // PENTING: Pastikan URL ini sesuai dengan route di web.php Laravel kamu
        // Jika route kamu untuk buat permintaan adalah /permintaan, ganti URL di bawah
        Uri.parse('$mitraBaseUrl/permintaan'), 
        headers: headers,
        body: jsonEncode({
          'Id_Produksi':    idProduksi, 
          'Jumlah_Diminta': jumlah,     
          'Catatan':        catatan ?? '',
        }),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'data':    data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> konfirmasiPesananSelesai(String id) async {
    try {
      final headers = await _mitraAuthHeaders();
      final response = await http.post(
        Uri.parse('$mitraBaseUrl/permintaan/$id/selesai'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
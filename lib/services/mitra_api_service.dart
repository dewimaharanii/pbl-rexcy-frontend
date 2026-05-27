import 'dart:convert';
import 'package:http/http.dart' as http;

class MitraApiService {

  static const String baseUrl = 'http://127.0.0.1:8000/api/mitra';

  static Future<Map<String, dynamic>> registerMitra({
    required String nama,
    required String email,
    required String noHp,
    required String password,
  }) async {

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },

        body: jsonEncode({
          'nama_mitra': nama,
          'username': email,
          'password': password,
          'password_confirmation': password,
          'no_hp': noHp,
          'alamat': '-',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        return {
          'status': data['status'],
          'message': data['message'],
          'data': data['data'],
        };

      } else {

        return {
          'status': false,
          'message': data['message'] ?? 'Register gagal',
        };
      }

    } catch (e) {

      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }
}
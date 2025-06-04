// auth_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
// import 'dart:convert';

class AuthRepository {
  final String baseUrl;

  AuthRepository({required this.baseUrl});

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {
        // 'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to login');
    }
  }

  Future<void> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/sign_up'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to signup');
    }
  }
}

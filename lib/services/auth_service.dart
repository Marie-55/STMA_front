import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  final _storage = const FlutterSecureStorage();

  Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getUserId() async {
    final token = await getToken();
    if (token != null) {
      try {
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return decodedToken['user_id']?.toString();
      } catch (e) {
        print('Error decoding token: $e');
        return null;
      }
    }
    return null;
  }
} 
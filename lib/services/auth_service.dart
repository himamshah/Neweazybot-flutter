import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';

class AuthService {
  static const String baseUrl = 'https://futures.eazybot.com';
  static const Duration timeout = Duration(seconds: 30);
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static Future<Map<String, String>> get _headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(timeout);


      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);
        
        // Save token and user data
        await _saveToken(loginResponse.token);
        await _saveUser(loginResponse.user);
        
        return loginResponse;
      } else {
        throw _handleError(response);
      }
    } catch (e, stackTrace) {
      throw _handleException(e);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<void> clearInvalidToken() async {
    await logout();
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token;
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userData = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userData);
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role,
    }));
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Exception _handleError(http.Response response) {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Exception(data['message'] ?? 'Login failed with status ${response.statusCode}');
    } catch (e) {
      return Exception('Login failed with status ${response.statusCode}');
    }
  }

  static Exception _handleException(dynamic exception) {
    if (exception is Exception) {
      return exception;
    }
    return Exception('An unexpected error occurred: $exception');
  }
}

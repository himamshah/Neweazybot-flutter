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
    print('AUTH DEBUG: Retrieved token: ${token != null ? token.substring(0, math.min(20, token.length)) + "..." : "null"}');
    print('AUTH DEBUG: Token length: ${token?.length ?? 0}');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<LoginResponse> login(String email, String password) async {
    try {
      print('AUTH DEBUG: Starting login for email: $email');
      final request = LoginRequest(email: email, password: password);
      
      print('AUTH DEBUG: Login request URL: $baseUrl/api/login');
      print('AUTH DEBUG: Login request body: ${request.toJson()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(timeout);

      print('AUTH DEBUG: Login response status: ${response.statusCode}');
      print('AUTH DEBUG: Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('AUTH DEBUG: Login response data: $data');
        final loginResponse = LoginResponse.fromJson(data);
        
        print('AUTH DEBUG: Login successful, token: ${loginResponse.token.substring(0, math.min(20, loginResponse.token.length))}...');
        
        // Save token and user data
        await _saveToken(loginResponse.token);
        await _saveUser(loginResponse.user);
        
        return loginResponse;
      } else {
        print('AUTH ERROR: Login failed with status ${response.statusCode}');
        throw _handleError(response);
      }
    } catch (e, stackTrace) {
      print('AUTH ERROR: Login exception: $e');
      print('AUTH ERROR: Stack trace: $stackTrace');
      throw _handleException(e);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<void> clearInvalidToken() async {
    print('AUTH DEBUG: Clearing invalid token');
    await logout();
  }

  static Future<void> clearAllData() async {
    print('AUTH DEBUG: Clearing all authentication data');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    print('AUTH DEBUG: All data cleared successfully');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('AUTH DEBUG: Retrieved token from storage: ${token != null ? token.substring(0, math.min(20, token.length)) + "..." : "null"}');
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
    print('AUTH DEBUG: Saving token: ${token.substring(0, math.min(20, token.length))}...');
    await prefs.setString(_tokenKey, token);
    print('AUTH DEBUG: Token saved successfully');
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

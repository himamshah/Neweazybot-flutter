import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bot.dart';
import '../models/trade.dart';
import '../models/trade_new.dart';
import '../models/create_bot.dart';
import '../models/profile.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://futures.eazybot.com';
  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, String>> get _headers async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<BotsListResponse> getBots({
    String status = 'all',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final headers = await _headers;
      final queryParams = {
        'status': status,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/bots').replace(queryParameters: queryParams);
      
      print('API DEBUG: Request URL: $uri');
      print('API DEBUG: Headers: $headers');
      
      final response = await http.get(uri, headers: headers).timeout(timeout);
      
      print('API DEBUG: Response status: ${response.statusCode}');
      print('API DEBUG: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('API DEBUG: Parsed JSON data: $data');
        return BotsListResponse.fromJson(data);
      } else if (response.statusCode == 401 || response.statusCode == 500) {
        // Handle authentication and server errors
        final body = json.decode(response.body);
        if (body['message'] == 'Unauthenticated' || response.statusCode == 401) {
          print('API ERROR: Authentication failed, clearing token');
          await AuthService.logout();
          throw Exception('Session expired. Please login again.');
        }
        // Handle specific server error with 'all' parameter
        if (body['message'] == 'Unsupported operand types: float - array') {
          print('API ERROR: Server error with status=all, retrying with status=running');
          // Retry with 'running' status instead
          final retryParams = <String, dynamic>{};
          queryParams.forEach((key, value) {
            retryParams[key] = key == 'status' ? 'running' : value;
          });
          final retryUri = Uri.parse('$baseUrl/api/bots').replace(queryParameters: retryParams);
          final retryResponse = await http.get(retryUri, headers: headers).timeout(timeout);
          if (retryResponse.statusCode == 200) {
            final retryData = json.decode(retryResponse.body) as Map<String, dynamic>;
            return BotsListResponse.fromJson(retryData);
          }
        }
        print('API ERROR: Status code ${response.statusCode}');
        throw _handleError(response);
      } else {
        print('API ERROR: Status code ${response.statusCode}');
        throw _handleError(response);
      }
    } catch (e, stackTrace) {
      print('API ERROR: Exception in getBots: $e');
      print('API ERROR: Stack trace: $stackTrace');
      throw _handleException(e);
    }
  }

  
  static Future<CreateBotResponse> createBot(CreateBotRequest request) async {
    try {
      final headers = await _headers;
      final uri = Uri.parse('$baseUrl/api/create-bot');
      
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(request.toJson()),
      ).timeout(timeout);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return CreateBotResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Bot configuration is invalid.');
      } else if (response.statusCode == 409) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'A bot is already running for this trading pair.');
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  static Exception _handleError(http.Response response) {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Exception(data['message'] ?? 'Request failed with status ${response.statusCode}');
    } catch (e) {
      return Exception('Request failed with status ${response.statusCode}');
    }
  }

  static Future<BotDetailResponse> getBotDetail(
    int botId, {
    String tradeStatus = 'all',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _headers;
      final queryParams = {
        'trade_status': tradeStatus,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/bots/$botId').replace(queryParameters: queryParams);
      
      print('API DEBUG: Bot Detail Request URL: $uri');
      print('API DEBUG: Headers: $headers');
      
      final response = await http.get(uri, headers: headers).timeout(timeout);
      
      print('API DEBUG: Bot Detail Response status: ${response.statusCode}');
      print('API DEBUG: Bot Detail Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('API DEBUG: Parsed Bot Detail JSON data: $data');
        return BotDetailResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Bot with ID $botId not found or does not belong to this account.');
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  static Future<TradesResponse> getTrades({
    int page = 1,
  }) async {
    try {
      final headers = await _headers;
      final uri = Uri.parse('https://futures.eazybot.com/api/trades?page=$page');
      
      print('API DEBUG: Trades Request URL: $uri');
      print('API DEBUG: Headers: $headers');
      
      final response = await http.get(uri, headers: headers).timeout(timeout);
      
      print('API DEBUG: Trades Response status: ${response.statusCode}');
      print('API DEBUG: Trades Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('API DEBUG: Parsed Trades JSON data: $data');
        return TradesResponse.fromJson(data);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  static Exception _handleException(dynamic exception) {
    if (exception is Exception) {
      return exception;
    }
    return Exception('An unexpected error occurred: $exception');
  }

  static Future<ProfileResponse> getProfile() async {
    try {
      final headers = await _headers;
      final uri = Uri.parse('$baseUrl/api/profile');
      
      print('API DEBUG: Profile Request URL: $uri');
      
      final response = await http.get(uri, headers: headers).timeout(timeout);
      
      print('API DEBUG: Profile Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('API DEBUG: Profile Parsed JSON data: $data');
        return ProfileResponse.fromJson(data);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await _headers;
      final uri = Uri.parse('$baseUrl/api/change-password');
      
      print('API DEBUG: Change Password Request URL: $uri');
      
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      ).timeout(timeout);
      
      print('API DEBUG: Change Password Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('API DEBUG: Change Password Parsed JSON data: $data');
        return data;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
}

class BotsListResponse {
  final Meta meta;
  final List<Bot> bots;

  BotsListResponse({
    required this.meta,
    required this.bots,
  });

  factory BotsListResponse.fromJson(Map<String, dynamic> json) {
    return BotsListResponse(
      meta: Meta.fromJson(json['meta']),
      bots: (json['bots'] as List).map((bot) => Bot.fromJson(bot)).toList(),
    );
  }
}

class Meta {
  final int? total;
  final int? limit;
  final int? offset;
  final bool? hasMore;
  final int? allCount;
  final int? runningCount;
  final int? pausedCount;
  final int? closedCount;

  Meta({
    this.total,
    this.limit,
    this.offset,
    this.hasMore,
    this.allCount,
    this.runningCount,
    this.pausedCount,
    this.closedCount,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      offset: json['offset'] as int? ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
      allCount: json['all_count'] as int? ?? 0,
      runningCount: json['running_count'] as int? ?? 0,
      pausedCount: json['paused_count'] as int? ?? 0,
      closedCount: json['closed_count'] as int? ?? 0,
    );
  }
}

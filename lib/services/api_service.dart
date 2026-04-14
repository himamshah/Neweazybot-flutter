import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bot.dart';
import '../models/trade.dart';
import '../models/create_bot.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, String>> get _headers async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<BotsListResponse> getBots({
    String status = 'all',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _headers;
      final queryParams = {
        'status': status,
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/bots').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return BotsListResponse.fromJson(data);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
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
      
      final response = await http.get(uri, headers: headers).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
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

  static Future<CreateBotResponse> createBot(CreateBotRequest request) async {
    try {
      final headers = await _headers;
      final uri = Uri.parse('$baseUrl/api/bots');
      
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

  static Exception _handleException(dynamic exception) {
    if (exception is Exception) {
      return exception;
    }
    return Exception('An unexpected error occurred: $exception');
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
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  Meta({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasMore: json['has_more'] as bool,
    );
  }
}

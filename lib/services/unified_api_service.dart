import 'dart:async';
import 'api_service.dart';
import 'mock_api_service.dart';
import '../models/bot.dart';
import '../models/trade.dart';
import '../models/trade_new.dart';
import '../models/create_bot.dart';
import '../models/profile.dart';

class UnifiedApiService {
  static bool _useMockData = false; // Set to true for mock data, false for real API

  static set useMockData(bool useMock) {
    _useMockData = useMock;
  }

  static bool get useMockData => _useMockData;
  
  // Performance optimization: API response caching
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  
  static String _generateCacheKey(String method, Map<String, dynamic> params) {
    final paramString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$method?$paramString';
  }
  
  static T? _getCachedResponse<T>(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
      return _cache[cacheKey] as T?;
    }
    _cache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    return null;
  }
  
  static void _cacheResponse(String cacheKey, dynamic response) {
    _cache[cacheKey] = response;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }
  
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  static Future<BotsListResponse> getBots({
    String status = 'all',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int limit = 20,
    int offset = 0,
  }) async {
    final params = {
      'status': status,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'limit': limit,
      'offset': offset,
    };
    final cacheKey = _generateCacheKey('getBots', params);
    
    // Check cache first
    final cachedResponse = _getCachedResponse<BotsListResponse>(cacheKey);
    if (cachedResponse != null) {
      return cachedResponse;
    }
    
    // Fetch from API
    BotsListResponse response;
    if (_useMockData) {
      response = await MockApiService.getBots(
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      );
    } else {
      response = await ApiService.getBots(
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      );
    }
    
    // Cache the response
    _cacheResponse(cacheKey, response);
    return response;
  }

  static Future<BotDetailResponse> getBotDetail(
    int botId, {
    String tradeStatus = 'all',
    int limit = 20,
    int offset = 0,
  }) async {
    final params = {
      'botId': botId,
      'tradeStatus': tradeStatus,
      'limit': limit,
      'offset': offset,
    };
    final cacheKey = _generateCacheKey('getBotDetail', params);
    
    // Check cache first
    final cachedResponse = _getCachedResponse<BotDetailResponse>(cacheKey);
    if (cachedResponse != null) {
      return cachedResponse;
    }
    
    // Fetch from API
    BotDetailResponse response;
    if (_useMockData) {
      response = await MockApiService.getBotDetail(
        botId,
        tradeStatus: tradeStatus,
        limit: limit,
        offset: offset,
      );
    } else {
      response = await ApiService.getBotDetail(
        botId,
        tradeStatus: tradeStatus,
        limit: limit,
        offset: offset,
      );
    }
    
    // Cache the response only if it has data (don't cache empty results)
    if (response.trades.isNotEmpty) {
      _cacheResponse(cacheKey, response);
    }
    return response;
  }

  static Future<CreateBotResponse> createBot(CreateBotRequest request) async {
    if (_useMockData) {
      return MockApiService.createBot(request);
    } else {
      return ApiService.createBot(request);
    }
  }

  static Future<TradesResponse> getTrades({
    int page = 1,
  }) async {
    if (_useMockData) {
      return MockApiService.getTrades(page: page);
    } else {
      return ApiService.getTrades(page: page);
    }
  }

  static Future<ProfileResponse> getProfile() async {
    if (_useMockData) {
      return MockApiService.getProfile();
    } else {
      return ApiService.getProfile();
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_useMockData) {
      return MockApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } else {
      return ApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    }
  }
}

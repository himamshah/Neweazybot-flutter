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

  static Future<BotsListResponse> getBots({
    String status = 'all',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int limit = 20,
    int offset = 0,
  }) async {
    if (_useMockData) {
      return MockApiService.getBots(
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      );
    } else {
      return ApiService.getBots(
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      );
    }
  }

  static Future<BotDetailResponse> getBotDetail(
    int botId, {
    String tradeStatus = 'all',
    int limit = 20,
    int offset = 0,
  }) async {
    if (_useMockData) {
      return MockApiService.getBotDetail(
        botId,
        tradeStatus: tradeStatus,
        limit: limit,
        offset: offset,
      );
    } else {
      return ApiService.getBotDetail(
        botId,
        tradeStatus: tradeStatus,
        limit: limit,
        offset: offset,
      );
    }
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

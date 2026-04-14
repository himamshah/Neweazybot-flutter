import 'dart:async';
import '../models/bot.dart';
import '../models/trade.dart';
import '../models/create_bot.dart';
import 'api_service.dart';

class MockApiService {
  static const Duration _delay = Duration(milliseconds: 800); // Simulate network delay

  // Sample bot data matching the API specification
  static final List<Bot> _sampleBots = [
    Bot(
      id: 1495,
      coin: 'AINUSDT',
      exchange: 'Binance',
      direction: 'short',
      status: 'running',
      createdAt: DateTime.parse('2026-03-26T03:30:41Z'),
      pnl: PnL(
        realized: 48.20,
        unrealized: -12.40,
        net: 35.80,
      ),
      price: Price(
        market: 0.03948,
        avgEntry: 0.04102,
        avgEntryDistancePct: -3.75,
        liquidation: 0.05820,
        liquidationDistancePct: 47.40,
      ),
      capital: Capital(
        assigned: 1000.00,
        available: 485.00,
        inPosition: 515.00,
        availablePct: 48.5,
        growthPct: 0.85,
      ),
      covers: Covers(
        total: 20,
        activeCoverId: 11,
        nextCover: NextCover(
          coverId: 12,
          triggerPrice: 0.03912,
          estimatedAmount: 40.00,
        ),
        lastCover: LastCover(
          coverId: 11,
          filledAt: DateTime.parse('2026-04-09T04:21:56Z'),
          fillPrice: 0.013246,
        ),
      ),
    ),
    Bot(
      id: 1493,
      coin: 'AIOTUSDT',
      exchange: 'Binance',
      direction: 'short',
      status: 'running',
      createdAt: DateTime.parse('2026-01-10T08:39:00Z'),
      pnl: PnL(
        realized: 264.94,
        unrealized: -702.80,
        net: -437.86,
      ),
      price: Price(
        market: 0.3261,
        avgEntry: 0.3744,
        avgEntryDistancePct: -12.90,
        liquidation: 0.5810,
        liquidationDistancePct: 78.20,
      ),
      capital: Capital(
        assigned: 1000.00,
        available: 79.00,
        inPosition: 921.00,
        availablePct: 7.9,
        growthPct: 0.05,
      ),
      covers: Covers(
        total: 20,
        activeCoverId: 18,
        nextCover: NextCover(
          coverId: 19,
          triggerPrice: 0.3307,
          estimatedAmount: 80.00,
        ),
        lastCover: LastCover(
          coverId: 18,
          filledAt: DateTime.parse('2026-03-21T08:18:42Z'),
          fillPrice: 0.3340,
        ),
      ),
    ),
    Bot(
      id: 1480,
      coin: 'BTCUSDT',
      exchange: 'Binance',
      direction: 'long',
      status: 'stopped',
      createdAt: DateTime.parse('2026-01-10T08:00:00Z'),
      pnl: PnL(
        realized: 1240.18,
        unrealized: 0.00,
        net: 1240.18,
      ),
      price: Price(
        market: 83420.00,
        avgEntry: null,
        avgEntryDistancePct: null,
        liquidation: null,
        liquidationDistancePct: null,
      ),
      capital: Capital(
        assigned: 5000.00,
        available: 5000.00,
        inPosition: 0.00,
        availablePct: 100.0,
        growthPct: 24.80,
      ),
      covers: Covers(
        total: 10,
        activeCoverId: null,
        nextCover: null,
        lastCover: null,
      ),
    ),
  ];

  // Sample trade data for bot 1495
  static final List<Trade> _sampleTrades = [
    Trade(
      groupId: 26983,
      coverId: 11,
      coverLabel: 'Cover 11',
      status: 'open',
      openTrade: OpenTrade(
        id: 68716,
        exchangeTradeId: '755612131',
        action: 'open_short',
        description: '2% drop · 1×',
        price: 0.013246,
        qty: 3775,
        amount: 50.00,
        commission: 0.0100007,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T03:55:01Z'),
        filledAt: DateTime.parse('2026-04-09T04:21:56Z'),
      ),
      closeTrade: null,
      profit: null,
      profitPct: null,
      holdDurationSeconds: null,
      pendingTp: PendingTp(
        targetPrice: 0.013445,
        targetPct: 1.5,
      ),
    ),
    Trade(
      groupId: 26976,
      coverId: 3,
      coverLabel: 'Cover 3',
      status: 'closed',
      openTrade: OpenTrade(
        id: 68694,
        exchangeTradeId: '754225122',
        action: 'open_short',
        description: '3% drop · 2×',
        price: 0.013247,
        qty: 7549,
        amount: 100.001603,
        commission: 0.0200003,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T02:49:26Z'),
        filledAt: DateTime.parse('2026-04-09T02:49:26Z'),
      ),
      closeTrade: CloseTrade(
        id: 68699,
        exchangeTradeId: '754254868',
        action: 'close_short',
        description: 'Profit trade @5%',
        price: 0.012585,
        qty: 7549,
        amount: 95.004165,
        commission: 0.0190008,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T02:49:28Z'),
        filledAt: DateTime.parse('2026-04-09T02:53:04Z'),
      ),
      profit: 3.03,
      profitPct: 5.0,
      holdDurationSeconds: 218,
      pendingTp: null,
    ),
    Trade(
      groupId: 26977,
      coverId: 2,
      coverLabel: 'Cover 2',
      status: 'cancelled',
      openTrade: OpenTrade(
        id: 68702,
        exchangeTradeId: '754398928',
        action: 'open_short',
        description: '2% drop · 2×',
        price: 0.013246,
        qty: 7549,
        amount: 99.994054,
        commission: 0,
        fillStatus: 'cancelled',
        createdAt: DateTime.parse('2026-04-09T02:53:08Z'),
        filledAt: null,
      ),
      closeTrade: null,
      profit: null,
      profitPct: null,
      holdDurationSeconds: null,
      pendingTp: null,
    ),
    Trade(
      groupId: 26973,
      coverId: 2,
      coverLabel: 'Cover 2',
      status: 'closed',
      openTrade: OpenTrade(
        id: 68689,
        exchangeTradeId: '754030740',
        action: 'open_short',
        description: '2% drop · 2×',
        price: 0.012991,
        qty: 7698,
        amount: 100.004718,
        commission: 0.0200009,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T02:38:39Z'),
        filledAt: DateTime.parse('2026-04-09T02:38:39Z'),
      ),
      closeTrade: CloseTrade(
        id: 68695,
        exchangeTradeId: '754225121',
        action: 'close_short',
        description: 'Profit trade @4%',
        price: 0.012471,
        qty: 7698,
        amount: 96.001758,
        commission: 0.0192003,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T02:48:42Z'),
        filledAt: DateTime.parse('2026-04-09T02:53:06Z'),
      ),
      profit: 3.97,
      profitPct: 4.0,
      holdDurationSeconds: 267,
      pendingTp: null,
    ),
    Trade(
      groupId: 26969,
      coverId: 1,
      coverLabel: 'Cover 1',
      status: 'closed',
      openTrade: OpenTrade(
        id: 68657,
        exchangeTradeId: '752911480',
        action: 'open_short',
        description: '2% drop · 1×',
        price: 0.013015,
        qty: 7683,
        amount: 99.994245,
        commission: 0.0199988,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T01:25:00Z'),
        filledAt: DateTime.parse('2026-04-09T01:54:57Z'),
      ),
      closeTrade: CloseTrade(
        id: 68685,
        exchangeTradeId: '753331384',
        action: 'close_short',
        description: 'Profit trade @3%',
        price: 0.012494,
        qty: 7683,
        amount: 95.991402,
        commission: 0.0191983,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T02:07:23Z'),
        filledAt: DateTime.parse('2026-04-09T02:37:23Z'),
      ),
      profit: 1.86,
      profitPct: 3.0,
      holdDurationSeconds: 2543,
      pendingTp: null,
    ),
    Trade(
      groupId: 26960,
      coverId: 0,
      coverLabel: 'Initial order',
      status: 'closed',
      openTrade: OpenTrade(
        id: 68651,
        exchangeTradeId: '752772852',
        action: 'open_short',
        description: 'Initial position',
        price: 0.012347,
        qty: 4055,
        amount: 50.067,
        commission: 0.009999,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T01:07:24Z'),
        filledAt: DateTime.parse('2026-04-09T01:07:24Z'),
      ),
      closeTrade: CloseTrade(
        id: 68658,
        exchangeTradeId: '752911479',
        action: 'close_short',
        description: 'Profit trade @3%',
        price: 0.011977,
        qty: 4055,
        amount: 48.577,
        commission: 0.009699,
        fillStatus: 'filled',
        createdAt: DateTime.parse('2026-04-09T01:17:03Z'),
        filledAt: DateTime.parse('2026-04-09T01:17:00Z'),
      ),
      profit: 3.06,
      profitPct: 3.0,
      holdDurationSeconds: 576,
      pendingTp: null,
    ),
  ];

  static Future<BotsListResponse> getBots({
    String status = 'all',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int limit = 20,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Filter bots by status
    List<Bot> filteredBots = _sampleBots;
    if (status != 'all') {
      filteredBots = _sampleBots.where((bot) => bot.status == status).toList();
    }

    // Sort bots
    switch (sortBy) {
      case 'created_at':
        filteredBots.sort((a, b) => sortOrder == 'desc' 
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt));
        break;
      case 'realized_pnl':
        filteredBots.sort((a, b) => sortOrder == 'desc'
            ? b.pnl.realized.compareTo(a.pnl.realized)
            : a.pnl.realized.compareTo(b.pnl.realized));
        break;
      case 'net_pnl':
        filteredBots.sort((a, b) => sortOrder == 'desc'
            ? b.pnl.net.compareTo(a.pnl.net)
            : a.pnl.net.compareTo(b.pnl.net));
        break;
      case 'assigned_capital':
        filteredBots.sort((a, b) => sortOrder == 'desc'
            ? b.capital.assigned.compareTo(a.capital.assigned)
            : a.capital.assigned.compareTo(b.capital.assigned));
        break;
    }

    // Apply pagination
    final paginatedBots = filteredBots.skip(offset).take(limit).toList();

    return BotsListResponse(
      meta: Meta(
        total: filteredBots.length,
        limit: limit,
        offset: offset,
        hasMore: offset + limit < filteredBots.length,
      ),
      bots: paginatedBots,
    );
  }

  static Future<BotDetailResponse> getBotDetail(
    int botId, {
    String tradeStatus = 'all',
    int limit = 20,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Find the bot
    final bot = _sampleBots.firstWhere(
      (b) => b.id == botId,
      orElse: () => throw Exception('Bot with ID $botId not found'),
    );

    // Filter trades by status
    List<Trade> filteredTrades = _sampleTrades;
    if (tradeStatus != 'all') {
      filteredTrades = _sampleTrades.where((trade) => trade.status == tradeStatus).toList();
    }

    // Apply pagination
    final paginatedTrades = filteredTrades.skip(offset).take(limit).toList();

    // Calculate trades meta
    final totalProfit = filteredTrades
        .where((t) => t.profit != null)
        .fold(0.0, (sum, trade) => sum + trade.profit!);
    
    final closedCount = filteredTrades
        .where((t) => t.status == 'closed')
        .length;

    final activeCoverId = filteredTrades
        .where((t) => t.status == 'open')
        .isNotEmpty ? filteredTrades.firstWhere((t) => t.status == 'open').coverId : null;

    return BotDetailResponse(
      bot: bot,
      tradesMeta: TradesMeta(
        total: filteredTrades.length,
        limit: limit,
        offset: offset,
        hasMore: offset + limit < filteredTrades.length,
        totalProfit: totalProfit,
        closedCount: closedCount,
        activeCoverId: activeCoverId,
      ),
      trades: paginatedTrades,
    );
  }

  static Future<CreateBotResponse> createBot(CreateBotRequest request) async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Simulate validation
    if (request.exchangeKeyId.isEmpty) {
      throw Exception('Exchange key not found or access denied.');
    }
    if (request.tradingPair.isEmpty) {
      throw Exception('Trading pair is required.');
    }
    if (request.covers.isEmpty) {
      throw Exception('At least one cover is required.');
    }

    // Check for existing bot with same pair
    final existingBot = _sampleBots.firstWhere(
      (bot) => bot.coin == request.tradingPair && bot.status == 'running',
      orElse: () => Bot(
        id: 0, // Dummy bot
        coin: '',
        exchange: '',
        direction: '',
        status: '',
        createdAt: DateTime.now(),
        pnl: PnL(realized: 0, unrealized: 0, net: 0),
        price: Price(market: 0),
        capital: Capital(assigned: 0, available: 0, inPosition: 0, availablePct: 0, growthPct: 0),
        covers: Covers(total: 0),
      ),
    );

    if (existingBot.id != 0) {
      throw Exception('A bot is already running for ${request.tradingPair} on this exchange key.');
    }

    // Create new bot response
    final newBotId = 1496; // Simulate new bot ID
    return CreateBotResponse(
      id: newBotId,
      status: 'running',
      coin: request.tradingPair,
      exchange: 'Binance', // Default to Binance for mock
      direction: request.configuration.direction,
      createdAt: DateTime.now(),
      botDetails: request.botDetails,
      configuration: request.configuration,
      risk: request.risk,
      covers: request.covers,
      initialOrder: InitialOrder(
        id: 68800,
        action: 'open_${request.configuration.direction}',
        price: null,
        qty: null,
        amount: request.botDetails.assignedCapital * (request.botDetails.initialSizePct / 100),
        fillStatus: 'pending',
        createdAt: DateTime.now(),
      ),
    );
  }
}

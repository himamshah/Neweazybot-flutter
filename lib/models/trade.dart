import 'bot.dart';

class OpenTrade {
  final int id;
  final String exchangeTradeId;
  final String action;
  final String description;
  final double price;
  final int qty;
  final double amount;
  final double commission;
  final String fillStatus;
  final DateTime createdAt;
  final DateTime? filledAt;

  OpenTrade({
    required this.id,
    required this.exchangeTradeId,
    required this.action,
    required this.description,
    required this.price,
    required this.qty,
    required this.amount,
    required this.commission,
    required this.fillStatus,
    required this.createdAt,
    this.filledAt,
  });

  factory OpenTrade.fromJson(Map<String, dynamic> json) {
    return OpenTrade(
      id: json['id'] as int,
      exchangeTradeId: json['exchange_trade_id'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      qty: (json['qty'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      fillStatus: json['status'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      filledAt: json['filled_at'] != null ? DateTime.parse(json['filled_at'] as String) : null,
    );
  }
}

class CloseTrade {
  final int id;
  final String exchangeTradeId;
  final String action;
  final String description;
  final double price;
  final int qty;
  final double amount;
  final double commission;
  final String fillStatus;
  final DateTime createdAt;
  final DateTime? filledAt;

  CloseTrade({
    required this.id,
    required this.exchangeTradeId,
    required this.action,
    required this.description,
    required this.price,
    required this.qty,
    required this.amount,
    required this.commission,
    required this.fillStatus,
    required this.createdAt,
    this.filledAt,
  });

  factory CloseTrade.fromJson(Map<String, dynamic> json) {
    return CloseTrade(
      id: json['id'] as int,
      exchangeTradeId: json['exchange_trade_id'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      qty: (json['qty'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      fillStatus: json['status'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      filledAt: json['filled_at'] != null ? DateTime.parse(json['filled_at'] as String) : null,
    );
  }
}

class PendingTp {
  final double targetPrice;
  final double targetPct;

  PendingTp({
    required this.targetPrice,
    required this.targetPct,
  });

  factory PendingTp.fromJson(Map<String, dynamic> json) {
    return PendingTp(
      targetPrice: (json['target_price'] as num).toDouble(),
      targetPct: (json['target_pct'] as num).toDouble(),
    );
  }
}

class Trade {
  final int groupId;
  final int coverId;
  final String coverLabel;
  final String status;
  final OpenTrade? openTrade;
  final CloseTrade? closeTrade;
  final double? profit;
  final double? profitPct;
  final int? holdDurationSeconds;
  final PendingTp? pendingTp;

  Trade({
    required this.groupId,
    required this.coverId,
    required this.coverLabel,
    required this.status,
    this.openTrade,
    this.closeTrade,
    this.profit,
    this.profitPct,
    this.holdDurationSeconds,
    this.pendingTp,
  });

  // Add id getter for compatibility
  int get id => groupId;

  factory Trade.fromJson(Map<String, dynamic> json) {
    try {
      final trade = Trade(
        groupId: (json['group_id'] as num).toInt(),
        coverId: (json['cover_id'] as num).toInt(),
        coverLabel: json['cover_label'] as String,
        status: json['status'] as String,
        openTrade: json['open_trade'] != null ? OpenTrade.fromJson(json['open_trade']) : null,
        closeTrade: json['close_trade'] != null ? CloseTrade.fromJson(json['close_trade']) : null,
        profit: json['profit'] != null ? (json['profit'] as num).toDouble() : null,
        profitPct: json['profit_pct'] != null ? (json['profit_pct'] as num).toDouble() : null,
        holdDurationSeconds: json['hold_duration_seconds'] != null ? (json['hold_duration_seconds'] as num).toInt() : null,
        pendingTp: json['pending_tp'] != null ? PendingTp.fromJson(json['pending_tp']) : null,
      );
      return trade;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  String get coverDisplay {
    return coverId == 0 ? 'INI' : 'C$coverId';
  }

  Duration? get holdDuration {
    if (holdDurationSeconds != null) {
      return Duration(seconds: holdDurationSeconds!);
    }
    return null;
  }
}

class TradesMeta {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;
  final double totalProfit;
  final int closedCount;
  final int? activeCoverId;

  TradesMeta({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.totalProfit,
    required this.closedCount,
    this.activeCoverId,
  });

  factory TradesMeta.fromJson(Map<String, dynamic> json) {
    return TradesMeta(
      total: (json['total'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      hasMore: json['has_more'] as bool,
      totalProfit: (json['total_profit'] as num).toDouble(),
      closedCount: (json['closed_count'] as num).toInt(),
      activeCoverId: json['active_cover_id'] != null ? (json['active_cover_id'] as num).toInt() : null,
    );
  }
}

class BotDetailResponse {
  final Bot bot;
  final TradesMeta tradesMeta;
  final List<Trade> trades;

  BotDetailResponse({
    required this.bot,
    required this.tradesMeta,
    required this.trades,
  });

  factory BotDetailResponse.fromJson(Map<String, dynamic> json) {
    try {
      final response = BotDetailResponse(
        bot: Bot.fromJson(json['bot']),
        tradesMeta: TradesMeta.fromJson(json['trades_meta']),
        trades: (json['trades'] as List).map((trade) => Trade.fromJson(trade)).toList(),
      );
      return response;
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}

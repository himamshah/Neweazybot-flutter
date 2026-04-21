import 'create_bot.dart';

class PnL {
  final double realized;
  final double unrealized;
  final double net;

  PnL({
    required this.realized,
    required this.unrealized,
    required this.net,
  });

  factory PnL.fromJson(Map<String, dynamic> json) {
    try {
      return PnL(
        realized: _parseDouble(json['realized'], 'realized'),
        unrealized: _parseDouble(json['unrealized'], 'unrealized'),
        net: _parseDouble(json['net'], 'net'),
      );
    } catch (e) {
      print('BOT ERROR: Failed to parse PnL: $e');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value, String fieldName) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    print('BOT WARNING: $fieldName is not a number: $value (${value.runtimeType})');
    return 0.0;
  }
}

class Price {
  final double market;
  final double? avgEntry;
  final double? avgEntryDistancePct;
  final double? liquidation;
  final double? liquidationDistancePct;

  Price({
    required this.market,
    this.avgEntry,
    this.avgEntryDistancePct,
    this.liquidation,
    this.liquidationDistancePct,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    try {
      return Price(
        market: PnL._parseDouble(json['market'], 'market'),
        avgEntry: json['avg_entry'] != null ? PnL._parseDouble(json['avg_entry'], 'avg_entry') : null,
        avgEntryDistancePct: json['avg_entry_distance_pct'] != null ? PnL._parseDouble(json['avg_entry_distance_pct'], 'avg_entry_distance_pct') : null,
        liquidation: json['liquidation'] != null ? PnL._parseDouble(json['liquidation'], 'liquidation') : null,
        liquidationDistancePct: json['liquidation_distance_pct'] != null ? PnL._parseDouble(json['liquidation_distance_pct'], 'liquidation_distance_pct') : null,
      );
    } catch (e) {
      print('BOT ERROR: Failed to parse Price: $e');
      rethrow;
    }
  }
}

class Capital {
  final double assigned;
  final double available;
  final double inPosition;
  final double availablePct;
  final double growthPct;

  Capital({
    required this.assigned,
    required this.available,
    required this.inPosition,
    required this.availablePct,
    required this.growthPct,
  });

  factory Capital.fromJson(Map<String, dynamic> json) {
    return Capital(
      assigned: (json['assigned'] as num).toDouble(),
      available: (json['available'] as num).toDouble(),
      inPosition: (json['in_position'] as num).toDouble(),
      availablePct: (json['available_pct'] as num).toDouble(),
      growthPct: (json['growth_pct'] as num).toDouble(),
    );
  }
}

class Covers {
  final int total;
  final int? activeCoverId;
  final NextCover? nextCover;
  final LastCover? lastCover;

  Covers({
    required this.total,
    this.activeCoverId,
    this.nextCover,
    this.lastCover,
  });

  factory Covers.fromJson(Map<String, dynamic> json) {
    try {
      return Covers(
        total: json['total'] as int? ?? 0,
        activeCoverId: json['active_cover_id'] as int?,
        nextCover: json['next_cover'] != null && json['next_cover'] is Map ? NextCover.fromJson(json['next_cover']) : null,
        lastCover: json['last_cover'] != null && json['last_cover'] is Map ? LastCover.fromJson(json['last_cover']) : null,
      );
    } catch (e) {
      print('BOT ERROR: Failed to parse Covers: $e');
      print('BOT ERROR: Covers JSON: $json');
      rethrow;
    }
  }
}

class NextCover {
  final int? buyCoverId;
  final int? sellCoverId;
  final String? buyCoverDetail;
  final String? sellCoverDetail;
  final double? triggerPrice;
  final double? estimatedAmount;

  NextCover({
    this.buyCoverId,
    this.sellCoverId,
    this.buyCoverDetail,
    this.sellCoverDetail,
    this.triggerPrice,
    this.estimatedAmount,
  });

  factory NextCover.fromJson(Map<String, dynamic> json) {
    return NextCover(
      buyCoverId: json['buy_cover_id'] as int?,
      sellCoverId: json['sell_cover_id'] as int?,
      buyCoverDetail: json['buy_cover_detail'] as String?,
      sellCoverDetail: json['sell_cover_detail'] as String?,
      triggerPrice: json['trigger_price'] != null ? (json['trigger_price'] as num).toDouble() : null,
      estimatedAmount: json['estimated_amount'] != null ? (json['estimated_amount'] as num).toDouble() : null,
    );
  }
}

class LastCover {
  final int? buyCoverId;
  final int? sellCoverId;
  final String? buyCoverDetail;
  final String? sellCoverDetail;
  final double? triggerPrice;
  final double? estimatedAmount;

  LastCover({
    this.buyCoverId,
    this.sellCoverId,
    this.buyCoverDetail,
    this.sellCoverDetail,
    this.triggerPrice,
    this.estimatedAmount,
  });

  factory LastCover.fromJson(Map<String, dynamic> json) {
    return LastCover(
      buyCoverId: json['buy_cover_id'] as int?,
      sellCoverId: json['sell_cover_id'] as int?,
      buyCoverDetail: json['buy_cover_detail'] as String?,
      sellCoverDetail: json['sell_cover_detail'] as String?,
      triggerPrice: json['trigger_price'] != null ? (json['trigger_price'] as num).toDouble() : null,
      estimatedAmount: json['estimated_amount'] != null ? (json['estimated_amount'] as num).toDouble() : null,
    );
  }
}

class Bot {
  final int id;
  final String coin;
  final String exchange;
  final String direction;
  final String status;
  final DateTime createdAt;
  final PnL pnl;
  final Price price;
  final Capital capital;
  final Covers covers;
  final BotDetails? botDetails;
  final Configuration? configuration;
  final Risk? risk;

  Bot({
    required this.id,
    required this.coin,
    required this.exchange,
    required this.direction,
    required this.status,
    required this.createdAt,
    required this.pnl,
    required this.price,
    required this.capital,
    required this.covers,
    this.botDetails,
    this.configuration,
    this.risk,
  });

  factory Bot.fromJson(Map<String, dynamic> json) {
    try {
      return Bot(
        id: json['id'] as int,
        coin: json['coin'] as String,
        exchange: json['exchange'] as String,
        direction: json['direction'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        pnl: PnL.fromJson(json['pnl']),
        price: Price.fromJson(json['price']),
        capital: Capital.fromJson(json['capital']),
        covers: json['covers'] != null ? Covers.fromJson(json['covers']) : Covers(total: 0),
        botDetails: json['bot_details'] != null ? BotDetails.fromJson(json['bot_details']) : null,
        configuration: json['configuration'] != null ? Configuration.fromJson(json['configuration']) : null,
        risk: json['risk'] != null ? Risk.fromJson(json['risk']) : null,
      );
    } catch (e) {
      print('BOT ERROR: Failed to parse Bot: $e');
      print('BOT ERROR: Bot JSON: $json');
      rethrow;
    }
  }

  String get coinSymbol {
    // Remove USDT suffix if present, otherwise return full coin name
    if (coin.endsWith('USDT')) {
      return coin.substring(0, coin.length - 4);
    }
    return coin;
  }
}

class BotDetails {
  final double assignedCapital;
  final double initialSizePct;

  BotDetails({
    required this.assignedCapital,
    required this.initialSizePct,
  });

  factory BotDetails.fromJson(Map<String, dynamic> json) {
    return BotDetails(
      assignedCapital: (json['assigned_capital'] as num).toDouble(),
      initialSizePct: (json['initial_size_pct'] as num).toDouble(),
    );
  }
}

class Configuration {
  final String? direction;
  final double? triggerPrice;
  final double? takeProfitPct;
  final bool? cycleContinuous;
  final bool? autoCompounding;

  Configuration({
    this.direction,
    this.triggerPrice,
    this.takeProfitPct,
    this.cycleContinuous,
    this.autoCompounding,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      direction: json['direction'] as String?,
      triggerPrice: json['trigger_price'] != null ? (json['trigger_price'] as num).toDouble() : null,
      takeProfitPct: json['take_profit_pct'] != null ? (json['take_profit_pct'] as num).toDouble() : null,
      cycleContinuous: json['cycle_continuous'] as bool?,
      autoCompounding: json['auto_compounding'] as bool?,
    );
  }
}

class Risk {
  final double? netProfitPct;
  final double? stopLossPct;

  Risk({
    this.netProfitPct,
    this.stopLossPct,
  });

  factory Risk.fromJson(Map<String, dynamic> json) {
    return Risk(
      netProfitPct: json['net_profit_pct'] != null ? (json['net_profit_pct'] as num).toDouble() : null,
      stopLossPct: json['stop_loss_pct'] != null ? (json['stop_loss_pct'] as num).toDouble() : null,
    );
  }
}



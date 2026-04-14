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
    return PnL(
      realized: (json['realized'] as num).toDouble(),
      unrealized: (json['unrealized'] as num).toDouble(),
      net: (json['net'] as num).toDouble(),
    );
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
    return Price(
      market: (json['market'] as num).toDouble(),
      avgEntry: json['avg_entry'] != null ? (json['avg_entry'] as num).toDouble() : null,
      avgEntryDistancePct: json['avg_entry_distance_pct'] != null ? (json['avg_entry_distance_pct'] as num).toDouble() : null,
      liquidation: json['liquidation'] != null ? (json['liquidation'] as num).toDouble() : null,
      liquidationDistancePct: json['liquidation_distance_pct'] != null ? (json['liquidation_distance_pct'] as num).toDouble() : null,
    );
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
    return Covers(
      total: json['total'] as int,
      activeCoverId: json['active_cover_id'] as int?,
      nextCover: json['next_cover'] != null ? NextCover.fromJson(json['next_cover']) : null,
      lastCover: json['last_cover'] != null ? LastCover.fromJson(json['last_cover']) : null,
    );
  }
}

class NextCover {
  final int coverId;
  final double triggerPrice;
  final double estimatedAmount;

  NextCover({
    required this.coverId,
    required this.triggerPrice,
    required this.estimatedAmount,
  });

  factory NextCover.fromJson(Map<String, dynamic> json) {
    return NextCover(
      coverId: json['cover_id'] as int,
      triggerPrice: (json['trigger_price'] as num).toDouble(),
      estimatedAmount: (json['estimated_amount'] as num).toDouble(),
    );
  }
}

class LastCover {
  final int coverId;
  final DateTime filledAt;
  final double fillPrice;

  LastCover({
    required this.coverId,
    required this.filledAt,
    required this.fillPrice,
  });

  factory LastCover.fromJson(Map<String, dynamic> json) {
    return LastCover(
      coverId: json['cover_id'] as int,
      filledAt: DateTime.parse(json['filled_at'] as String),
      fillPrice: (json['fill_price'] as num).toDouble(),
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
  });

  factory Bot.fromJson(Map<String, dynamic> json) {
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
      covers: Covers.fromJson(json['covers']),
    );
  }

  String get coinSymbol {
    // Remove USDT suffix if present, otherwise return full coin name
    if (coin.endsWith('USDT')) {
      return coin.substring(0, coin.length - 4);
    }
    return coin;
  }
}

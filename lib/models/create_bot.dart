class BotDetails {
  final double assignedCapital;
  final double initialSizePct;

  BotDetails({
    required this.assignedCapital,
    required this.initialSizePct,
  });

  Map<String, dynamic> toJson() {
    return {
      'assigned_capital': assignedCapital,
      'initial_size_pct': initialSizePct,
    };
  }
}

class Configuration {
  final String direction;
  final double? triggerPrice;
  final double takeProfitPct;
  final bool cycleContinuous;
  final bool autoCompounding;

  Configuration({
    required this.direction,
    this.triggerPrice,
    required this.takeProfitPct,
    required this.cycleContinuous,
    required this.autoCompounding,
  });

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'trigger_price': triggerPrice,
      'take_profit_pct': takeProfitPct,
      'cycle_continuous': cycleContinuous,
      'auto_compounding': autoCompounding,
    };
  }
}

class Risk {
  final double netProfitPct;
  final double stopLossPct;

  Risk({
    required this.netProfitPct,
    required this.stopLossPct,
  });

  Map<String, dynamic> toJson() {
    return {
      'net_profit_pct': netProfitPct,
      'stop_loss_pct': stopLossPct,
    };
  }
}

class Cover {
  final int coverNumber;
  final double dropdownPct;
  final double takeProfitPct;
  final double qtyMultiplier;
  final String basePrice;

  Cover({
    required this.coverNumber,
    required this.dropdownPct,
    required this.takeProfitPct,
    required this.qtyMultiplier,
    required this.basePrice,
  });

  factory Cover.fromJson(Map<String, dynamic> json) {
    return Cover(
      coverNumber: json['cover_number'] as int,
      dropdownPct: (json['dropdown_pct'] as num).toDouble(),
      takeProfitPct: (json['take_profit_pct'] as num).toDouble(),
      qtyMultiplier: (json['qty_multiplier'] as num).toDouble(),
      basePrice: json['base_price'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cover_number': coverNumber,
      'dropdown_pct': dropdownPct,
      'take_profit_pct': takeProfitPct,
      'qty_multiplier': qtyMultiplier,
      'base_price': basePrice,
    };
  }
}

class CreateBotRequest {
  final String exchangeKeyId;
  final String tradingPair;
  final String preset;
  final BotDetails botDetails;
  final Configuration configuration;
  final Risk risk;
  final List<Cover> covers;

  CreateBotRequest({
    required this.exchangeKeyId,
    required this.tradingPair,
    required this.preset,
    required this.botDetails,
    required this.configuration,
    required this.risk,
    required this.covers,
  });

  Map<String, dynamic> toJson() {
    return {
      'exchange_key_id': exchangeKeyId,
      'trading_pair': tradingPair,
      'preset': preset,
      'bot_details': botDetails.toJson(),
      'configuration': configuration.toJson(),
      'risk': risk.toJson(),
      'covers': covers.map((cover) => cover.toJson()).toList(),
    };
  }
}

class InitialOrder {
  final int id;
  final String action;
  final double? price;
  final int? qty;
  final double amount;
  final String fillStatus;
  final DateTime createdAt;

  InitialOrder({
    required this.id,
    required this.action,
    this.price,
    this.qty,
    required this.amount,
    required this.fillStatus,
    required this.createdAt,
  });

  factory InitialOrder.fromJson(Map<String, dynamic> json) {
    return InitialOrder(
      id: json['id'] as int,
      action: json['action'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      qty: json['qty'] as int?,
      amount: (json['amount'] as num).toDouble(),
      fillStatus: json['fill_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CreateBotResponse {
  final int id;
  final String status;
  final String coin;
  final String exchange;
  final String direction;
  final DateTime createdAt;
  final BotDetails botDetails;
  final Configuration configuration;
  final Risk risk;
  final List<Cover> covers;
  final InitialOrder initialOrder;

  CreateBotResponse({
    required this.id,
    required this.status,
    required this.coin,
    required this.exchange,
    required this.direction,
    required this.createdAt,
    required this.botDetails,
    required this.configuration,
    required this.risk,
    required this.covers,
    required this.initialOrder,
  });

  factory CreateBotResponse.fromJson(Map<String, dynamic> json) {
    return CreateBotResponse(
      id: json['id'] as int,
      status: json['status'] as String,
      coin: json['coin'] as String,
      exchange: json['exchange'] as String,
      direction: json['direction'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      botDetails: BotDetails(
        assignedCapital: (json['bot_details']['assigned_capital'] as num).toDouble(),
        initialSizePct: (json['bot_details']['initial_size_pct'] as num).toDouble(),
      ),
      configuration: Configuration(
        direction: json['configuration']['direction'] as String,
        triggerPrice: json['configuration']['trigger_price'] != null 
            ? (json['configuration']['trigger_price'] as num).toDouble() 
            : null,
        takeProfitPct: (json['configuration']['take_profit_pct'] as num).toDouble(),
        cycleContinuous: json['configuration']['cycle_continuous'] as bool,
        autoCompounding: json['configuration']['auto_compounding'] as bool,
      ),
      risk: Risk(
        netProfitPct: (json['risk']['net_profit_pct'] as num).toDouble(),
        stopLossPct: (json['risk']['stop_loss_pct'] as num).toDouble(),
      ),
      covers: (json['covers'] as List).map((cover) => Cover(
        coverNumber: cover['cover_number'] as int,
        dropdownPct: (cover['dropdown_pct'] as num).toDouble(),
        takeProfitPct: (cover['take_profit_pct'] as num).toDouble(),
        qtyMultiplier: (cover['qty_multiplier'] as num).toDouble(),
        basePrice: cover['base_price'] as String,
      )).toList(),
      initialOrder: InitialOrder.fromJson(json['initial_order']),
    );
  }
}

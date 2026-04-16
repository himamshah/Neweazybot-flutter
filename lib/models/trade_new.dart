class TradeNew {
  final int id;
  final String responseId;
  final String status;
  final String symbol;
  final double price;
  final String qty;
  final double amount;
  final double commission;
  final String fillStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int? referenceId;
  final int? coverIndexId;
  final int? groupId;
  final int? sourceId;
  final double? currentBalance;
  final double tradeProfit;
  final int goalAchieved;
  final int userId;
  final int? closeTradeId;
  final int isClose;
  final String? failureReason;
  final String? comment;
  final DateTime? filledTimestamp;
  final String? description;
  final String? createdVia;

  TradeNew({
    required this.id,
    required this.responseId,
    required this.status,
    required this.symbol,
    required this.price,
    required this.qty,
    required this.amount,
    required this.commission,
    required this.fillStatus,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.referenceId,
    this.coverIndexId,
    this.groupId,
    this.sourceId,
    this.currentBalance,
    required this.tradeProfit,
    required this.goalAchieved,
    required this.userId,
    this.closeTradeId,
    required this.isClose,
    this.failureReason,
    this.comment,
    this.filledTimestamp,
    this.description,
    this.createdVia,
  });

  factory TradeNew.fromJson(Map<String, dynamic> json) {
    return TradeNew(
      id: json['id'] as int,
      responseId: json['response_id'] as String,
      status: json['status'] as String,
      symbol: json['symbol'] as String,
      price: (json['price'] as num).toDouble(),
      qty: json['qty'].toString(),
      amount: (json['amount'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      fillStatus: json['fill_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      referenceId: json['reference_id'] as int?,
      coverIndexId: json['cover_index_id'] as int?,
      groupId: json['group_id'] as int?,
      sourceId: json['source_id'] as int?,
      currentBalance: json['current_balance'] != null ? (json['current_balance'] as num).toDouble() : null,
      tradeProfit: (json['trade_profit'] as num).toDouble(),
      goalAchieved: json['goal_achieved'] as int,
      userId: json['user_id'] as int,
      closeTradeId: json['close_trade_id'] as int?,
      isClose: json['is_close'] as int,
      failureReason: json['failure_reason'] as String?,
      comment: json['comment'] as String?,
      filledTimestamp: json['filled_timestamp'] != null ? DateTime.parse(json['filled_timestamp'] as String) : null,
      description: json['description'] as String?,
      createdVia: json['created_via'] as String?,
    );
  }
}

class TradesResponse {
  final bool success;
  final String message;
  final Data data;

  TradesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TradesResponse.fromJson(Map<String, dynamic> json) {
    return TradesResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final int currentPage;
  final List<TradeNew> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final Links links;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  Data({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
    this.prevPageUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      currentPage: json['current_page'] as int,
      data: (json['data'] as List).map((trade) => TradeNew.fromJson(trade)).toList(),
      firstPageUrl: json['first_page_url'] as String,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      lastPageUrl: json['last_page_url'] as String,
      links: Links.fromJson(json['links']),
      path: json['path'] as String,
      perPage: json['per_page'] as int,
      to: json['to'] as int,
      total: json['total'] as int,
      prevPageUrl: json['prev_page_url'] as String?,
    );
  }
}

class Links {
  final String? url;
  final String? label;
  final bool active;

  Links({
    this.url,
    this.label,
    required this.active,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      url: json['url'] as String?,
      label: json['label'] as String?,
      active: json['active'] as bool,
    );
  }
}

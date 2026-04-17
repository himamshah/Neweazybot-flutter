class ApiKey {
  final int id;
  final String name;
  final String environment;
  final String maskedKey;
  final Exchange exchange;
  final bool isActive;
  final DateTime? createdAt;

  ApiKey({
    required this.id,
    required this.name,
    required this.environment,
    required this.maskedKey,
    required this.exchange,
    required this.isActive,
    this.createdAt,
  });

  factory ApiKey.fromJson(Map<String, dynamic> json) {
    return ApiKey(
      id: json['id'] as int,
      name: json['name'] as String,
      environment: json['environment'] as String,
      maskedKey: json['masked_key'] as String,
      exchange: Exchange.fromJson(json['exchange'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'environment': environment,
      'masked_key': maskedKey,
      'exchange': exchange.toJson(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Exchange {
  final int id;
  final String name;

  Exchange({
    required this.id,
    required this.name,
  });

  factory Exchange.fromJson(Map<String, dynamic> json) {
    return Exchange(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class CreateApiKeyRequest {
  final String name;
  final String environment;
  final String apiKey;
  final String apiSecret;
  final int exchangeId;

  CreateApiKeyRequest({
    required this.name,
    required this.environment,
    required this.apiKey,
    required this.apiSecret,
    required this.exchangeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'environment': environment,
      'api_key': apiKey,
      'api_secret': apiSecret,
      'exchange_id': exchangeId,
    };
  }
}

class CreateApiKeyResponse {
  final ApiKey apiKey;

  CreateApiKeyResponse({
    required this.apiKey,
  });

  factory CreateApiKeyResponse.fromJson(Map<String, dynamic> json) {
    return CreateApiKeyResponse(
      apiKey: ApiKey.fromJson(json['api_key'] as Map<String, dynamic>),
    );
  }
}

class ApiKeysListResponse {
  final List<ApiKey> apiKeys;

  ApiKeysListResponse({
    required this.apiKeys,
  });

  factory ApiKeysListResponse.fromJson(Map<String, dynamic> json) {
    return ApiKeysListResponse(
      apiKeys: (json['api_keys'] as List)
          .map((apiKey) => ApiKey.fromJson(apiKey as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProfileResponse {
  final bool success;
  final ProfileData data;

  ProfileResponse({
    required this.success,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] as bool? ?? false,
      data: ProfileData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ProfileData {
  final String name;
  final String email;
  final String memberSince;
  final String avatar;
  final ProfileStats stats;
  final ProfileInfo profileInfo;

  ProfileData({
    required this.name,
    required this.email,
    required this.memberSince,
    required this.avatar,
    required this.stats,
    required this.profileInfo,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      memberSince: json['member_since'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      stats: ProfileStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      profileInfo: ProfileInfo.fromJson(json['profile_info'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ProfileStats {
  final int totalBots;
  final int runningBots;
  final double allTimePnl;

  ProfileStats({
    required this.totalBots,
    required this.runningBots,
    required this.allTimePnl,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalBots: (json['total_bots'] as num?)?.toInt() ?? 0,
      runningBots: (json['running_bots'] as num?)?.toInt() ?? 0,
      allTimePnl: (json['all_time_pnl'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProfileInfo {
  final String fullName;
  final String email;
  final String role;
  final int userId;
  final String lastLogin;

  ProfileInfo({
    required this.fullName,
    required this.email,
    required this.role,
    required this.userId,
    required this.lastLogin,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      lastLogin: json['last_login'] as String? ?? '',
    );
  }
}

// Path: models\user_model.dart
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final int balance;
  final int points;
  final bool isVerified;
  final DateTime? createdAt;
  final Map<String, dynamic>? stats;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.balance = 0,
    this.points = 0,
    this.isVerified = false,
    this.createdAt,
    this.stats, 
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      balance: json['balance'] ?? 0,
      points: json['points'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null, 
      stats: json['stats'] ?? {  // TAMBAHKAN INI
        'totalBookings': 0,
        'ongoingBookings': 0,
        'completedBookings': 0,

      }
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'balance': balance,
      'points': points,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'stats': stats, 
    };
  }
UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    int? balance,
    int? points,
    bool? isVerified,
    DateTime? createdAt,
    Map<String, dynamic>? stats,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      balance: balance ?? this.balance,
      points: points ?? this.points,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      stats: stats ?? this.stats, 
    );
  }
}
import '../../domain/entities/user.dart';

/// 사용자 모델 (JSON 직렬화 포함)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.profileImage,
    super.isExpert,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
      isExpert: json['is_expert'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profile_image': profileImage,
      'is_expert': isExpert,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      profileImage: user.profileImage,
      isExpert: user.isExpert,
      createdAt: user.createdAt,
    );
  }
}



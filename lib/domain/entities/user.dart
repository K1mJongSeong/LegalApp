/// 사용자 엔티티
class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? profileImage;
  final bool isExpert;
  final DateTime createdAt;
  final String? loginProvider; // 'email', 'google', 'kakao'

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImage,
    this.isExpert = false,
    required this.createdAt,
    this.loginProvider,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImage,
    bool? isExpert,
    DateTime? createdAt,
    String? loginProvider,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isExpert: isExpert ?? this.isExpert,
      createdAt: createdAt ?? this.createdAt,
      loginProvider: loginProvider ?? this.loginProvider,
    );
  }
}



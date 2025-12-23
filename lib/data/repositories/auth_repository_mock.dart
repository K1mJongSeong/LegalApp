import 'dart:async';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// 인증 레포지토리 Mock 구현체 (Firebase 없이 테스트용)
class AuthRepositoryMock implements AuthRepository {
  User? _currentUser;

  // 테스트용 사용자 데이터
  final Map<String, Map<String, dynamic>> _users = {
    'test@test.com': {
      'id': 'user_001',
      'email': 'test@test.com',
      'password': 'test1234',
      'name': '테스트 사용자',
      'phone': '010-1234-5678',
      'profile_image': null,
      'is_expert': false,
    },
  };

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final userData = _users[email];
    if (userData == null) {
      throw Exception('등록되지 않은 이메일입니다');
    }
    if (userData['password'] != password) {
      throw Exception('비밀번호가 올바르지 않습니다');
    }

    _currentUser = UserModel.fromJson(userData);
    return _currentUser!;
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    bool isExpert = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_users.containsKey(email)) {
      throw Exception('이미 사용 중인 이메일입니다');
    }

    final userData = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'profile_image': null,
      'is_expert': isExpert,
    };

    _users[email] = userData;
    _currentUser = UserModel.fromJson(userData);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_users.containsKey(email)) {
      throw Exception('등록되지 않은 이메일입니다');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return Stream.value(_currentUser);
  }
}



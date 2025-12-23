import '../entities/user.dart';

/// 인증 레포지토리 인터페이스
abstract class AuthRepository {
  /// 현재 로그인된 사용자 가져오기
  Future<User?> getCurrentUser();

  /// 이메일 로그인
  Future<User> loginWithEmail({
    required String email,
    required String password,
  });

  /// 회원가입
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    bool isExpert = false,
  });

  /// 로그아웃
  Future<void> logout();

  /// 비밀번호 재설정 이메일 발송
  Future<void> sendPasswordResetEmail(String email);

  /// 인증 상태 스트림
  Stream<User?> get authStateChanges;
}



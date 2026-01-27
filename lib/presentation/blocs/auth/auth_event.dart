import 'package:equatable/equatable.dart';

/// 인증 이벤트
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 앱 시작 시 인증 상태 확인
class AuthCheckRequested extends AuthEvent {}

/// 이메일 로그인 요청
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// 회원가입 요청
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final bool isExpert;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.isExpert = false,
  });

  @override
  List<Object?> get props => [email, password, name, phone, isExpert];
}

/// 로그아웃 요청
class AuthLogoutRequested extends AuthEvent {}

/// 비밀번호 재설정 이메일 요청
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// 에러 초기화
class AuthErrorCleared extends AuthEvent {}

/// 구글 로그인 요청
class AuthGoogleLoginRequested extends AuthEvent {
  final bool isExpert;

  const AuthGoogleLoginRequested({this.isExpert = false});

  @override
  List<Object?> get props => [isExpert];
}

/// 카카오 로그인 요청
class AuthKakaoLoginRequested extends AuthEvent {
  final bool isExpert;

  const AuthKakaoLoginRequested({this.isExpert = false});

  @override
  List<Object?> get props => [isExpert];
}



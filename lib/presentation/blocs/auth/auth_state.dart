import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

/// 인증 상태
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class AuthInitial extends AuthState {}

/// 로딩 중
class AuthLoading extends AuthState {}

/// 인증됨
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// 미인증
class AuthUnauthenticated extends AuthState {}

/// 에러
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 비밀번호 재설정 이메일 발송 완료
class AuthPasswordResetSent extends AuthState {}

/// 회원탈퇴 완료
class AuthAccountDeleted extends AuthState {}



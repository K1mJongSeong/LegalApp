import 'package:equatable/equatable.dart';

/// 전문가 계정 엔티티 (권한/인증 관리용)
/// experts 컬렉션(공개 프로필)과 분리된 계정 전용 데이터
class ExpertAccount extends Equatable {
  final String id; // expert_accounts document id
  final String userId; // Firebase Auth uid
  final String? expertPublicId; // experts 컬렉션의 expertId 참조 (선택)
  final bool isVerified; // 인증 완료 여부
  final String status; // active, pending, suspended
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpertAccount({
    required this.id,
    required this.userId,
    this.expertPublicId,
    required this.isVerified,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        expertPublicId,
        isVerified,
        status,
        createdAt,
        updatedAt,
      ];

  ExpertAccount copyWith({
    String? id,
    String? userId,
    String? expertPublicId,
    bool? isVerified,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpertAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expertPublicId: expertPublicId ?? this.expertPublicId,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}








import 'package:equatable/equatable.dart';

/// 상담 요청 엔티티 (전문가 대시보드용)
class ConsultationRequest extends Equatable {
  final String id;
  final String expertAccountId; // expert_accounts 참조
  final String? expertPublicId; // experts 참조 (선택)
  final String userId; // 요청자 uid
  final String title;
  final String status; // waiting, accepted, completed
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final String? consultationPostId; // consultation_posts 참조 (상담 글 ID)

  const ConsultationRequest({
    required this.id,
    required this.expertAccountId,
    this.expertPublicId,
    required this.userId,
    required this.title,
    required this.status,
    this.scheduledAt,
    required this.createdAt,
    this.consultationPostId,
  });

  @override
  List<Object?> get props => [
        id,
        expertAccountId,
        expertPublicId,
        userId,
        title,
        status,
        scheduledAt,
        createdAt,
        consultationPostId,
      ];
}
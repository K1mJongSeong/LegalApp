import 'package:equatable/equatable.dart';

/// 상담 글 엔티티
class ConsultationPost extends Equatable {
  final String id;
  final String userId; // 작성자 uid
  final String title; // 제목
  final String content; // 내용
  final DateTime incidentDate; // 최초 사건 발생 일자
  final String? category; // 카테고리
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views; // 조회수
  final int comments; // 댓글 수

  const ConsultationPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.incidentDate,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    this.views = 0,
    this.comments = 0,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        incidentDate,
        category,
        createdAt,
        updatedAt,
        views,
        comments,
      ];
}


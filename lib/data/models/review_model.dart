import '../../domain/entities/review.dart';

/// 리뷰 모델 (JSON 포함)
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.expertId,
    required super.caseId,
    required super.rating,
    required super.content,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      expertId: json['expert_id'] as int,
      caseId: json['case_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'expert_id': expertId,
      'case_id': caseId,
      'rating': rating,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      userId: review.userId,
      expertId: review.expertId,
      caseId: review.caseId,
      rating: review.rating,
      content: review.content,
      createdAt: review.createdAt,
    );
  }
}



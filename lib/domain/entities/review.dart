/// 리뷰 엔티티
class Review {
  final String id;
  final String userId;
  final int expertId;
  final String caseId;
  final double rating;
  final String content;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.expertId,
    required this.caseId,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  Review copyWith({
    String? id,
    String? userId,
    int? expertId,
    String? caseId,
    double? rating,
    String? content,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expertId: expertId ?? this.expertId,
      caseId: caseId ?? this.caseId,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}



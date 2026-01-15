/// 경력사항 엔티티
class Career {
  final String? id; // Firestore document ID (optional for new entries)
  final int? startYear; // 경력시작 년도
  final int? endYear; // 경력종료 년도
  final String? description; // 경력사항 설명
  final bool isRepresentative; // 대표항목 여부

  const Career({
    this.id,
    this.startYear,
    this.endYear,
    this.description,
    this.isRepresentative = false,
  });

  Career copyWith({
    String? id,
    int? startYear,
    int? endYear,
    String? description,
    bool? isRepresentative,
  }) {
    return Career(
      id: id ?? this.id,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      description: description ?? this.description,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}




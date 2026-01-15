/// 수상내역 엔티티
class Award {
  final String? id; // Firestore document ID (optional for new entries)
  final int? year; // 연도
  final String? description; // 수상내용
  final bool isRepresentative; // 대표항목 여부

  const Award({
    this.id,
    this.year,
    this.description,
    this.isRepresentative = false,
  });

  Award copyWith({
    String? id,
    int? year,
    String? description,
    bool? isRepresentative,
  }) {
    return Award(
      id: id ?? this.id,
      year: year ?? this.year,
      description: description ?? this.description,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}




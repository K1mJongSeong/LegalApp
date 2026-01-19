/// 자격사항 엔티티
class Qualification {
  final String? id; // Firestore document ID (optional for new entries)
  final int? year; // 연도
  final String? description; // 자격사항 내용
  final bool isRepresentative; // 대표항목 여부

  const Qualification({
    this.id,
    this.year,
    this.description,
    this.isRepresentative = false,
  });

  Qualification copyWith({
    String? id,
    int? year,
    String? description,
    bool? isRepresentative,
  }) {
    return Qualification(
      id: id ?? this.id,
      year: year ?? this.year,
      description: description ?? this.description,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}

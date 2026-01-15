/// 기타활동 엔티티
class OtherActivity {
  final String? id; // Firestore document ID (optional for new entries)
  final int? startYear; // 시작연도
  final int? endYear; // 종료연도
  final String? content; // 내용
  final bool isRepresentative; // 대표항목 여부

  const OtherActivity({
    this.id,
    this.startYear,
    this.endYear,
    this.content,
    this.isRepresentative = false,
  });

  OtherActivity copyWith({
    String? id,
    int? startYear,
    int? endYear,
    String? content,
    bool? isRepresentative,
  }) {
    return OtherActivity(
      id: id ?? this.id,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      content: content ?? this.content,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}



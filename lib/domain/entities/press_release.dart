/// 보도자료 엔티티
class PressRelease {
  final String? id; // Firestore document ID (optional for new entries)
  final int? year; // 보도 연도
  final int? month; // 보도 월
  final String? summary; // 보도 내용 요약
  final String? url; // URL 주소
  final bool isRepresentative; // 대표항목 여부

  const PressRelease({
    this.id,
    this.year,
    this.month,
    this.summary,
    this.url,
    this.isRepresentative = false,
  });

  PressRelease copyWith({
    String? id,
    int? year,
    int? month,
    String? summary,
    String? url,
    bool? isRepresentative,
  }) {
    return PressRelease(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      summary: summary ?? this.summary,
      url: url ?? this.url,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}









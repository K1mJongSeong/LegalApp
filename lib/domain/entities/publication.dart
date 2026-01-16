/// 논문/출판 엔티티
class Publication {
  final String? id; // Firestore document ID (optional for new entries)
  final String? category; // 분류
  final int? year; // 연도
  final String? title; // 제목
  final String? url; // URL 주소
  final bool isRepresentative; // 대표항목 여부

  const Publication({
    this.id,
    this.category,
    this.year,
    this.title,
    this.url,
    this.isRepresentative = false,
  });

  Publication copyWith({
    String? id,
    String? category,
    int? year,
    String? title,
    String? url,
    bool? isRepresentative,
  }) {
    return Publication(
      id: id ?? this.id,
      category: category ?? this.category,
      year: year ?? this.year,
      title: title ?? this.title,
      url: url ?? this.url,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}




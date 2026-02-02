import '../../domain/entities/press_release.dart';

/// 보도자료 모델 (Firestore JSON 변환)
class PressReleaseModel extends PressRelease {
  const PressReleaseModel({
    super.id,
    super.year,
    super.month,
    super.summary,
    super.url,
    super.isRepresentative,
  });

  /// Firestore → Model
  factory PressReleaseModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PressReleaseModel(
      id: id ?? json['id'] as String?,
      year: json['year'] as int?,
      month: json['month'] as int?,
      summary: json['summary'] as String?,
      url: json['url'] as String?,
      isRepresentative: json['isRepresentative'] as bool? ??
          json['is_representative'] as bool? ??
          false,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (summary != null) 'summary': summary,
      if (url != null) 'url': url,
      'isRepresentative': isRepresentative,
    };
  }

  /// Entity → Model
  factory PressReleaseModel.fromEntity(PressRelease entity) {
    return PressReleaseModel(
      id: entity.id,
      year: entity.year,
      month: entity.month,
      summary: entity.summary,
      url: entity.url,
      isRepresentative: entity.isRepresentative,
    );
  }
}









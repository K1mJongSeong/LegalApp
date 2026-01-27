import '../../domain/entities/other_activity.dart';

/// 기타활동 모델 (Firestore JSON 변환)
class OtherActivityModel extends OtherActivity {
  const OtherActivityModel({
    super.id,
    super.startYear,
    super.endYear,
    super.content,
    super.isRepresentative,
  });

  /// Firestore → Model
  factory OtherActivityModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return OtherActivityModel(
      id: id ?? json['id'] as String?,
      startYear: json['startYear'] as int? ?? json['start_year'] as int?,
      endYear: json['endYear'] as int? ?? json['end_year'] as int?,
      content: json['content'] as String?,
      isRepresentative: json['isRepresentative'] as bool? ??
          json['is_representative'] as bool? ??
          false,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (startYear != null) 'startYear': startYear,
      if (endYear != null) 'endYear': endYear,
      if (content != null) 'content': content,
      'isRepresentative': isRepresentative,
    };
  }

  /// Entity → Model
  factory OtherActivityModel.fromEntity(OtherActivity entity) {
    return OtherActivityModel(
      id: entity.id,
      startYear: entity.startYear,
      endYear: entity.endYear,
      content: entity.content,
      isRepresentative: entity.isRepresentative,
    );
  }
}







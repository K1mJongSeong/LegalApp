import '../../domain/entities/award.dart';

/// 수상내역 모델 (Firestore JSON 변환)
class AwardModel extends Award {
  const AwardModel({
    super.id,
    super.year,
    super.description,
    super.isRepresentative,
  });

  /// Firestore → Model
  factory AwardModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return AwardModel(
      id: id ?? json['id'] as String?,
      year: json['year'] as int?,
      description: json['description'] as String?,
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
      if (description != null) 'description': description,
      'isRepresentative': isRepresentative,
    };
  }

  /// Entity → Model
  factory AwardModel.fromEntity(Award entity) {
    return AwardModel(
      id: entity.id,
      year: entity.year,
      description: entity.description,
      isRepresentative: entity.isRepresentative,
    );
  }
}









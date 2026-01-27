import '../../domain/entities/qualification.dart';

/// 자격사항 모델 (Firestore JSON 변환)
class QualificationModel extends Qualification {
  const QualificationModel({
    super.id,
    super.year,
    super.description,
    super.isRepresentative,
  });

  /// Firestore → Model
  factory QualificationModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return QualificationModel(
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
  factory QualificationModel.fromEntity(Qualification entity) {
    return QualificationModel(
      id: entity.id,
      year: entity.year,
      description: entity.description,
      isRepresentative: entity.isRepresentative,
    );
  }
}







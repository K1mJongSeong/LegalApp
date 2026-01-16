import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/career.dart';

/// 경력사항 모델 (Firestore JSON 변환)
class CareerModel extends Career {
  const CareerModel({
    super.id,
    super.startYear,
    super.endYear,
    super.description,
    super.isRepresentative,
  });

  /// Firestore → Model
  factory CareerModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return CareerModel(
      id: id ?? json['id'] as String?,
      startYear: json['startYear'] as int? ?? json['start_year'] as int?,
      endYear: json['endYear'] as int? ?? json['end_year'] as int?,
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
      if (startYear != null) 'startYear': startYear,
      if (endYear != null) 'endYear': endYear,
      if (description != null) 'description': description,
      'isRepresentative': isRepresentative,
    };
  }

  /// Entity → Model
  factory CareerModel.fromEntity(Career entity) {
    return CareerModel(
      id: entity.id,
      startYear: entity.startYear,
      endYear: entity.endYear,
      description: entity.description,
      isRepresentative: entity.isRepresentative,
    );
  }
}





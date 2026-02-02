import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/education.dart';

/// 학력사항 모델 (Firestore JSON 변환)
class EducationModel extends Education {
  const EducationModel({
    super.id,
    super.enrollmentYear,
    super.graduationYear,
    super.degree,
    super.status,
    super.schoolName,
    super.departmentName,
    super.isRepresentative,
  });

  /// Firestore → Model
  factory EducationModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return EducationModel(
      id: id ?? json['id'] as String?,
      enrollmentYear: json['enrollmentYear'] as int? ??
          json['enrollment_year'] as int?,
      graduationYear: json['graduationYear'] as int? ??
          json['graduation_year'] as int?,
      degree: json['degree'] as String?,
      status: json['status'] as String?,
      schoolName: json['schoolName'] as String? ??
          json['school_name'] as String?,
      departmentName: json['departmentName'] as String? ??
          json['department_name'] as String?,
      isRepresentative: json['isRepresentative'] as bool? ??
          json['is_representative'] as bool? ??
          false,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (enrollmentYear != null) 'enrollmentYear': enrollmentYear,
      if (graduationYear != null) 'graduationYear': graduationYear,
      if (degree != null) 'degree': degree,
      if (status != null) 'status': status,
      if (schoolName != null) 'schoolName': schoolName,
      if (departmentName != null) 'departmentName': departmentName,
      'isRepresentative': isRepresentative,
    };
  }

  /// Entity → Model
  factory EducationModel.fromEntity(Education entity) {
    return EducationModel(
      id: entity.id,
      enrollmentYear: entity.enrollmentYear,
      graduationYear: entity.graduationYear,
      degree: entity.degree,
      status: entity.status,
      schoolName: entity.schoolName,
      departmentName: entity.departmentName,
      isRepresentative: entity.isRepresentative,
    );
  }
}















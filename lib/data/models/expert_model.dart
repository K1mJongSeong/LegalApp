import '../../domain/entities/expert.dart';

/// 전문가 모델 (JSON 포함)
class ExpertModel extends Expert {
  const ExpertModel({
    required super.id,
    required super.name,
    super.profileImage,
    required super.specialty,
    required super.categories,
    required super.experienceYears,
    super.rating,
    super.reviewCount,
    super.consultationCount,
    super.introduction,
    super.lawFirm,
    super.certifications,
    super.isAvailable,
  });

  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    return ExpertModel(
      id: json['id'] as int,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      specialty: json['specialty'] as String,
      categories: List<String>.from(json['categories'] as List),
      experienceYears: json['experience_years'] as int,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      consultationCount: json['consultation_count'] as int? ?? 0,
      introduction: json['introduction'] as String?,
      lawFirm: json['law_firm'] as String?,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'] as List)
          : null,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'specialty': specialty,
      'categories': categories,
      'experience_years': experienceYears,
      'rating': rating,
      'review_count': reviewCount,
      'consultation_count': consultationCount,
      'introduction': introduction,
      'law_firm': lawFirm,
      'certifications': certifications,
      'is_available': isAvailable,
    };
  }

  factory ExpertModel.fromEntity(Expert expert) {
    return ExpertModel(
      id: expert.id,
      name: expert.name,
      profileImage: expert.profileImage,
      specialty: expert.specialty,
      categories: expert.categories,
      experienceYears: expert.experienceYears,
      rating: expert.rating,
      reviewCount: expert.reviewCount,
      consultationCount: expert.consultationCount,
      introduction: expert.introduction,
      lawFirm: expert.lawFirm,
      certifications: expert.certifications,
      isAvailable: expert.isAvailable,
    );
  }
}



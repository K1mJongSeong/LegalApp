import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expert_profile.dart';
import 'education_model.dart';
import 'career_model.dart';
import 'qualification_model.dart';
import 'award_model.dart';

/// 전문가 프로필 모델 (Firestore JSON 변환)
class ExpertProfileModel extends ExpertProfile {
  const ExpertProfileModel({
    required super.id,
    required super.userId,
    super.profileImageUrl,
    super.virtualNumber,
    super.examType,
    super.examSession,
    super.passYear,
    super.isExamPublic,
    super.name,
    super.birthDate,
    super.gender,
    super.phoneNumber,
    super.officePhoneNumber,
    super.representativePhoneType,
    super.customPhoneNumber,
    super.isPhonePublic,
    super.convertTo050,
    super.email,
    super.auxiliaryEmail,
    super.oneLineIntro,
    super.educations,
    super.isEducationPublic,
    super.mainFields,
    super.officeName,
    super.officeRegion1,
    super.officeRegion2,
    super.affiliatedBranch,
    super.officeAddressSearch,
    super.postalCode,
    super.lotNumberAddress,
    super.roadNameAddress,
    super.detailedAddress,
    super.homepageUrl,
    super.operatingStartTime,
    super.operatingEndTime,
    super.isOperatingTimeAM,
    super.isOperatingEndTimeAM,
    super.holidays,
    super.serviceDetails,
    super.isKbaSpecializationRegistered,
    super.kbaSpecializations,
    super.specialQualifications,
    super.experiences,
    super.languages,
    super.otherLanguage,
    super.careers,
    super.createdAt,
    super.updatedAt,
  });

  /// Firestore → Model
  factory ExpertProfileModel.fromJson(Map<String, dynamic> json, String id) {
    // 학력사항 파싱
    List<Education> educations = [];
    if (json['educations'] != null) {
      final educationsList = json['educations'] as List<dynamic>?;
      if (educationsList != null) {
        educations = educationsList
            .map((e) => EducationModel.fromJson(
                e as Map<String, dynamic>, id: e['id'] as String?))
            .toList();
      }
    }

    // 경력사항 파싱
    List<Career> careers = [];
    if (json['careers'] != null) {
      final careersList = json['careers'] as List<dynamic>?;
      if (careersList != null) {
        careers = careersList
            .map((e) => CareerModel.fromJson(
                e as Map<String, dynamic>, id: e['id'] as String?))
            .toList();
      }
    }

    // 자격사항 파싱
    List<Qualification> qualifications = [];
    if (json['qualifications'] != null) {
      final qualificationsList = json['qualifications'] as List<dynamic>?;
      if (qualificationsList != null) {
        qualifications = qualificationsList
            .map((e) => QualificationModel.fromJson(
                e as Map<String, dynamic>, id: e['id'] as String?))
            .toList();
      }
    }

    // 수상내역 파싱
    List<Award> awards = [];
    if (json['awards'] != null) {
      final awardsList = json['awards'] as List<dynamic>?;
      if (awardsList != null) {
        awards = awardsList
            .map((e) => AwardModel.fromJson(
                e as Map<String, dynamic>, id: e['id'] as String?))
            .toList();
      }
    }

    return ExpertProfileModel(
      id: id,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ??
          json['profile_image_url'] as String?,
      virtualNumber: json['virtualNumber'] as String? ??
          json['virtual_number'] as String?,
      examType: json['examType'] as String? ?? json['exam_type'] as String?,
      examSession: json['examSession'] as String? ??
          json['exam_session'] as String?,
      passYear: json['passYear'] as int? ?? json['pass_year'] as int?,
      isExamPublic: json['isExamPublic'] as bool? ??
          json['is_exam_public'] as bool? ??
          true,
      // 인적사항
      name: json['name'] as String?,
      birthDate: (json['birthDate'] as Timestamp?)?.toDate() ??
          (json['birth_date'] as Timestamp?)?.toDate(),
      gender: json['gender'] as String?,
      phoneNumber: json['phoneNumber'] as String? ??
          json['phone_number'] as String?,
      // 연락처 정보
      officePhoneNumber: json['officePhoneNumber'] as String? ??
          json['office_phone_number'] as String?,
      representativePhoneType: json['representativePhoneType'] as String? ??
          json['representative_phone_type'] as String?,
      customPhoneNumber: json['customPhoneNumber'] as String? ??
          json['custom_phone_number'] as String?,
      isPhonePublic: json['isPhonePublic'] as bool? ??
          json['is_phone_public'] as bool? ??
          false,
      convertTo050: json['convertTo050'] as bool? ??
          json['convert_to_050'] as bool? ??
          false,
      email: json['email'] as String?,
      // 추가 정보
      auxiliaryEmail: json['auxiliaryEmail'] as String? ??
          json['auxiliary_email'] as String?,
      oneLineIntro: json['oneLineIntro'] as String? ??
          json['one_line_intro'] as String?,
      // 학력사항
      educations: educations,
      isEducationPublic: json['isEducationPublic'] as bool? ??
          json['is_education_public'] as bool? ??
          true,
      // 주요분야
      mainFields: (json['mainFields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['main_fields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      // 사무실 정보
      officeName: json['officeName'] as String? ??
          json['office_name'] as String?,
      officeRegion1: json['officeRegion1'] as String? ??
          json['office_region1'] as String?,
      officeRegion2: json['officeRegion2'] as String? ??
          json['office_region2'] as String?,
      affiliatedBranch: json['affiliatedBranch'] as String? ??
          json['affiliated_branch'] as String?,
      officeAddressSearch: json['officeAddressSearch'] as String? ??
          json['office_address_search'] as String?,
      postalCode: json['postalCode'] as String? ??
          json['postal_code'] as String?,
      lotNumberAddress: json['lotNumberAddress'] as String? ??
          json['lot_number_address'] as String?,
      roadNameAddress: json['roadNameAddress'] as String? ??
          json['road_name_address'] as String?,
      detailedAddress: json['detailedAddress'] as String? ??
          json['detailed_address'] as String?,
      homepageUrl: json['homepageUrl'] as String? ??
          json['homepage_url'] as String?,
      operatingStartTime: json['operatingStartTime'] as String? ??
          json['operating_start_time'] as String?,
      operatingEndTime: json['operatingEndTime'] as String? ??
          json['operating_end_time'] as String?,
      isOperatingTimeAM: json['isOperatingTimeAM'] as bool? ??
          json['is_operating_time_am'] as bool? ??
          true,
      isOperatingEndTimeAM: json['isOperatingEndTimeAM'] as bool? ??
          json['is_operating_end_time_am'] as bool? ??
          true,
      holidays: (json['holidays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      serviceDetails: (json['serviceDetails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['service_details'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      // 강조정보
      isKbaSpecializationRegistered: json['isKbaSpecializationRegistered'] as bool? ??
          json['is_kba_specialization_registered'] as bool? ??
          false,
      kbaSpecializations: (json['kbaSpecializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['kba_specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      specialQualifications: (json['specialQualifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['special_qualifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      experiences: (json['experiences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      otherLanguage: json['otherLanguage'] as String? ??
          json['other_language'] as String?,
      // 경력사항
      careers: careers,
      // 자격사항
      qualifications: qualifications,
      // 수상내역
      awards: awards,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          (json['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ??
          (json['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (virtualNumber != null) 'virtualNumber': virtualNumber,
      if (examType != null) 'examType': examType,
      if (examSession != null) 'examSession': examSession,
      if (passYear != null) 'passYear': passYear,
      'isExamPublic': isExamPublic,
      // 인적사항
      if (name != null) 'name': name,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
      if (gender != null) 'gender': gender,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      // 연락처 정보
      if (officePhoneNumber != null) 'officePhoneNumber': officePhoneNumber,
      if (representativePhoneType != null)
        'representativePhoneType': representativePhoneType,
      if (customPhoneNumber != null) 'customPhoneNumber': customPhoneNumber,
      'isPhonePublic': isPhonePublic,
      'convertTo050': convertTo050,
      if (email != null) 'email': email,
      // 추가 정보
      if (auxiliaryEmail != null) 'auxiliaryEmail': auxiliaryEmail,
      if (oneLineIntro != null) 'oneLineIntro': oneLineIntro,
      // 학력사항
      'educations': educations
          .map((e) => EducationModel.fromEntity(e).toJson())
          .toList(),
      'isEducationPublic': isEducationPublic,
      // 주요분야
      'mainFields': mainFields,
      // 사무실 정보
      if (officeName != null) 'officeName': officeName,
      if (officeRegion1 != null) 'officeRegion1': officeRegion1,
      if (officeRegion2 != null) 'officeRegion2': officeRegion2,
      if (affiliatedBranch != null) 'affiliatedBranch': affiliatedBranch,
      if (officeAddressSearch != null)
        'officeAddressSearch': officeAddressSearch,
      if (postalCode != null) 'postalCode': postalCode,
      if (lotNumberAddress != null) 'lotNumberAddress': lotNumberAddress,
      if (roadNameAddress != null) 'roadNameAddress': roadNameAddress,
      if (detailedAddress != null) 'detailedAddress': detailedAddress,
      if (homepageUrl != null) 'homepageUrl': homepageUrl,
      if (operatingStartTime != null)
        'operatingStartTime': operatingStartTime,
      if (operatingEndTime != null) 'operatingEndTime': operatingEndTime,
      'isOperatingTimeAM': isOperatingTimeAM,
      'isOperatingEndTimeAM': isOperatingEndTimeAM,
      'holidays': holidays,
      'serviceDetails': serviceDetails,
      // 강조정보
      'isKbaSpecializationRegistered': isKbaSpecializationRegistered,
      'kbaSpecializations': kbaSpecializations,
      'specialQualifications': specialQualifications,
      'experiences': experiences,
      'languages': languages,
      if (otherLanguage != null) 'otherLanguage': otherLanguage,
      // 경력사항
      'careers': careers
          .map((e) => CareerModel.fromEntity(e).toJson())
          .toList(),
      // 자격사항
      'qualifications': qualifications
          .map((e) => QualificationModel.fromEntity(e).toJson())
          .toList(),
      // 수상내역
      'awards': awards
          .map((e) => AwardModel.fromEntity(e).toJson())
          .toList(),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Entity → Model
  factory ExpertProfileModel.fromEntity(ExpertProfile entity) {
    return ExpertProfileModel(
      id: entity.id,
      userId: entity.userId,
      profileImageUrl: entity.profileImageUrl,
      virtualNumber: entity.virtualNumber,
      examType: entity.examType,
      examSession: entity.examSession,
      passYear: entity.passYear,
      isExamPublic: entity.isExamPublic,
      name: entity.name,
      birthDate: entity.birthDate,
      gender: entity.gender,
      phoneNumber: entity.phoneNumber,
      officePhoneNumber: entity.officePhoneNumber,
      representativePhoneType: entity.representativePhoneType,
      customPhoneNumber: entity.customPhoneNumber,
      isPhonePublic: entity.isPhonePublic,
      convertTo050: entity.convertTo050,
      email: entity.email,
      auxiliaryEmail: entity.auxiliaryEmail,
      oneLineIntro: entity.oneLineIntro,
      educations: entity.educations,
      isEducationPublic: entity.isEducationPublic,
      mainFields: entity.mainFields,
      officeName: entity.officeName,
      officeRegion1: entity.officeRegion1,
      officeRegion2: entity.officeRegion2,
      affiliatedBranch: entity.affiliatedBranch,
      officeAddressSearch: entity.officeAddressSearch,
      postalCode: entity.postalCode,
      lotNumberAddress: entity.lotNumberAddress,
      roadNameAddress: entity.roadNameAddress,
      detailedAddress: entity.detailedAddress,
      homepageUrl: entity.homepageUrl,
      operatingStartTime: entity.operatingStartTime,
      operatingEndTime: entity.operatingEndTime,
      isOperatingTimeAM: entity.isOperatingTimeAM,
      isOperatingEndTimeAM: entity.isOperatingEndTimeAM,
      holidays: entity.holidays,
      serviceDetails: entity.serviceDetails,
      isKbaSpecializationRegistered: entity.isKbaSpecializationRegistered,
      kbaSpecializations: entity.kbaSpecializations,
      specialQualifications: entity.specialQualifications,
      experiences: entity.experiences,
      languages: entity.languages,
      otherLanguage: entity.otherLanguage,
      careers: entity.careers,
      qualifications: entity.qualifications,
      awards: entity.awards,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}




import 'education.dart';
import 'career.dart';
import 'award.dart';
import 'qualification.dart';
import 'publication.dart';
import 'press_release.dart';

/// 전문가 프로필 정보 엔티티
class ExpertProfile {
  final String id; // Firestore document ID
  final String userId; // Firebase Auth UID
  final String? profileImageUrl; // 프로필 이미지 URL
  final String? virtualNumber; // 050 가상 번호
  final String? examType; // 출신시험 (예: 변호사시험)
  final String? examSession; // 시험 회차 (예: 10회)
  final int? passYear; // 시험 합격 년도
  final bool isExamPublic; // 출신시험 공개 여부
  
  // 인적사항
  final String? name; // 이름
  final DateTime? birthDate; // 생년월일
  final String? gender; // 성별 ('male' or 'female')
  final String? phoneNumber; // 휴대폰 번호
  
  // 연락처 정보
  final String? officePhoneNumber; // 사무실 전화번호
  final String? representativePhoneType; // 대표 전화번호 타입 ('office', 'mobile', 'custom')
  final String? customPhoneNumber; // 직접 입력한 대표 전화번호
  final bool isPhonePublic; // 번호 공개 여부
  final bool convertTo050; // 050번호로 변환 여부
  final String? email; // 메일주소
  
  // 추가 정보
  final String? auxiliaryEmail; // 보조 메일주소
  final String? oneLineIntro; // 한 줄 소개
  
  // 학력사항
  final List<Education> educations; // 학력사항 목록
  final bool isEducationPublic; // 학력사항 공개 여부
  
  // 주요분야
  final List<String> mainFields; // 주요분야 목록 (최대 7개)
  
  // 사무실 정보
  final String? officeName; // 사무실이름
  final String? officeRegion1; // 사무실지역1 (시/도)
  final String? officeRegion2; // 사무실지역2 (시/군/구)
  final String? affiliatedBranch; // 소속 지회 (필수)
  final String? officeAddressSearch; // 사무실주소 검색어
  final String? postalCode; // 우편번호
  final String? lotNumberAddress; // 지번 주소
  final String? roadNameAddress; // 도로명 주소
  final String? detailedAddress; // 상세 주소
  final String? homepageUrl; // 홈페이지 주소
  final String? operatingStartTime; // 운영 시작시간 (HH:mm 형식)
  final String? operatingEndTime; // 운영 종료시간 (HH:mm 형식)
  final bool isOperatingTimeAM; // 시작시간 AM/PM
  final bool isOperatingEndTimeAM; // 종료시간 AM/PM
  final List<String> holidays; // 휴일 목록 (월요일, 화요일, ...)
  final List<String> serviceDetails; // 서비스사항 목록
  
  // 강조정보
  final bool isKbaSpecializationRegistered; // 대한변호사협회 전문분야 등록 여부
  final List<String> kbaSpecializations; // 등록된 전문분야 목록 (최대 2개)
  final List<String> specialQualifications; // 특수자격 목록
  final List<String> experiences; // 경험 목록
  final List<String> languages; // 외국어 목록
  final String? otherLanguage; // 기타 외국어
  
  // 추가정보
  final List<Career> careers; // 경력사항 목록
  final List<Qualification> qualifications; // 자격사항 목록
  final List<Award> awards; // 수상내역 목록
  final List<Publication> publications; // 논문/출판 목록
  final List<PressRelease> pressReleases; // 보도자료 목록
  
  // 세금계산서 정보
  final String? taxInvoiceType; // 세금계산서 타입 ('taxInvoice' or 'cashReceipt')
  final String? businessRegistrationNumber; // 사업자 등록번호
  final String? companyName; // 상호명
  final String? representativeName; // 대표자명
  final String? taxInvoiceEmail; // 기본 이메일 (필수)
  final String? additionalTaxInvoiceEmail; // 추가 이메일 (선택)
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpertProfile({
    required this.id,
    required this.userId,
    this.profileImageUrl,
    this.virtualNumber,
    this.examType,
    this.examSession,
    this.passYear,
    this.isExamPublic = true,
    this.name,
    this.birthDate,
    this.gender,
    this.phoneNumber,
    this.officePhoneNumber,
    this.representativePhoneType,
    this.customPhoneNumber,
    this.isPhonePublic = false,
    this.convertTo050 = false,
    this.email,
    this.auxiliaryEmail,
    this.oneLineIntro,
    this.educations = const [],
    this.isEducationPublic = true,
    this.mainFields = const [],
    this.officeName,
    this.officeRegion1,
    this.officeRegion2,
    this.affiliatedBranch,
    this.officeAddressSearch,
    this.postalCode,
    this.lotNumberAddress,
    this.roadNameAddress,
    this.detailedAddress,
    this.homepageUrl,
    this.operatingStartTime,
    this.operatingEndTime,
    this.isOperatingTimeAM = true,
    this.isOperatingEndTimeAM = true,
    this.holidays = const [],
    this.serviceDetails = const [],
    this.isKbaSpecializationRegistered = false,
    this.kbaSpecializations = const [],
    this.specialQualifications = const [],
    this.experiences = const [],
    this.languages = const [],
    this.otherLanguage,
    this.careers = const [],
    this.qualifications = const [],
    this.awards = const [],
    this.publications = const [],
    this.pressReleases = const [],
    this.taxInvoiceType,
    this.businessRegistrationNumber,
    this.companyName,
    this.representativeName,
    this.taxInvoiceEmail,
    this.additionalTaxInvoiceEmail,
    this.createdAt,
    this.updatedAt,
  });

  ExpertProfile copyWith({
    String? id,
    String? userId,
    String? profileImageUrl,
    String? virtualNumber,
    String? examType,
    String? examSession,
    int? passYear,
    bool? isExamPublic,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? phoneNumber,
    String? officePhoneNumber,
    String? representativePhoneType,
    String? customPhoneNumber,
    bool? isPhonePublic,
    bool? convertTo050,
    String? email,
    String? auxiliaryEmail,
    String? oneLineIntro,
    List<Education>? educations,
    bool? isEducationPublic,
    List<String>? mainFields,
    String? officeName,
    String? officeRegion1,
    String? officeRegion2,
    String? affiliatedBranch,
    String? officeAddressSearch,
    String? postalCode,
    String? lotNumberAddress,
    String? roadNameAddress,
    String? detailedAddress,
    String? homepageUrl,
    String? operatingStartTime,
    String? operatingEndTime,
    bool? isOperatingTimeAM,
    bool? isOperatingEndTimeAM,
    List<String>? holidays,
    List<String>? serviceDetails,
    bool? isKbaSpecializationRegistered,
    List<String>? kbaSpecializations,
    List<String>? specialQualifications,
    List<String>? experiences,
    List<String>? languages,
    String? otherLanguage,
    List<Career>? careers,
    List<Qualification>? qualifications,
    List<Award>? awards,
    List<Publication>? publications,
    List<PressRelease>? pressReleases,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpertProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      virtualNumber: virtualNumber ?? this.virtualNumber,
      examType: examType ?? this.examType,
      examSession: examSession ?? this.examSession,
      passYear: passYear ?? this.passYear,
      isExamPublic: isExamPublic ?? this.isExamPublic,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      officePhoneNumber: officePhoneNumber ?? this.officePhoneNumber,
      representativePhoneType: representativePhoneType ?? this.representativePhoneType,
      customPhoneNumber: customPhoneNumber ?? this.customPhoneNumber,
      isPhonePublic: isPhonePublic ?? this.isPhonePublic,
      convertTo050: convertTo050 ?? this.convertTo050,
      email: email ?? this.email,
      auxiliaryEmail: auxiliaryEmail ?? this.auxiliaryEmail,
      oneLineIntro: oneLineIntro ?? this.oneLineIntro,
      educations: educations ?? this.educations,
      isEducationPublic: isEducationPublic ?? this.isEducationPublic,
      mainFields: mainFields ?? this.mainFields,
      officeName: officeName ?? this.officeName,
      officeRegion1: officeRegion1 ?? this.officeRegion1,
      officeRegion2: officeRegion2 ?? this.officeRegion2,
      affiliatedBranch: affiliatedBranch ?? this.affiliatedBranch,
      officeAddressSearch: officeAddressSearch ?? this.officeAddressSearch,
      postalCode: postalCode ?? this.postalCode,
      lotNumberAddress: lotNumberAddress ?? this.lotNumberAddress,
      roadNameAddress: roadNameAddress ?? this.roadNameAddress,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      homepageUrl: homepageUrl ?? this.homepageUrl,
      operatingStartTime: operatingStartTime ?? this.operatingStartTime,
      operatingEndTime: operatingEndTime ?? this.operatingEndTime,
      isOperatingTimeAM: isOperatingTimeAM ?? this.isOperatingTimeAM,
      isOperatingEndTimeAM: isOperatingEndTimeAM ?? this.isOperatingEndTimeAM,
      holidays: holidays ?? this.holidays,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      isKbaSpecializationRegistered: isKbaSpecializationRegistered ?? this.isKbaSpecializationRegistered,
      kbaSpecializations: kbaSpecializations ?? this.kbaSpecializations,
      specialQualifications: specialQualifications ?? this.specialQualifications,
      experiences: experiences ?? this.experiences,
      languages: languages ?? this.languages,
      otherLanguage: otherLanguage ?? this.otherLanguage,
      careers: careers ?? this.careers,
      qualifications: qualifications ?? this.qualifications,
      awards: awards ?? this.awards,
      publications: publications ?? this.publications,
      pressReleases: pressReleases ?? this.pressReleases,
      taxInvoiceType: taxInvoiceType ?? this.taxInvoiceType,
      businessRegistrationNumber: businessRegistrationNumber ?? this.businessRegistrationNumber,
      companyName: companyName ?? this.companyName,
      representativeName: representativeName ?? this.representativeName,
      taxInvoiceEmail: taxInvoiceEmail ?? this.taxInvoiceEmail,
      additionalTaxInvoiceEmail: additionalTaxInvoiceEmail ?? this.additionalTaxInvoiceEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



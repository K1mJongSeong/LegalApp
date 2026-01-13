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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



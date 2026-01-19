/// 전문가 엔티티
class Expert {
  final int id;
  final String? userId; // Firebase Auth UID (ExpertProfile과 연결)
  final String name;
  final String? profileImage;
  final String specialty; // 전문 분야
  final List<String> categories; // 담당 카테고리
  final int experienceYears; // 경력 연수
  final double rating; // 평점
  final int reviewCount; // 리뷰 수
  final int consultationCount; // 상담 건수
  final String? introduction; // 자기소개
  final String? lawFirm; // 소속 법무법인
  final List<String>? certifications; // 자격증
  final bool isAvailable; // 상담 가능 여부
  final String? profession; // 직업 타입 (변호사, 노무사 등)

  const Expert({
    required this.id,
    this.userId,
    required this.name,
    this.profileImage,
    required this.specialty,
    required this.categories,
    required this.experienceYears,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.consultationCount = 0,
    this.introduction,
    this.lawFirm,
    this.certifications,
    this.isAvailable = true,
    this.profession,
  });

  Expert copyWith({
    int? id,
    String? userId,
    String? name,
    String? profileImage,
    String? specialty,
    List<String>? categories,
    int? experienceYears,
    double? rating,
    int? reviewCount,
    int? consultationCount,
    String? introduction,
    String? lawFirm,
    List<String>? certifications,
    bool? isAvailable,
    String? profession,
  }) {
    return Expert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      specialty: specialty ?? this.specialty,
      categories: categories ?? this.categories,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      consultationCount: consultationCount ?? this.consultationCount,
      introduction: introduction ?? this.introduction,
      lawFirm: lawFirm ?? this.lawFirm,
      certifications: certifications ?? this.certifications,
      isAvailable: isAvailable ?? this.isAvailable,
      profession: profession ?? this.profession,
    );
  }
}
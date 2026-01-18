import '../../domain/entities/expert_profile.dart';

/// 프로필 완성률 계산 유틸리티
class ProfileCompletionCalculator {
  /// 필수정보 탭의 완성률을 계산합니다 (0-100)
  static int calculateRequiredInfoCompletion(ExpertProfile? profile) {
    if (profile == null) return 0;

    int completedFields = 0;
    int totalFields = 0;

    // 1. 인적사항 섹션 (필수)
    totalFields += 5;
    if (profile.name != null && profile.name!.isNotEmpty) completedFields++;
    if (profile.birthDate != null) completedFields++;
    if (profile.gender != null && profile.gender!.isNotEmpty) completedFields++;
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) completedFields++;
    // 이메일 또는 대표 전화번호 타입이 설정되어 있어야 함
    if ((profile.email != null && profile.email!.isNotEmpty) ||
        (profile.representativePhoneType != null && profile.representativePhoneType!.isNotEmpty)) {
      completedFields++;
    }

    // 2. 학력사항 섹션 (필수)
    totalFields += 1;
    if (profile.educations.isNotEmpty) {
      // 학력사항이 최소 1개 이상 있어야 함
      completedFields++;
    }

    // 3. 주요분야 섹션 (필수)
    totalFields += 1;
    if (profile.mainFields.isNotEmpty) {
      // 주요분야가 최소 1개 이상 있어야 함
      completedFields++;
    }

    // 4. 사무실 정보 섹션 (필수)
    totalFields += 4;
    if (profile.affiliatedBranch != null && profile.affiliatedBranch!.isNotEmpty) completedFields++;
    if (profile.officeRegion1 != null && profile.officeRegion1!.isNotEmpty) completedFields++;
    if (profile.officeRegion2 != null && profile.officeRegion2!.isNotEmpty) completedFields++;
    // 도로명 주소 또는 지번 주소 중 하나라도 있어야 함
    if ((profile.roadNameAddress != null && profile.roadNameAddress!.isNotEmpty) ||
        (profile.lotNumberAddress != null && profile.lotNumberAddress!.isNotEmpty)) {
      completedFields++;
    }

    // 완성률 계산 (반올림)
    if (totalFields == 0) return 0;
    return ((completedFields / totalFields) * 100).round().clamp(0, 100);
  }
}





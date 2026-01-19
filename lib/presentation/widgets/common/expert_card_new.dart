import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/expert.dart';
import '../../../domain/entities/expert_profile.dart';

/// 전문가 카드 위젯 (새로운 디자인)
class ExpertCardNew extends StatelessWidget {
  final Expert expert;
  final ExpertProfile? profile; // 프로필 정보 (선택)
  final VoidCallback? onTap;
  final VoidCallback? onPhoneConsultation;
  final VoidCallback? onVisitConsultation;

  const ExpertCardNew({
    super.key,
    required this.expert,
    this.profile,
    this.onTap,
    this.onPhoneConsultation,
    this.onVisitConsultation,
  });

  @override
  Widget build(BuildContext context) {
    // 직업 타입 결정
    String profession = expert.profession ?? '변호사';
    if (profile?.examType != null) {
      if (profile!.examType!.contains('노무사')) {
        profession = '노무사';
      } else if (profile!.examType!.contains('변호사')) {
        profession = '변호사';
      }
    }

    // 소속 사무실
    String? lawFirm = expert.lawFirm ?? profile?.officeName;

    // 전문 분야 설명
    String specialization = expert.introduction ?? 
        expert.specialty ?? 
        (profile?.mainFields.isNotEmpty == true 
            ? profile!.mainFields.join(', ') 
            : '법률 전문가');

    // 상담 가능 시간 (임시로 랜덤하게 설정, 실제로는 profile에서 가져와야 함)
    String availability = '즉시 상담가능';
    if (profile != null) {
      // TODO: 실제 상담 가능 시간 로직 구현
      availability = '즉시 상담가능';
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 정보
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 이미지
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: expert.profileImage != null
                        ? ClipOval(
                            child: Image.network(
                              expert.profileImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar(expert.name);
                              },
                            ),
                          )
                        : _buildDefaultAvatar(expert.name),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  // 이름, 직업, 소속
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              expert.name,
                              style: const TextStyle(
                                fontSize: AppSizes.fontL,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                profession,
                                style: const TextStyle(
                                  fontSize: AppSizes.fontXS,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (lawFirm != null && lawFirm.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            lawFirm,
                            style: const TextStyle(
                              fontSize: AppSizes.fontS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              // 전문 분야 설명
              Text(
                specialization,
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              // 상담 가능 시간
              Text(
                availability,
                style: const TextStyle(
                  fontSize: AppSizes.fontS,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              // 상담 옵션 버튼
              Wrap(
                spacing: AppSizes.paddingS,
                runSpacing: AppSizes.paddingS,
                children: [
                  if (onPhoneConsultation != null)
                    _buildConsultationButton(
                      label: '15분 전화상담',
                      onTap: onPhoneConsultation!,
                    ),
                  if (onVisitConsultation != null)
                    _buildConsultationButton(
                      label: '30분 방문상담',
                      onTap: onVisitConsultation!,
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              // 연락처 아이콘
              Row(
                children: [
                  if (profile?.phoneNumber != null || profile?.representativePhoneType != null)
                    _buildContactIcon(Icons.phone_outlined),
                  if (profile?.isKakaoTalkInquiryEnabled == true)
                    _buildContactIcon(Icons.chat_bubble_outline),
                  if (profile?.email != null || profile?.emailInquiryAddress != null)
                    _buildContactIcon(Icons.email_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0] : '?',
        style: const TextStyle(
          fontSize: AppSizes.fontXL,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildConsultationButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppSizes.fontS,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildContactIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.paddingM),
      child: Icon(
        icon,
        size: 20,
        color: AppColors.textSecondary,
      ),
    );
  }
}
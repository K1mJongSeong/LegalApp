import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/profile_completion_calculator.dart';
import '../../../../domain/entities/expert_profile.dart';

/// 전문가 프로필 카드 위젯 (프로필 팁 + 프로필 정보 통합)
class ExpertProfileCard extends StatelessWidget {
  final String name;
  final int? completion;
  final bool isVerified;
  final ExpertProfile? profile;

  const ExpertProfileCard({
    super.key,
    required this.name,
    this.completion,
    required this.isVerified,
    this.profile,
  });

  int get _calculatedCompletion {
    if (completion != null) return completion!;
    return ProfileCompletionCalculator.calculateRequiredInfoCompletion(profile);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = (profile?.oneLineIntro != null && profile!.oneLineIntro!.trim().isNotEmpty)
        ? profile!.oneLineIntro!.trim()
        : (profile?.mainFields.isNotEmpty ?? false)
            ? '${profile!.mainFields.first} 전문'
            : '전문 분야를 입력해 주세요';
    final statusText = isVerified ? '승인완료' : '승인대기';
    final statusColor = isVerified ? AppColors.success : AppColors.error;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.expertProfileManage,
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4A5899),
                Color(0xFF3D4A7A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          ),
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 상단
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70),
                    ),
                    child: const Center(
                      child: Text(
                        '👤',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name님',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppSizes.fontL,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppSizes.fontS,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: AppSizes.fontXS,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                '프로필을 완성해야 사용자 검색 결과 상위에 노출됩니다!\n전문가님, 프로필을 완성해 주세요!',
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _calculatedCompletion / 100,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryLight,
                  ),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_calculatedCompletion% 완성',
                  style: TextStyle(
                    fontSize: AppSizes.fontS,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

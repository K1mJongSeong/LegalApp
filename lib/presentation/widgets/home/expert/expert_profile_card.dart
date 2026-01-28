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
    return Container(
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
          // 상단 팁 영역
          const Text(
            '프로필을 100%\n채워주세요.',
            style: TextStyle(
              fontSize: AppSizes.fontXXL,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '프로필을 모두 작성한 상태에서만 노출되어\n구글 검색결과로도 상위 노출됩니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),

          // 하단 프로필 정보 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isTight = constraints.maxWidth < 320;
                    final avatarSize = isTight ? 32.0 : 40.0;
                    final gap = isTight ? AppSizes.paddingS : AppSizes.paddingM;
                    final nameFontSize = isTight ? AppSizes.fontS : AppSizes.fontM;
                    final statusFontSize = isTight ? AppSizes.fontXS : AppSizes.fontXS;
                    final buttonFontSize = isTight ? AppSizes.fontXS : AppSizes.fontS;
                    final buttonPadding =
                        EdgeInsets.symmetric(horizontal: isTight ? 6 : 10);
                    final buttonWidth = isTight ? 70.0 : 86.0;
                    final buttonHeight = 28.0;

                    return Row(
                      children: [
                        // 좌측 프로필 영역 (이미지 + 텍스트)
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: avatarSize,
                                height: avatarSize,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '👤',
                                    style: TextStyle(
                                      fontSize: isTight ? 16 : 20,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: gap),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isVerified ? '승인완료' : '승인대기',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: statusFontSize,
                                        // color: AppColors.textSecondary,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$name님',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: nameFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isTight ? AppSizes.paddingXS : AppSizes.paddingS),
                        // 우측 작은 버튼 (고정 폭으로 무한 제약 방지)
                        SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.expertProfileManage,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: buttonPadding,
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '완성하기',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSizes.paddingM),

                // 완성률 프로그레스
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _calculatedCompletion / 100,
                    backgroundColor: Colors.grey[200],
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
                    '$_calculatedCompletion%완성',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

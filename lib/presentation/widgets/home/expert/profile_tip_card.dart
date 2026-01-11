import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';

/// 프로필 완성 팁 카드 위젯
class ProfileTipCard extends StatelessWidget {
  const ProfileTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '로디코드 TIP 01',
              style: TextStyle(
                fontSize: AppSizes.fontXS,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
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
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.expertDashboard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
            child: const Text('프로필 채우기'),
          ),
        ],
      ),
    );
  }
}






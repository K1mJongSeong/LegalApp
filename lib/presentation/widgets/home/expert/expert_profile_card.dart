import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';

/// 전문가 프로필 카드 위젯
class ExpertProfileCard extends StatelessWidget {
  final String name;
  final int completion;
  final bool isVerified;

  const ExpertProfileCard({
    super.key,
    required this.name,
    required this.completion,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 프로필 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 이름 + 승인 상태 배지
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$name님',
                style: const TextStyle(
                  fontSize: AppSizes.fontXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isVerified ? '승인 완료' : '승인 대기',
                  style: TextStyle(
                    fontSize: AppSizes.fontXS,
                    fontWeight: FontWeight.bold,
                    color: isVerified ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 프로필 완성률
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '프로필 완성률',
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completion%',
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 완성하기 버튼
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.expertDashboard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('완성하기'),
          ),
        ],
      ),
    );
  }
}










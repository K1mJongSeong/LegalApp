import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';

/// 빠른 상담 카드 위젯
class QuickConsultCard extends StatelessWidget {
  const QuickConsultCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '간단한 법률 상담이 필요하세요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            '전문가에게 빠르게 상담받아보세요',
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.fontM,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '${AppRoutes.experts}?urgency=simple',
              );
            },
            child: const Text(AppStrings.expertList),
          ),
        ],
      ),
    );
  }
}





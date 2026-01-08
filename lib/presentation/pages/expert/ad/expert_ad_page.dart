import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// 로디코드 AD 페이지 (전문가용)
class ExpertAdPage extends StatelessWidget {
  const ExpertAdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('로디코드 AD'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.paddingL),
            Text(
              '로디코드 AD',
              style: TextStyle(
                fontSize: AppSizes.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.paddingS),
            Text(
              '페이지 준비 중입니다',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



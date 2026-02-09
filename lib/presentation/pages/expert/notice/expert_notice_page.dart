import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// 공지사항 페이지 (전문가용)
class ExpertNoticePage extends StatelessWidget {
  const ExpertNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.paddingL),
            Text(
              '공지사항',
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























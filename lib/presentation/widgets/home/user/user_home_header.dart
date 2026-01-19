import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// 일반 사용자 홈 헤더 위젯
class UserHomeHeader extends StatelessWidget {
  final String name;

  const UserHomeHeader({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 기능은 준비 중입니다')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          '안녕하세요, $name님!',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontM,
          ),
        ),
      ],
    );
  }
}















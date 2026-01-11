import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// 관심있는 상담글 섹션 헤더 위젯
class ConsultationSectionHeader extends StatelessWidget {
  const ConsultationSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '관심있는 상담글',
          style: TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('전체보기 기능은 준비 중입니다')),
            );
          },
          child: Row(
            children: [
              Text(
                '전체보기',
                style: TextStyle(color: AppColors.primary),
              ),
              Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}






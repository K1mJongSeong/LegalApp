import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';

/// 빠른 상담 섹션 헤더 위젯
class QuickConsultSectionHeader extends StatelessWidget {
  const QuickConsultSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '빠른 상담',
          style: TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '${AppRoutes.experts}?urgency=simple',
            );
          },
          child: const Text('전체보기'),
        ),
      ],
    );
  }
}




















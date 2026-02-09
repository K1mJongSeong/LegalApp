import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';

/// 전문가 퀵 메뉴 위젯
class ExpertQuickMenu extends StatelessWidget {
  const ExpertQuickMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _QuickMenuItem(
            icon: Icons.person_outline,
            label: '프로필 편집',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.expertProfileManage);
            },
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: _QuickMenuItem(
            icon: Icons.calendar_today_outlined,
            label: '상담 일정',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('상담 일정 기능은 준비 중입니다')),
              );
            },
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: _QuickMenuItem(
            icon: Icons.bar_chart_outlined,
            label: '통계 분석',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('통계 분석 기능은 준비 중입니다')),
              );
            },
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: _QuickMenuItem(
            icon: Icons.edit_outlined,
            label: '포스트 작성',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('포스트 작성 기능은 준비 중입니다')),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 퀵 메뉴 아이템 (내부용)
class _QuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.grey[800], size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.fontXS,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
























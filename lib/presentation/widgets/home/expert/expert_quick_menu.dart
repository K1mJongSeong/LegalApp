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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickMenuItem(
          icon: Icons.person_outline,
          label: '프로필 편집',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.expertDashboard);
          },
        ),
        _QuickMenuItem(
          icon: Icons.calendar_today_outlined,
          label: '상담 일정',
          color: Colors.amber,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('상담 일정 기능은 준비 중입니다')),
            );
          },
        ),
        _QuickMenuItem(
          icon: Icons.bar_chart_outlined,
          label: '통계 분석',
          color: AppColors.primary,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('통계 분석 기능은 준비 중입니다')),
            );
          },
        ),
        _QuickMenuItem(
          icon: Icons.edit_outlined,
          label: '포스트 작성',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('포스트 작성 기능은 준비 중입니다')),
            );
          },
        ),
      ],
    );
  }
}

/// 퀵 메뉴 아이템 (내부용)
class _QuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _QuickMenuItem({
    required this.icon,
    required this.label,
    this.color,
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color ?? Colors.grey[600], size: 28),
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






















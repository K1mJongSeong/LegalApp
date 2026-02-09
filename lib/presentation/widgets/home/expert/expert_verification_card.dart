import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';

/// 전문가 인증 카드 위젯 (미인증 시)
class ExpertVerificationCard extends StatelessWidget {
  const ExpertVerificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '전문가 인증을 완료해 주세요!',
            style: TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            '인증이 완료되면 모든 서비스를 이용할 수 있습니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 즉시 인증 옵션
          _VerificationOption(
            icon: Icons.flash_on,
            iconColor: Colors.grey[600]!,
            title: '신분증 정보로 즉시 인증',
            subtitle: '대한변협 신분증 정보로 즉시 인증',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.expertCertification);
            },
          ),
          Divider(color: Colors.grey[200], height: 1),
          // 서류 인증 옵션
          _VerificationOption(
            icon: Icons.description_outlined,
            iconColor: Colors.grey[600]!,
            title: '증빙서류 제출',
            subtitle: '등록 증명원 또는 신분증 제출',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.expertCertification);
            },
          ),
        ],
      ),
    );
  }
}

/// 인증 옵션 위젯 (내부용)
class _VerificationOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _VerificationOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppSizes.fontXS,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

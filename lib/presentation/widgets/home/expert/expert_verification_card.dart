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
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '가입승인 필수',
              style: TextStyle(
                fontSize: AppSizes.fontXS,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          const Text(
            '전문가 인증을 완료해주세요',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            '인증이 완료되면 모든 서비스를 이용할 수 있습니다',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 즉시 인증 버튼
          _VerificationOption(
            icon: Icons.flash_on,
            iconColor: Colors.amber,
            title: '신분증 정보로 즉시 인증',
            subtitle: '대한변협 신분증 정보로 즉시 인증',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.expertCertification);
            },
          ),
          const SizedBox(height: AppSizes.paddingS),
          // 서류 인증 버튼
          _VerificationOption(
            icon: Icons.description_outlined,
            iconColor: Colors.grey,
            title: '증빙 서류 제출',
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.bold,
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













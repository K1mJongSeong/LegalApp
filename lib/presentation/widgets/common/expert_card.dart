import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/expert.dart';

/// 전문가 카드 위젯
class ExpertCard extends StatelessWidget {
  final Expert expert;
  final VoidCallback? onTap;
  final bool showButton;
  final String? buttonText;

  const ExpertCard({
    super.key,
    required this.expert,
    this.onTap,
    this.showButton = true,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    backgroundImage: expert.profileImage != null
                        ? NetworkImage(expert.profileImage!)
                        : null,
                    child: expert.profileImage == null
                        ? Text(
                            expert.name[0],
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: AppSizes.fontXL,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  // 기본 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              expert.name,
                              style: const TextStyle(
                                fontSize: AppSizes.fontL,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            if (expert.isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '상담가능',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: AppSizes.fontXS,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expert.specialty,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppSizes.fontM,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              // 상세 정보
              Row(
                children: [
                  _buildInfoChip(Icons.star, '${expert.rating}'),
                  const SizedBox(width: AppSizes.paddingM),
                  _buildInfoChip(Icons.chat_bubble_outline, '${expert.reviewCount}건'),
                  const SizedBox(width: AppSizes.paddingM),
                  _buildInfoChip(Icons.work_outline, '${expert.experienceYears}년'),
                ],
              ),
              if (expert.lawFirm != null) ...[
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  expert.lawFirm!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontS,
                  ),
                ),
              ],
              if (showButton) ...[
                const SizedBox(height: AppSizes.paddingM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    child: Text(buttonText ?? '선택하기'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: AppSizes.fontS,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}



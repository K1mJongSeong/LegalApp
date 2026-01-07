import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// 상담글 카드 위젯
class ConsultationCard extends StatelessWidget {
  final String category;
  final Color categoryColor;
  final String time;
  final String title;
  final int views;
  final int comments;

  const ConsultationCard({
    super.key,
    required this.category,
    required this.categoryColor,
    required this.time,
    required this.title,
    required this.views,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 상단: 카테고리 + 시간
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ Spacer 제거
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: categoryColor.withOpacity(0.3)),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: AppSizes.fontXS,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: AppSizes.fontXS,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingM),

          /// 제목
          Text(
            title,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSizes.paddingM),

          /// 하단: 조회수 / 댓글 / 버튼
          Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '$views',
                style: TextStyle(fontSize: AppSizes.fontXS, color: Colors.grey[500]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '$comments',
                style: TextStyle(fontSize: AppSizes.fontXS, color: Colors.grey[500]),
              ),
              const Spacer(), // ❌ 제거해야 하지만…

              /// 👉 여기서는 Spacer 대신 Expanded Text 패턴도 가능
            ],
          ),

          const SizedBox(height: AppSizes.paddingS),

          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('답변하기 기능은 준비 중입니다')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('답변하기'),
            ),
          ),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/consultation_post.dart';

/// 상담 사례 상세 페이지
class ConsultationPostDetailPage extends StatelessWidget {
  final ConsultationPost post;

  const ConsultationPostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('상담 사례'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 태그
              if (post.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getCategoryLabel(post.category!),
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: AppSizes.paddingM),

              // 제목
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),

              // 작성 정보
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy.MM.dd HH:mm').format(post.createdAt),
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Icon(Icons.visibility_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${post.views}',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${post.comments}',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),

              // 사건 발생일
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '사건 발생일: ${DateFormat('yyyy년 MM월 dd일').format(post.incidentDate)}',
                      style: const TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingL),
              const Divider(),
              const SizedBox(height: AppSizes.paddingL),

              // 본문 내용
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  color: AppColors.textPrimary,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    final categoryMap = {
      'labor': '노동',
      'real_estate': '부동산',
      'traffic': '교통사고',
      'criminal': '형사',
      'civil': '민사',
      'family': '가사',
      'company': '회사',
      'medical_tax': '의료·세금·행정',
      'it_ip': 'IT·지식재산·금융',
    };
    return categoryMap[category] ?? category;
  }
}

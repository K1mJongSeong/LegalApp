import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../widgets/home/expert/expert_home_header.dart';
import '../../../widgets/home/expert/expert_profile_card.dart';
import '../../../widgets/home/expert/profile_tip_card.dart';
import '../../../widgets/home/expert/consultation_section_header.dart';
import '../../../widgets/home/expert/consultation_card.dart';
import '../../../widgets/home/expert/recommendation_card.dart';
import '../../../widgets/home/expert/notice_card.dart';
import '../../../widgets/home/expert/expert_verification_card.dart';
import '../../../widgets/home/expert/expert_quick_menu.dart';

/// 전문가 홈 Sliver 위젯
/// 
/// SliverList + SliverChildListDelegate로 구성
/// Column, Expanded, Spacer 사용하지 않음
class ExpertHomeSliver extends StatelessWidget {
  final String name;
  final bool isVerified;
  final int profileCompletion;

  const ExpertHomeSliver({
    super.key,
    required this.name,
    this.isVerified = false,
    this.profileCompletion = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // 헤더
          // const ExpertHomeHeader(),
          const SizedBox(height: AppSizes.paddingM),

          // 프로필 카드
          ExpertProfileCard(
            name: name,
            completion: profileCompletion,
            isVerified: isVerified,
          ),
          const SizedBox(height: AppSizes.paddingM),

          // 프로필 완성 팁 카드
          const ProfileTipCard(),
          const SizedBox(height: AppSizes.paddingL),

          // 관심있는 상담글 섹션 헤더
          const ConsultationSectionHeader(),
          const SizedBox(height: AppSizes.paddingS),

          // 상담글 카드 1
          const ConsultationCard(
            category: '민사',
            categoryColor: Colors.red,
            time: '5분 전',
            title: '공증 실무(위조 사문서) 관련 문의',
            views: 3,
            comments: 0,
          ),
          const SizedBox(height: AppSizes.paddingS),

          // 상담글 카드 2
          const ConsultationCard(
            category: '가족',
            categoryColor: Colors.purple,
            time: '15분 전',
            title: '상속 포기 절차와 비용 문의드립니다',
            views: 12,
            comments: 2,
          ),
          const SizedBox(height: AppSizes.paddingM),

          // 추천 카드
          const RecommendationCard(),
          const SizedBox(height: AppSizes.paddingM),

          // 공지사항 카드
          const NoticeCard(),
          const SizedBox(height: AppSizes.paddingM),

          // 전문가 인증 카드 (미인증 시)
          if (!isVerified) const ExpertVerificationCard(),
          if (!isVerified) const SizedBox(height: AppSizes.paddingL),

          // 하단 퀵 메뉴
          const ExpertQuickMenu(),
          const SizedBox(height: AppSizes.paddingL),
        ]),
      ),
    );
  }
}











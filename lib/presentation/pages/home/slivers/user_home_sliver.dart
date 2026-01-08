import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../widgets/home/user/user_home_header.dart';
import '../../../widgets/home/user/search_bar_widget.dart';
import '../../../widgets/home/user/case_summary_card.dart';
import '../../../widgets/home/user/quick_consult_section.dart';
import '../../../widgets/home/user/quick_consult_card.dart';
import '../../../widgets/home/user/expert_certification_card.dart';

/// 일반 사용자 홈 Sliver 위젯
/// 
/// SliverList + SliverChildListDelegate로 구성
/// Column, Expanded, Spacer 사용하지 않음
class UserHomeSliver extends StatelessWidget {
  final String name;

  const UserHomeSliver({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // 헤더
          UserHomeHeader(name: name),
          const SizedBox(height: AppSizes.paddingL),

          // 검색바
          const SearchBarWidget(),
          const SizedBox(height: AppSizes.paddingXL),

          // AI 사건 요약 카드
          const CaseSummaryCard(),
          const SizedBox(height: AppSizes.paddingXL),

          // 빠른 상담 섹션 헤더
          const QuickConsultSectionHeader(),
          const SizedBox(height: AppSizes.paddingM),

          // 빠른 상담 카드
          const QuickConsultCard(),
          const SizedBox(height: AppSizes.paddingXL),

          // 전문가 인증 유도 카드
          const ExpertCertificationCard(),
          const SizedBox(height: AppSizes.paddingL),
        ]),
      ),
    );
  }
}



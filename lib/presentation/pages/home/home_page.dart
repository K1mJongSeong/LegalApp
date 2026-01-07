import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/bottom_nav_bar.dart';

/// 홈 화면
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: _HomeBody(context),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _HomeBody(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isExpert = state is AuthAuthenticated && state.user.isExpert;
        final name = state is AuthAuthenticated ? state.user.name : '회원';

        // 전문가 사용자용 UI
        if (isExpert) {
          return _buildExpertHomeBody(context, name);
        }

        // 일반 사용자용 UI
        return _buildUserHomeBody(context, name);
      },
    );
  }

  /// 전문가 사용자 홈 화면
  Widget _buildExpertHomeBody(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 기능은 준비 중입니다')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        // 환영 메시지
        Text(
          '안녕하세요, $name 전문가님!',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontM,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXL),
        // 전문가 대시보드 카드
        _buildExpertCertificationCard(context),
      ],
    );
  }

  /// 일반 사용자 홈 화면
  Widget _buildUserHomeBody(BuildContext context, String name) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppSizes.fontXXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('알림 기능은 준비 중입니다')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          // 환영 메시지
          Text(
            '안녕하세요, $name님!',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontM,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 검색바
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '어떤 법률 문제가 있으신가요?',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingM,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pushNamed(context, AppRoutes.caseInput);
                }
              },
            ),
          ),
          const SizedBox(height: AppSizes.paddingXL),
          // AI 사건 요약 카드
          _buildCaseSummaryCard(context),
          const SizedBox(height: AppSizes.paddingXL),
          // 빠른 상담
          Row(
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
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildQuickConsultCard(context),
          const SizedBox(height: AppSizes.paddingXL),
          // 전문가 인증 버튼
          _buildExpertCertificationCard(context),
        ]
      );
  }

  Widget _buildCaseSummaryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.categorySelect);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AI 분석',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.fontS,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            const Text(
              '사건 요약하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              '법률 문제를 AI가 분석하고\n관련 법령, 판례, 전문가를 추천해드려요',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: AppSizes.fontM,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '시작하기',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickConsultCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '간단한 법률 상담이 필요하세요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            '전문가에게 빠르게 상담받아보세요',
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.fontM,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '${AppRoutes.experts}?urgency=simple',
              );
            },
            child: const Text(AppStrings.expertList),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCertificationCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 전문가 대시보드로 이동 (인증 상태에 따라 자동 분기)
        Navigator.pushNamed(context, AppRoutes.expertDashboard);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!,
              Colors.purple[500]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '전문가이신가요?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.fontXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    '전문가 인증을 받고\n상담을 시작하세요',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: AppSizes.fontM,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '인증하기',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontSize: AppSizes.fontM,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.purple[700],
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user,
                color: Colors.white,
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

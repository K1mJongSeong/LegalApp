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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: Column(
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
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final name = state is AuthAuthenticated
                                ? state.user.name
                                : '회원';
                            return Text(
                              '안녕하세요, $name님!',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AppSizes.fontM,
                              ),
                            );
                          },
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
                              prefixIcon: Icon(Icons.search),
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
                        // 카테고리
                        const Text(
                          '카테고리',
                          style: TextStyle(
                            fontSize: AppSizes.fontL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: AppSizes.paddingM,
                          crossAxisSpacing: AppSizes.paddingM,
                          childAspectRatio: 1,
                          children: [
                            _buildCategoryCard(
                              context,
                              Icons.work_outline,
                              AppStrings.categoryLabor,
                              'labor',
                              AppColors.categoryLabor,
                            ),
                            _buildCategoryCard(
                              context,
                              Icons.receipt_long_outlined,
                              AppStrings.categoryTax,
                              'tax',
                              AppColors.categoryTax,
                            ),
                            _buildCategoryCard(
                              context,
                              Icons.gavel_outlined,
                              AppStrings.categoryCriminal,
                              'criminal',
                              AppColors.categoryCriminal,
                            ),
                            _buildCategoryCard(
                              context,
                              Icons.family_restroom_outlined,
                              AppStrings.categoryFamily,
                              'family',
                              AppColors.categoryFamily,
                            ),
                            _buildCategoryCard(
                              context,
                              Icons.home_work_outlined,
                              AppStrings.categoryReal,
                              'real',
                              AppColors.categoryReal,
                            ),
                            _buildCategoryCard(
                              context,
                              Icons.more_horiz,
                              '더보기',
                              null,
                              AppColors.textSecondary,
                            ),
                          ],
                        ),
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
                      ],
                    ),
                  ),
                ),
                const BottomNavBar(currentIndex: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    IconData icon,
    String label,
    String? category,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        if (category != null) {
          Navigator.pushNamed(
            context,
            '${AppRoutes.caseInput}?category=$category',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('추가 카테고리는 준비 중입니다')),
          );
        }
      },
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontS,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
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
}

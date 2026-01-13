import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// 전문가용 드로어 메뉴
class ExpertDrawer extends StatelessWidget {
  const ExpertDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // 닫기 버튼
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 프로필 섹션
            _buildProfileSection(context),
            const SizedBox(height: AppSizes.paddingL),

            // 메뉴 리스트
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 주요 메뉴
                    _buildSectionTitle('주요 메뉴'),
                    _buildMenuItem(
                      context,
                      icon: Icons.home_outlined,
                      title: '홈',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.lightbulb_outline,
                      title: '로디코드 소개',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.expertIntro);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.chat_bubble_outline,
                      title: '온라인 상담',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.expertConsult);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.campaign_outlined,
                      title: '로디코드 AD',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.expertAd);
                      },
                    ),

                    const SizedBox(height: AppSizes.paddingM),

                    // 콘텐츠
                    _buildSectionTitle('콘텐츠'),
                    _buildMenuItem(
                      context,
                      icon: Icons.article_outlined,
                      title: '포스트',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.expertPost);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.play_circle_outline,
                      title: '동영상',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.expertVideo);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: '공지사항',
                      trailing: _buildNewBadge(),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.expertNotice);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼들
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  /// 프로필 섹션
  Widget _buildProfileSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = state is AuthAuthenticated ? state.user.name : '전문가';
        const profileCompletion = 10; // TODO: 실제 데이터 연동

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // 프로필 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  // 이름 및 완성률
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name님',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '프로필 완성률 $profileCompletion%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.fontXS,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              // 내 프로필 수정 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.expertDashboard);
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('내 프로필 수정'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 섹션 타이틀
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingM,
        AppSizes.paddingL,
        AppSizes.paddingS,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppSizes.fontS,
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 메뉴 아이템
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppSizes.fontM,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  /// NEW 뱃지
  Widget _buildNewBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'N',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }

  /// 하단 버튼들
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // 설정 버튼
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('설정 기능은 준비 중입니다')),
                );
              },
              icon: Icon(Icons.settings_outlined, color: Colors.grey[600]),
              label: Text(
                '설정',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          // 구분선
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[300],
          ),
          // 로그아웃 버튼
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.orange),
              label: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }
}








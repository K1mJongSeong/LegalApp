import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/drawer/expert_drawer.dart';
import 'slivers/expert_home_sliver.dart';
import 'slivers/user_home_sliver.dart';

/// 홈 화면
/// 
/// - 전문가: Drawer 메뉴 사용 (햄버거 메뉴)
/// - 일반 사용자: BottomNavBar 사용
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isExpert = state is AuthAuthenticated && state.user.isExpert;
        final name = state is AuthAuthenticated ? state.user.name : '회원';

        return Scaffold(
          backgroundColor: AppColors.background,
          // 전문가인 경우 Drawer 사용
          drawer: isExpert ? const ExpertDrawer() : null,
          appBar: isExpert ? _buildExpertAppBar(context) : null,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
                child: CustomScrollView(
                  slivers: [
                    if (isExpert)
                      ExpertHomeSliver(
                        name: name,
                        isVerified: false, // TODO: 실제 데이터 연동 필요
                      )
                    else
                      UserHomeSliver(name: name),
                  ],
                ),
              ),
            ),
          ),
          // 일반 사용자인 경우에만 BottomNavBar 표시
          bottomNavigationBar: isExpert ? null : const BottomNavBar(currentIndex: 0),
        );
      },
    );
  }

  /// 전문가용 AppBar
  PreferredSizeWidget _buildExpertAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text(
        AppStrings.appName,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: AppSizes.fontXL,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('검색 기능은 준비 중입니다')),
            );
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 기능은 준비 중입니다')),
                );
              },
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

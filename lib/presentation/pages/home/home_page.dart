import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import 'slivers/expert_home_sliver.dart';
import 'slivers/user_home_sliver.dart';

/// 홈 화면
/// 
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 📌 아키텍처 설계 원칙
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 
/// 1. HomePage 책임
///    - Scaffold, SafeArea, CustomScrollView, BlocBuilder만 포함
///    - Column, Expanded, Spacer 사용 ❌
///    - UI 카드 직접 작성 ❌
/// 
/// 2. Sliver 위젯 분리
///    - ExpertHomeSliver: 전문가용 홈 화면 (SliverList 기반)
///    - UserHomeSliver: 일반 사용자용 홈 화면 (SliverList 기반)
/// 
/// 3. 일반 위젯 분리
///    - widgets/home/expert/: 전문가용 카드/섹션 위젯
///    - widgets/home/user/: 일반 사용자용 카드/섹션 위젯
///    - Column, Row, Expanded는 이 파일들에서만 사용
/// 
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isExpert = state is AuthAuthenticated && state.user.isExpert;
                final name = state is AuthAuthenticated ? state.user.name : '회원';

                return CustomScrollView(
                  slivers: [
                    // 전문가 / 일반 사용자에 따라 다른 Sliver 반환
                    if (isExpert)
                      ExpertHomeSliver(
                        name: name,
                        isVerified: false, // TODO: 실제 데이터 연동 필요
                        profileCompletion: 10, // TODO: 실제 데이터 연동 필요
                      )
                    else
                      UserHomeSliver(name: name),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

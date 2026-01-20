import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:law_decode/presentation/blocs/auth/auth_bloc.dart';
import 'package:law_decode/presentation/blocs/auth/auth_state.dart';
import 'package:law_decode/presentation/blocs/expert_dashboard/expert_dashboard_bloc.dart';
import 'package:law_decode/presentation/blocs/expert_dashboard/expert_dashboard_event.dart';
import 'package:law_decode/presentation/blocs/expert_dashboard/expert_dashboard_state.dart';
import 'package:law_decode/presentation/widgets/expert/expert_profile_card.dart';
import 'package:law_decode/presentation/widgets/expert/dashboard_menu_card.dart';
import 'package:law_decode/core/constants/app_colors.dart';
import 'package:law_decode/core/constants/app_sizes.dart';
import 'package:law_decode/core/router/app_router.dart';

/// 전문가 대시보드 페이지
class ExpertDashboardPage extends StatefulWidget {
  const ExpertDashboardPage({super.key});

  @override
  State<ExpertDashboardPage> createState() => _ExpertDashboardPageState();
}

class _ExpertDashboardPageState extends State<ExpertDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<ExpertDashboardBloc>()
          .add(LoadExpertDashboard(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('전문가 대시보드'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
            child: BlocBuilder<ExpertDashboardBloc, ExpertDashboardState>(
              builder: (context, state) {
                if (state is ExpertDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ExpertDashboardNeedsCertification) {
                  return _buildNeedsCertificationView();
                }

                if (state is ExpertDashboardVerificationPending) {
                  return _buildVerificationPendingView();
                }

                if (state is ExpertDashboardLoaded) {
                  return _buildDashboardView(state);
                }

                if (state is ExpertDashboardError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          '오류가 발생했습니다',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(state.message),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadDashboard,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeedsCertificationView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              '전문가 인증이 필요합니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '전문가 대시보드를 이용하려면\n먼저 전문가 인증을 완료해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.expertCertification);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('전문가 인증 시작하기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationPendingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              '인증 심사 중입니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '전문가 인증 심사가 진행 중입니다.\n승인까지 1-2영업일 소요됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardView(ExpertDashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadDashboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전문가 프로필 카드
            ExpertProfileCard(
              account: state.account,
              publicProfile: state.publicProfile,
            ),

            const SizedBox(height: 24),

            // 메뉴 그리드
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                DashboardMenuCard(
                  title: '상담 요청',
                  subtitle: '대기 ${state.waitingCount}건',
                  icon: Icons.chat_bubble_outline,
                  color: AppColors.primary,
                  onTap: () {
                    // TODO: 상담 요청 목록 페이지로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('상담 요청 페이지 준비 중입니다')),
                    );
                  },
                ),
                DashboardMenuCard(
                  title: '나의 일정',
                  subtitle: '예정 ${state.acceptedCount}건',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                  onTap: () {
                    // TODO: 일정 관리 페이지로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('일정 관리 페이지 준비 중입니다')),
                    );
                  },
                ),
                DashboardMenuCard(
                  title: '통계',
                  subtitle: '상담 분석',
                  icon: Icons.bar_chart,
                  color: Colors.green,
                  onTap: () {
                    // TODO: 통계 페이지로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('통계 페이지 준비 중입니다')),
                    );
                  },
                ),
                DashboardMenuCard(
                  title: '게시글 관리',
                  subtitle: '콘텐츠',
                  icon: Icons.article_outlined,
                  color: Colors.purple,
                  onTap: () {
                    // TODO: 게시글 관리 페이지로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('게시글 관리 페이지 준비 중입니다')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/legal_case.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/case/case_bloc.dart';
import '../../blocs/case/case_event.dart';
import '../../blocs/case/case_state.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

/// 내 사건 화면
class MyCasePage extends StatefulWidget {
  const MyCasePage({super.key});

  @override
  State<MyCasePage> createState() => _MyCasePageState();
}

class _MyCasePageState extends State<MyCasePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCases();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCases() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CaseBloc>().add(CaseListRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('내 사건'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<CaseBloc, CaseState>(
            builder: (context, state) {
              int pending = 0, inProgress = 0, completed = 0;
              if (state is CaseListLoaded) {
                pending = state.pendingCases.length;
                inProgress = state.inProgressCases.length;
                completed = state.completedCases.length;
              }
              return TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: '진행중 ($inProgress)'),
                  Tab(text: '대기중 ($pending)'),
                  Tab(text: '완료 ($completed)'),
                ],
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<CaseBloc, CaseState>(
                    builder: (context, state) {
                      if (state is CaseLoading) {
                        return const LoadingWidget(message: '사건을 불러오는 중...');
                      }

                      if (state is CaseError) {
                        return ErrorStateWidget(
                          message: state.message,
                          onRetry: _loadCases,
                        );
                      }

                      if (state is CaseEmpty) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildEmptyList(),
                            _buildEmptyList(),
                            _buildEmptyList(),
                          ],
                        );
                      }

                      if (state is CaseListLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCaseList(state.inProgressCases),
                            _buildCaseList(state.pendingCases),
                            _buildCaseList(state.completedCases),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const BottomNavBar(currentIndex: 1),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.caseInput);
          },
          icon: const Icon(Icons.add),
          label: const Text('새 상담'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyList() {
    return EmptyStateWidget(
      icon: Icons.folder_open_outlined,
      title: '등록된 사건이 없습니다',
      subtitle: '새로운 상담을 시작해보세요',
      buttonText: '새 상담 시작',
      onButtonPressed: () {
        Navigator.pushNamed(context, AppRoutes.caseInput);
      },
    );
  }

  Widget _buildCaseList(List<LegalCase> cases) {
    if (cases.isEmpty) {
      return _buildEmptyList();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadCases(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: cases.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.paddingM),
        itemBuilder: (context, index) {
          final caseItem = cases[index];
          return _buildCaseCard(caseItem);
        },
      ),
    );
  }

  Widget _buildCaseCard(LegalCase caseItem) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: _getStatusColor(caseItem.status).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '${AppRoutes.summary}?id=${caseItem.id}');
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(caseItem.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        caseItem.status.displayName,
                        style: TextStyle(
                          color: _getStatusColor(caseItem.status),
                          fontSize: AppSizes.fontXS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(caseItem.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontXS,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),
                Text(
                  caseItem.title,
                  style: const TextStyle(
                    fontSize: AppSizes.fontL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(caseItem.category),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getCategoryLabel(caseItem.category),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontS,
                      ),
                    ),
                  ],
                ),
                if (caseItem.assignedExpert != null) ...[
                  const SizedBox(height: AppSizes.paddingS),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '담당: ${caseItem.assignedExpert!.name}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontS,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return AppColors.warning;
      case CaseStatus.inProgress:
        return AppColors.info;
      case CaseStatus.completed:
        return AppColors.success;
      case CaseStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'labor':
        return Icons.work_outline;
      case 'tax':
        return Icons.receipt_long_outlined;
      case 'criminal':
        return Icons.gavel_outlined;
      case 'family':
        return Icons.family_restroom_outlined;
      case 'real':
        return Icons.home_work_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'labor':
        return '노동/근로';
      case 'tax':
        return '세금/조세';
      case 'criminal':
        return '형사';
      case 'family':
        return '가사/이혼';
      case 'real':
        return '부동산';
      default:
        return category;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '오늘';
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }
}

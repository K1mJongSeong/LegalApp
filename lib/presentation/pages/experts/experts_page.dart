import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/expert/expert_bloc.dart';
import '../../blocs/expert/expert_event.dart';
import '../../blocs/expert/expert_state.dart';
import '../../widgets/common/expert_card.dart';
import '../../widgets/common/expert_card_new.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

/// 전문가 목록 화면
class ExpertsPage extends StatefulWidget {
  final String? urgency;
  final String? category;

  const ExpertsPage({super.key, this.urgency, this.category});

  @override
  State<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends State<ExpertsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExperts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExperts() {
    context.read<ExpertBloc>().add(
      ExpertListRequested(
        category: widget.category,
        urgency: widget.urgency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('전문가 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
            child: Column(
              children: [
                // 정보 배너
                _buildInfoBanner(),
                // 검색 바
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '전문가 검색...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadExperts();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        context.read<ExpertBloc>().add(ExpertSearchRequested(value));
                      } else {
                        _loadExperts();
                      }
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                // 전문가 목록
                Expanded(
                  child: BlocBuilder<ExpertBloc, ExpertState>(
                    builder: (context, state) {
                      if (state is ExpertLoading) {
                        return const LoadingWidget(message: '전문가를 찾고 있습니다...');
                      }

                      if (state is ExpertError) {
                        return ErrorStateWidget(
                          message: state.message,
                          onRetry: _loadExperts,
                        );
                      }

                      if (state is ExpertEmpty) {
                        return EmptyStateWidget(
                          icon: Icons.person_search_outlined,
                          title: '등록된 전문가가 없습니다',
                          subtitle: '조건에 맞는 전문가가 없습니다.\n다른 조건으로 검색해보세요.',
                          buttonText: '조건 변경',
                          onButtonPressed: _showFilterSheet,
                        );
                      }

                      if (state is ExpertListLoaded) {
                        return RefreshIndicator(
                          onRefresh: () async => _loadExperts(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingM,
                            ),
                            itemCount: state.experts.length,
                            itemBuilder: (context, index) {
                              final expert = state.experts[index];
                              return ExpertCardNew(
                                expert: expert,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '${AppRoutes.confirm}?expertId=${expert.id}',
                                  );
                                },
                                onPhoneConsultation: () {
                                  // TODO: 전화 상담 기능 구현
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('전화 상담 기능은 준비 중입니다')),
                                  );
                                },
                                onVisitConsultation: () {
                                  // TODO: 방문 상담 기능 구현
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('방문 상담 기능은 준비 중입니다')),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '필터',
                style: TextStyle(
                  fontSize: AppSizes.fontXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              const Text('카테고리', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.paddingS),
              Wrap(
                spacing: AppSizes.paddingS,
                children: [
                  _buildFilterChip('전체', null),
                  _buildFilterChip('노동/근로', 'labor'),
                  _buildFilterChip('세금/조세', 'tax'),
                  _buildFilterChip('형사', 'criminal'),
                  _buildFilterChip('가사/이혼', 'family'),
                  _buildFilterChip('부동산', 'real'),
                ],
              ),
              const SizedBox(height: AppSizes.paddingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('적용'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? category) {
    return FilterChip(
      label: Text(label),
      selected: widget.category == category,
      onSelected: (selected) {
        Navigator.pop(context);
        context.read<ExpertBloc>().add(
          ExpertListRequested(
            category: selected ? category : null,
            urgency: widget.urgency,
          ),
        );
      },
    );
  }

  /// 정보 배너 위젯
  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // 연한 파란색
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              '아래 전문가들은 해당 분야를 등록한 전문가들입니다. 상담 여부 및 선택은 사용자님의 판단에 따릅니다.',
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

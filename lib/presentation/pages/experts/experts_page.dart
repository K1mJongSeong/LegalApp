import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/expert.dart';
import '../../../domain/repositories/expert_account_repository.dart';
import '../../../data/repositories/expert_account_repository_impl.dart';
import '../../../data/datasources/expert_account_remote_datasource.dart';
import '../../../domain/repositories/consultation_request_repository.dart';
import '../../../data/repositories/consultation_request_repository_impl.dart';
import '../../../data/datasources/consultation_request_remote_datasource.dart';
import '../../blocs/expert/expert_bloc.dart';
import '../../blocs/expert/expert_event.dart';
import '../../blocs/expert/expert_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/expert_card.dart';
import '../../widgets/common/expert_card_new.dart';
import '../../widgets/common/consultation_booking_modal.dart';
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

class _ExpertsPageState extends State<ExpertsPage> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  List<Expert>? _cachedExperts; // 목록 캐시

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadExperts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 목록 다시 로드
      _loadExperts();
    }
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
                      // ExpertListLoaded 상태일 때 캐시 저장
                      if (state is ExpertListLoaded) {
                        _cachedExperts = state.experts;
                      }

                      // ExpertDetailLoaded 상태일 때 캐시된 목록 사용
                      if (state is ExpertDetailLoaded && _cachedExperts != null) {
                        return RefreshIndicator(
                          onRefresh: () async => _loadExperts(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingM,
                            ),
                            itemCount: _cachedExperts!.length,
                            itemBuilder: (context, index) {
                              final expert = _cachedExperts![index];
                              return ExpertCardNew(
                                expert: expert,
                                onTap: () {
                                  // userId를 사용하여 상세 페이지로 이동
                                  if (expert.userId != null) {
                                    Navigator.pushNamed(
                                      context,
                                      '${AppRoutes.confirm}?userId=${expert.userId}',
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('전문가 정보를 불러올 수 없습니다'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                onPhoneConsultation: () {
                                  _showConsultationBookingModal(
                                    context,
                                    expert: expert,
                                    consultationType: 'phone',
                                    durationMinutes: 15,
                                  );
                                },
                                onVisitConsultation: () {
                                  _showConsultationBookingModal(
                                    context,
                                    expert: expert,
                                    consultationType: 'visit',
                                    durationMinutes: 30,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }

                      if (state is ExpertLoading) {
                        // 로딩 중일 때 캐시된 목록이 있으면 표시
                        if (_cachedExperts != null) {
                          return RefreshIndicator(
                            onRefresh: () async => _loadExperts(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.paddingM,
                              ),
                              itemCount: _cachedExperts!.length,
                              itemBuilder: (context, index) {
                                final expert = _cachedExperts![index];
                                return ExpertCardNew(
                                  expert: expert,
                                  onTap: () {
                                    if (expert.userId != null) {
                                      Navigator.pushNamed(
                                        context,
                                        '${AppRoutes.confirm}?userId=${expert.userId}',
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('전문가 정보를 불러올 수 없습니다'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  },
                                  onPhoneConsultation: () {
                                    _showConsultationBookingModal(
                                      context,
                                      expert: expert,
                                      consultationType: 'phone',
                                      durationMinutes: 15,
                                    );
                                  },
                                  onVisitConsultation: () {
                                    _showConsultationBookingModal(
                                      context,
                                      expert: expert,
                                      consultationType: 'visit',
                                      durationMinutes: 30,
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }
                        return const LoadingWidget(message: '전문가를 찾고 있습니다...');
                      }

                      if (state is ExpertError) {
                        // 에러일 때 캐시된 목록이 있으면 표시
                        if (_cachedExperts != null) {
                          return RefreshIndicator(
                            onRefresh: () async => _loadExperts(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.paddingM,
                              ),
                              itemCount: _cachedExperts!.length,
                              itemBuilder: (context, index) {
                                final expert = _cachedExperts![index];
                                return ExpertCardNew(
                                  expert: expert,
                                  onTap: () {
                                    if (expert.userId != null) {
                                      Navigator.pushNamed(
                                        context,
                                        '${AppRoutes.confirm}?userId=${expert.userId}',
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('전문가 정보를 불러올 수 없습니다'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  },
                                  onPhoneConsultation: () {
                                    _showConsultationBookingModal(
                                      context,
                                      expert: expert,
                                      consultationType: 'phone',
                                      durationMinutes: 15,
                                    );
                                  },
                                  onVisitConsultation: () {
                                    _showConsultationBookingModal(
                                      context,
                                      expert: expert,
                                      consultationType: 'visit',
                                      durationMinutes: 30,
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }
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
                                  // userId를 사용하여 상세 페이지로 이동
                                  if (expert.userId != null) {
                                    Navigator.pushNamed(
                                      context,
                                      '${AppRoutes.confirm}?userId=${expert.userId}',
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('전문가 정보를 불러올 수 없습니다'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                onPhoneConsultation: () {
                                  _showConsultationBookingModal(
                                    context,
                                    expert: expert,
                                    consultationType: 'phone',
                                    durationMinutes: 15,
                                  );
                                },
                                onVisitConsultation: () {
                                  _showConsultationBookingModal(
                                    context,
                                    expert: expert,
                                    consultationType: 'visit',
                                    durationMinutes: 30,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }

                      // 초기 상태일 때 캐시된 목록이 있으면 표시
                      if (_cachedExperts != null) {
                        return RefreshIndicator(
                          onRefresh: () async => _loadExperts(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingM,
                            ),
                            itemCount: _cachedExperts!.length,
                            itemBuilder: (context, index) {
                              final expert = _cachedExperts![index];
                              return ExpertCardNew(
                                expert: expert,
                                onTap: () {
                                  if (expert.userId != null) {
                                    Navigator.pushNamed(
                                      context,
                                      '${AppRoutes.confirm}?userId=${expert.userId}',
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('전문가 정보를 불러올 수 없습니다'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                onPhoneConsultation: () {
                                  _showConsultationBookingModal(
                                    context,
                                    expert: expert,
                                    consultationType: 'phone',
                                    durationMinutes: 15,
                                  );
                                },
                                onVisitConsultation: () {
                                  _showConsultationBookingModal(
                                    context,
                                    expert: expert,
                                    consultationType: 'visit',
                                    durationMinutes: 30,
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

  /// 상담 예약 모달 표시
  void _showConsultationBookingModal(
    BuildContext context, {
    required expert,
    required String consultationType,
    required int durationMinutes,
  }) {
    // 로그인 확인
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (context) => ConsultationBookingModal(
        expertName: expert.name,
        consultationType: consultationType,
        durationMinutes: durationMinutes,
        onConfirm: (scheduledAt) async {
          await _createConsultationRequest(
            context,
            expert: expert,
            consultationType: consultationType,
            durationMinutes: durationMinutes,
            scheduledAt: scheduledAt,
            userId: authState.user.id,
          );
        },
      ),
    );
  }

  /// 상담 요청 생성
  Future<void> _createConsultationRequest(
    BuildContext context, {
    required expert,
    required String consultationType,
    required int durationMinutes,
    required DateTime scheduledAt,
    required String userId,
  }) async {
    try {
      // Expert의 userId로 expertAccountId 조회
      if (expert.userId == null) {
        throw Exception('전문가 정보를 찾을 수 없습니다');
      }

      final expertAccountRepository = ExpertAccountRepositoryImpl(
        ExpertAccountRemoteDataSource(),
      );
      final expertAccount = await expertAccountRepository.getExpertAccountByUserId(expert.userId!);

      if (expertAccount == null) {
        throw Exception('전문가 계정을 찾을 수 없습니다');
      }

      // 상담 요청 생성
      final consultationRequestRepository = ConsultationRequestRepositoryImpl(
        ConsultationRequestRemoteDataSource(),
      );

      final consultationTypeText = consultationType == 'phone' ? '전화' : '방문';
      final title = '${expert.name}님과의 ${durationMinutes}분 ${consultationTypeText}상담';

      await consultationRequestRepository.createConsultationRequest(
        expertAccountId: expertAccount.id,
        expertPublicId: expertAccount.expertPublicId,
        userId: userId,
        title: title,
        scheduledAt: scheduledAt,
        status: 'waiting',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예약 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      rethrow;
    }
  }
}

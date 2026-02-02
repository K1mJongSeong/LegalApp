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
import '../../../domain/repositories/consultation_post_repository.dart';
import '../../../data/repositories/consultation_request_repository_impl.dart';
import '../../../data/repositories/consultation_post_repository_impl.dart';
import '../../../data/datasources/consultation_request_remote_datasource.dart';
import '../../../data/datasources/consultation_post_remote_datasource.dart';
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
  final bool showHomeButton;

  const ExpertsPage({
    super.key,
    this.urgency,
    this.category,
    this.showHomeButton = true,
  });

  @override
  State<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends State<ExpertsPage> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  List<Expert>? _cachedExperts; // 목록 캐시
  String? _latestConsultationPostId; // 최근 작성한 상담 글 ID
  String? _selectedExpertId; // 선택된 전문가 ID
  
  // 필터 상태
  Set<String> _selectedConsultationMethods = {}; // 전화, 채팅, 방문, 이메일
  String? _selectedRegion; // 선호 지역
  String? _experienceSort; // 경력 정렬
  String? _selectedGender; // 성별
  Set<String> _selectedQualifications = {}; // 특수 자격
  Set<String> _selectedExperiences = {}; // 경험

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadExperts();
    _loadLatestConsultationPost();
  }

  /// 최근 작성한 상담 글 조회
  Future<void> _loadLatestConsultationPost() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        final consultationPostRepository = ConsultationPostRepositoryImpl(
          ConsultationPostRemoteDataSource(),
        );
        final latestPost = await consultationPostRepository.getLatestConsultationPostByUserId(
          authState.user.id,
        );
        if (mounted && latestPost != null) {
          setState(() {
            _latestConsultationPostId = latestPost.id;
          });
        }
      } catch (e) {
        debugPrint('최근 상담 글 조회 실패: $e');
      }
    }
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
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated && authState.user.name.isNotEmpty
        ? authState.user.name
        : '회원';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // title: Text('$userName님을 위한 전문가 목록'),
        title: const Text('전문가 목록'),
        leading: widget.showHomeButton
            ? IconButton(
                icon: const Icon(Icons.home),
                // onPressed: () => Navigator.pop(context),
                onPressed: () => _showExitDialog(context),
              )
            : IconButton(
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
                              final isSelected = _selectedExpertId == expert.id.toString();
                              return Column(
                                children: [
                                  ExpertCardNew(
                                    expert: expert,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedExpertId = isSelected ? null : expert.id.toString();
                                      });
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
                                  ),
                                  // 선택된 카드 아래에 버튼 표시
                                  if (isSelected && _latestConsultationPostId != null)
                                    _buildActionButtons(expert),
                                ],
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
                                final isSelected = _selectedExpertId == expert.id.toString();
                                return Column(
                                  children: [
                                    ExpertCardNew(
                                      expert: expert,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedExpertId = isSelected ? null : expert.id.toString();
                                        });
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
                                    ),
                                    // 선택된 카드 아래에 버튼 표시
                                    if (isSelected && _latestConsultationPostId != null)
                                      _buildActionButtons(expert),
                                  ],
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
                                final isSelected = _selectedExpertId == expert.id.toString();
                                return Column(
                                  children: [
                                    ExpertCardNew(
                                      expert: expert,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedExpertId = isSelected ? null : expert.id.toString();
                                        });
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
                                    ),
                                    // 선택된 카드 아래에 버튼 표시
                                    if (isSelected && _latestConsultationPostId != null)
                                      _buildActionButtons(expert),
                                  ],
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
                              final isSelected = _selectedExpertId == expert.id.toString();
                              return Column(
                                children: [
                                  ExpertCardNew(
                                    expert: expert,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedExpertId = isSelected ? null : expert.id.toString();
                                      });
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
                                  ),
                                  // 선택된 카드 아래에 버튼 표시
                                  if (isSelected && _latestConsultationPostId != null)
                                    _buildActionButtons(expert),
                                ],
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


  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('홈으로 이동'),
        // content: Text(_isCaseSaved
        //     ? '홈으로 이동하시겠습니까?\n사건은 \'내 사건\'에서 확인할 수 있습니다.'
        //     : '홈으로 이동하시겠습니까?'),
        content: Text("홈으로 이동하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                    (route) => false,
              );
            },
            child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '필터',
                          style: TextStyle(
                            fontSize: AppSizes.fontXL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedConsultationMethods.clear();
                              _selectedRegion = null;
                              _experienceSort = null;
                              _selectedGender = null;
                              _selectedQualifications.clear();
                              _selectedExperiences.clear();
                            });
                          },
                          child: const Text('초기화'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    
                    // 카테고리
                    _buildFilterSection(
                      title: '카테고리',
                      child: Wrap(
                        spacing: AppSizes.paddingS,
                        runSpacing: AppSizes.paddingS,
                        children: [
                          _buildFilterChip('전체', null),
                          _buildFilterChip('노동/근로', 'labor'),
                          _buildFilterChip('세금/조세', 'tax'),
                          _buildFilterChip('형사', 'criminal'),
                          _buildFilterChip('가사/이혼', 'family'),
                          _buildFilterChip('부동산', 'real'),
                        ],
                      ),
                    ),
                    
                    // 선호하는 상담 방식
                    _buildFilterSection(
                      title: '선호하는 상담 방식',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildToggleButton(
                                  '전화',
                                  _selectedConsultationMethods.contains('phone'),
                                  () {
                                    setModalState(() {
                                      if (_selectedConsultationMethods.contains('phone')) {
                                        _selectedConsultationMethods.remove('phone');
                                      } else {
                                        _selectedConsultationMethods.add('phone');
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              Expanded(
                                child: _buildToggleButton(
                                  '채팅',
                                  _selectedConsultationMethods.contains('chat'),
                                  () {
                                    setModalState(() {
                                      if (_selectedConsultationMethods.contains('chat')) {
                                        _selectedConsultationMethods.remove('chat');
                                      } else {
                                        _selectedConsultationMethods.add('chat');
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          Row(
                            children: [
                              Expanded(
                                child: _buildToggleButton(
                                  '방문',
                                  _selectedConsultationMethods.contains('visit'),
                                  () {
                                    setModalState(() {
                                      if (_selectedConsultationMethods.contains('visit')) {
                                        _selectedConsultationMethods.remove('visit');
                                      } else {
                                        _selectedConsultationMethods.add('visit');
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              Expanded(
                                child: _buildToggleButton(
                                  '이메일',
                                  _selectedConsultationMethods.contains('email'),
                                  () {
                                    setModalState(() {
                                      if (_selectedConsultationMethods.contains('email')) {
                                        _selectedConsultationMethods.remove('email');
                                      } else {
                                        _selectedConsultationMethods.add('email');
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 선호 지역
                    _buildFilterSection(
                      title: '선호 지역',
                      child: DropdownButtonFormField<String>(
                        value: _selectedRegion,
                        decoration: InputDecoration(
                          hintText: '지역을 선택하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical: AppSizes.paddingS,
                          ),
                        ),
                        items: _getRegionList().map((region) {
                          return DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            _selectedRegion = value;
                          });
                        },
                      ),
                    ),
                    
                    // 경력 정렬
                    _buildFilterSection(
                      title: '경력 정렬',
                      child: DropdownButtonFormField<String>(
                        value: _experienceSort,
                        decoration: InputDecoration(
                          hintText: '정렬 방식을 선택하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical: AppSizes.paddingS,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'high', child: Text('경력 높은 순')),
                          DropdownMenuItem(value: 'low', child: Text('경력 낮은 순')),
                          DropdownMenuItem(value: 'none', child: Text('경력 무관')),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            _experienceSort = value;
                          });
                        },
                      ),
                    ),
                    
                    // 성별
                    _buildFilterSection(
                      title: '성별',
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          hintText: '성별을 선택하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical: AppSizes.paddingS,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('남성')),
                          DropdownMenuItem(value: 'female', child: Text('여성')),
                          DropdownMenuItem(value: 'any', child: Text('상관없음')),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                    ),
                    
                    // 특수 자격
                    _buildFilterSection(
                      title: '특수 자격',
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '세무사',
                              _selectedQualifications.contains('tax_accountant'),
                              () {
                                setModalState(() {
                                  if (_selectedQualifications.contains('tax_accountant')) {
                                    _selectedQualifications.remove('tax_accountant');
                                  } else {
                                    _selectedQualifications.add('tax_accountant');
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '노무사',
                              _selectedQualifications.contains('labor_attorney'),
                              () {
                                setModalState(() {
                                  if (_selectedQualifications.contains('labor_attorney')) {
                                    _selectedQualifications.remove('labor_attorney');
                                  } else {
                                    _selectedQualifications.add('labor_attorney');
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '변리사',
                              _selectedQualifications.contains('patent_attorney'),
                              () {
                                setModalState(() {
                                  if (_selectedQualifications.contains('patent_attorney')) {
                                    _selectedQualifications.remove('patent_attorney');
                                  } else {
                                    _selectedQualifications.add('patent_attorney');
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '관세사',
                              _selectedQualifications.contains('customs_broker'),
                              () {
                                setModalState(() {
                                  if (_selectedQualifications.contains('customs_broker')) {
                                    _selectedQualifications.remove('customs_broker');
                                  } else {
                                    _selectedQualifications.add('customs_broker');
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '회계사',
                              _selectedQualifications.contains('accountant'),
                              () {
                                setModalState(() {
                                  if (_selectedQualifications.contains('accountant')) {
                                    _selectedQualifications.remove('accountant');
                                  } else {
                                    _selectedQualifications.add('accountant');
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 경험
                    _buildFilterSection(
                      title: '경험',
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '판사 경험',
                              _selectedExperiences.contains('judge'),
                              () {
                                setModalState(() {
                                  if (_selectedExperiences.contains('judge')) {
                                    _selectedExperiences.remove('judge');
                                  } else {
                                    _selectedExperiences.add('judge');
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '검사 경험',
                              _selectedExperiences.contains('prosecutor'),
                              () {
                                setModalState(() {
                                  if (_selectedExperiences.contains('prosecutor')) {
                                    _selectedExperiences.remove('prosecutor');
                                  } else {
                                    _selectedExperiences.add('prosecutor');
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '경찰 경험',
                              _selectedExperiences.contains('police'),
                              () {
                                setModalState(() {
                                  if (_selectedExperiences.contains('police')) {
                                    _selectedExperiences.remove('police');
                                  } else {
                                    _selectedExperiences.add('police');
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '법원 공무원 경험',
                              _selectedExperiences.contains('court_official'),
                              () {
                                setModalState(() {
                                  if (_selectedExperiences.contains('court_official')) {
                                    _selectedExperiences.remove('court_official');
                                  } else {
                                    _selectedExperiences.add('court_official');
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          SizedBox(
                            width: double.infinity,
                            child: _buildToggleButton(
                              '검찰 공무원 경험',
                              _selectedExperiences.contains('prosecution_official'),
                              () {
                                setModalState(() {
                                  if (_selectedExperiences.contains('prosecution_official')) {
                                    _selectedExperiences.remove('prosecution_official');
                                  } else {
                                    _selectedExperiences.add('prosecution_official');
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingL),
                    
                    // 적용 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                        ),
                        child: const Text('적용'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    String value,
    Set<String> selectedSet,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title),
      value: selectedSet.contains(value),
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: isSelected
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }

  List<String> _getRegionList() {
    return [
      '서울',
      '부산',
      '대구',
      '인천',
      '광주',
      '대전',
      '울산',
      '세종',
      '경기',
      '강원',
      '충북',
      '충남',
      '전북',
      '전남',
      '경북',
      '경남',
      '제주',
    ];
  }

  void _applyFilters() {
    // TODO: 실제 필터 로직 구현 (현재는 카테고리만 지원)
    _loadExperts();
  }

  Widget _buildFilterChip(String label, String? category) {
    final isSelected = widget.category == category;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
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
              // '아래 전문가들은 해당 분야를 등록한 전문가들입니다. 상담 여부 및 선택은 사용자님의 판단에 따릅니다.',
            '현재는 베타서비스이며 등록된 전문가는 가상의 인물로 상담이 불가 합니다. 정식 서비스 오픈 시 알림을 보내드리겠습니다.',
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
          try {
            await _createConsultationRequest(
              context,
              expert: expert,
              consultationType: consultationType,
              durationMinutes: durationMinutes,
              scheduledAt: scheduledAt,
              userId: authState.user.id,
            );
            // 페이지 이동이 있으면 false 반환 (모달을 열어둠)
            // 페이지 이동이 없으면 true 반환 (모달 닫기)
            return false; // 페이지 이동이 있으므로 false 반환
          } catch (e) {
            // 에러 발생 시 true 반환하여 모달 닫기
            return true;
          }
        },
      ),
    );
  }

  /// 액션 버튼 위젯 빌드
  Widget _buildActionButtons(expert) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 사건 요약 전송 및 상담 신청 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToCaseSubmission(expert),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: const Text(
                '사건 요약 전송 및 상담 신청',
                style: TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          // 전문가 프로필 상세보기 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
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
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: const Text(
                '전문가 프로필 상세보기',
                style: TextStyle(
                  fontSize: AppSizes.fontM,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 사건 전송 페이지로 이동
  void _navigateToCaseSubmission(expert) {
    if (_latestConsultationPostId == null || expert.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('상담 글 정보를 찾을 수 없습니다'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.caseSubmission,
      arguments: {
        'consultationPostId': _latestConsultationPostId!,
        'expertUserId': expert.userId!,
        'expertId': expert.id.toString(),
      },
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

      // 최근 작성한 상담 글 조회 (예약 시 연결)
      final consultationPostRepository = ConsultationPostRepositoryImpl(
        ConsultationPostRemoteDataSource(),
      );
      final latestPost = await consultationPostRepository.getLatestConsultationPostByUserId(userId);

      // 상담 요청 생성
      final consultationRequestRepository = ConsultationRequestRepositoryImpl(
        ConsultationRequestRemoteDataSource(),
      );

      final consultationTypeText = consultationType == 'phone' ? '전화' : '방문';
      final title = latestPost != null
          ? latestPost.title
          : '${expert.name}님과의 ${durationMinutes}분 ${consultationTypeText}상담';

      await consultationRequestRepository.createConsultationRequest(
        expertAccountId: expertAccount.id,
        expertPublicId: expertAccount.expertPublicId,
        userId: userId,
        title: title,
        scheduledAt: scheduledAt,
        status: 'waiting',
        consultationPostId: latestPost?.id,
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

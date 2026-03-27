import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http_client;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/gpt_service.dart';
import '../../../core/services/law_api_service.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/case/case_bloc.dart';
import '../../blocs/case/case_event.dart';
import '../../blocs/case/case_state.dart';
import '../../widgets/common/signup_prompt_dialog.dart';
import '../../widgets/common/consultation_post_dialog.dart';
import '../../../core/services/payapp_service.dart';

/// 사건 요약 결과 페이지
class CaseSummaryResultPage extends StatefulWidget {
  final String category;
  final String categoryName;
  final String description;
  final String urgency;
  final List<String> progressItems;
  final String goal;
  final List<String>? consultationMethod;
  final String? preferredRegion;
  final String? expertExperience;
  final String? consultationFee;
  final bool freeConsultation;
  final String? availableTime;
  final bool isPaid;

  const CaseSummaryResultPage({
    super.key,
    required this.category,
    required this.categoryName,
    required this.description,
    required this.urgency,
    this.progressItems = const [],
    this.goal = '',
    this.consultationMethod,
    this.preferredRegion,
    this.expertExperience,
    this.consultationFee,
    this.freeConsultation = false,
    this.availableTime,
    this.isPaid = false,
  });

  @override
  State<CaseSummaryResultPage> createState() => _CaseSummaryResultPageState();
}

class _CaseSummaryResultPageState extends State<CaseSummaryResultPage> {
  final GptService _gptService = GptService();
  final LawApiService _lawApiService = LawApiService();
  CaseSummaryResult? _result;
  bool _isLoading = true;
  String? _error;

  // 법령 API 검색 결과
  List<LawSummary> _lawResults = [];
  Map<String, LawDetail?> _lawDetails = {};
  bool _isLoadingLaws = false;

  // 판례 API 검색 결과
  List<PrecedentSummary> _precedentResults = [];
  bool _isLoadingPrecedents = false;

  // Firebase에서 가져온 실제 전문가 수
  int _realExpertCount = 0;

  // 사건 저장 여부
  bool _isCaseSaved = false;
  String? _savedCaseId;

  // 사건 요약 수정용
  final TextEditingController _summaryController = TextEditingController();
  bool _isEditingSummary = false;

  // 전문가 상담 전 질문 리스트
  List<String> _consultationQuestions = [];
  bool _isLoadingQuestions = false;

  // 각 질문별 새로고침 남은 횟수 (최대 3회)
  List<int> _questionRefreshCounts = [];
  // 각 질문별 로딩 상태
  List<bool> _questionRefreshLoading = [];

  // 결제 완료 여부
  late bool _isSurveyCompleted = widget.isPaid;

  // 결제 요청번호 (PayApp)
  String? _paymentMulNo;

  // 설문조사 문서 ID (콘텐츠 피드백 설문과 연결용)
  String? _surveyDocId;

  @override
  void initState() {
    super.initState();
    // 비회원인 경우 회원가입 유도 팝업 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        _showSignupPrompt();
      } else {
        _analyzCase();
        _loadExpertCount();
      }
    });
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  /// 회원가입 유도 팝업 표시
  void _showSignupPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SignupPromptDialog(),
    ).then((value) {
      // 팝업이 닫힌 후 분석 시작
      _analyzCase();
      _loadExpertCount();
    });
  }
  
  /// 사건을 Firebase에 저장
  Future<void> _saveCase() async {
    if (_isCaseSaved || widget.isPaid) {
      debugPrint('📌 Case already saved, skipping...');
      return;
    }
    
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      debugPrint('❌ User not authenticated, case not saved');
      return;
    }
    
    debugPrint('💾 Saving case to Firebase...');
    debugPrint('   userId: ${authState.user.id}');
    debugPrint('   category: ${widget.category}');
    debugPrint('   urgency: ${widget.urgency}');
    debugPrint('   title: ${widget.categoryName} 상담');
    
    context.read<CaseBloc>().add(CaseCreateRequested(
      userId: authState.user.id,
      category: widget.category,
      urgency: widget.urgency,
      title: '${widget.categoryName} 상담',
      description: widget.description.isEmpty 
          ? '${widget.categoryName} 관련 법률 상담' 
          : widget.description,
    ));
  }

  /// Firebase에서 해당 카테고리의 전문가 수 조회
  Future<void> _loadExpertCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('experts')
          .where('is_available', isEqualTo: true)
          .where('categories', arrayContains: widget.category)
          .get();
      
      setState(() {
        _realExpertCount = snapshot.docs.length;
      });
    } catch (e) {
      // 오류 시 0으로 유지
      debugPrint('Expert count load error: $e');
    }
  }

  Future<void> _analyzCase() async {
    try {
      // 상담 목표 텍스트 변환
      String goalText = '';
      switch (widget.goal) {
        case 'recover_damages':
          goalText = '손해를 최대한 회복하고 싶어요';
          break;
        case 'legal_judgment':
          goalText = '법적 판단을 받아보고 싶어요';
          break;
        case 'amicable_resolution':
          goalText = '원만하게 정리하고 싶어요';
          break;
        case 'consultation_only':
          goalText = '상황 설명과 상담만 원해요';
          break;
        default:
          goalText = '';
      }

      // 사건 진행 상황 텍스트
      String progressText = widget.progressItems.isNotEmpty
          ? '사건 진행 상황: ${widget.progressItems.join(', ')}'
          : '';

      final result = await _gptService.analyzeLegalCase(
        category: widget.categoryName,
        description: widget.description.isEmpty
            ? '${widget.categoryName} 관련 법률 상담이 필요합니다.'
            : widget.description,
        urgency: _getUrgencyText(widget.urgency),
        progressItems: progressText,
        goal: goalText,
      );
      setState(() {
        _result = result;
        _isLoading = false;
        _summaryController.text = result.summary;
      });

      // GPT 분석 완료 후 실제 법령/판례 API 호출
      _loadLawsFromApi();
      _loadPrecedentsFromApi();

      // 전문가 상담 전 질문 리스트 생성
      _loadConsultationQuestions();

      // 분석 완료 후 Firebase에 사건 저장
      _saveCase();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 법령 API에서 관련 법령 검색 (GPT 추출 키워드 사용)
  Future<void> _loadLawsFromApi() async {
    setState(() {
      _isLoadingLaws = true;
    });

    try {
      // GPT가 추출한 키워드 사용, 없으면 카테고리 이름에서 추출
      final keywords = _result?.searchKeywords ?? [];
      debugPrint('🔍 법령 검색 시작');
      debugPrint('   GPT 추출 키워드: $keywords');

      if (keywords.isEmpty) {
        // 키워드가 없으면 카테고리 기반 검색
        final fallbackKeyword = LawApiService.getKeywordFromCategoryName(widget.categoryName);
        debugPrint('   폴백 키워드: $fallbackKeyword');

        final response = await _lawApiService.searchLaws(
          query: fallbackKeyword,
          size: 3,
        );

        setState(() {
          _lawResults = response.results;
          _isLoadingLaws = false;
        });

        for (final law in response.results) {
          _loadLawDetail(law.mst);
        }
        return;
      }

      // 각 키워드로 검색하여 결과 합치기 (중복 제거)
      final Map<String, LawSummary> uniqueLaws = {};

      for (final keyword in keywords.take(3)) { // 최대 3개 키워드만 사용
        debugPrint('   검색 중: $keyword');
        try {
          final response = await _lawApiService.searchLaws(
            query: keyword,
            size: 2, // 키워드당 2개씩
          );

          for (final law in response.results) {
            // mst로 중복 제거
            if (!uniqueLaws.containsKey(law.mst)) {
              uniqueLaws[law.mst] = law;
            }
          }
        } catch (e) {
          debugPrint('   키워드 "$keyword" 검색 실패: $e');
        }
      }

      debugPrint('✅ 법령 검색 완료: ${uniqueLaws.length}건');

      setState(() {
        _lawResults = uniqueLaws.values.take(5).toList(); // 최대 5개
        _isLoadingLaws = false;
      });

      // 각 법령의 상세 정보 (조문) 로드
      for (final law in _lawResults) {
        debugPrint('   - ${law.name} (${law.mst})');
        _loadLawDetail(law.mst);
      }
    } catch (e) {
      debugPrint('❌ 법령 검색 오류: $e');
      setState(() {
        _isLoadingLaws = false;
      });
    }
  }

  /// 법령 상세 정보 (조문) 로드
  Future<void> _loadLawDetail(String mst) async {
    try {
      final detail = await _lawApiService.getLawDetail(mst);
      setState(() {
        _lawDetails[mst] = detail;
      });
    } catch (e) {
      debugPrint('❌ 법령 상세 조회 오류 ($mst): $e');
    }
  }

  /// 판례 API에서 유사 판례 검색 (GPT 추출 키워드 사용)
  Future<void> _loadPrecedentsFromApi() async {
    setState(() {
      _isLoadingPrecedents = true;
    });

    try {
      // GPT가 추출한 키워드 사용, 없으면 카테고리 이름에서 추출
      final keywords = _result?.searchKeywords ?? [];
      debugPrint('🔍 판례 검색 시작');
      debugPrint('   GPT 추출 키워드: $keywords');

      if (keywords.isEmpty) {
        // 키워드가 없으면 카테고리 기반 검색
        final fallbackKeyword = LawApiService.getKeywordFromCategoryName(widget.categoryName);
        debugPrint('   폴백 키워드: $fallbackKeyword');

        final response = await _lawApiService.searchPrecedents(
          query: fallbackKeyword,
          size: 3,
        );

        setState(() {
          _precedentResults = response.results;
          _isLoadingPrecedents = false;
        });
        return;
      }

      // 각 키워드로 검색하여 결과 합치기 (중복 제거)
      final Map<String, PrecedentSummary> uniquePrecedents = {};

      for (final keyword in keywords.take(3)) { // 최대 3개 키워드만 사용
        debugPrint('   검색 중: $keyword');
        try {
          final response = await _lawApiService.searchPrecedents(
            query: keyword,
            size: 2, // 키워드당 2개씩
          );

          for (final prec in response.results) {
            // 사건번호로 중복 제거
            if (!uniquePrecedents.containsKey(prec.caseNumber)) {
              uniquePrecedents[prec.caseNumber] = prec;
            }
          }
        } catch (e) {
          debugPrint('   키워드 "$keyword" 검색 실패: $e');
        }
      }

      debugPrint('✅ 판례 검색 완료: ${uniquePrecedents.length}건');
      for (final prec in uniquePrecedents.values) {
        debugPrint('   - ${prec.caseNumber} (${prec.court})');
      }

      setState(() {
        _precedentResults = uniquePrecedents.values.take(5).toList(); // 최대 5개
        _isLoadingPrecedents = false;
      });
    } catch (e) {
      debugPrint('❌ 판례 검색 오류: $e');
      setState(() {
        _isLoadingPrecedents = false;
      });
    }
  }

  /// 전문가 상담 전 질문 리스트 로드
  Future<void> _loadConsultationQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
    });

    try {
      final questions = await _gptService.generateConsultationQuestions(
        category: widget.categoryName,
        description: widget.description.isEmpty
            ? '${widget.categoryName} 관련 법률 상담이 필요합니다.'
            : widget.description,
        summary: _result?.summary ?? '',
      );

      setState(() {
        _consultationQuestions = questions;
        _isLoadingQuestions = false;
        // 각 질문별 새로고침 횟수 초기화 (3회씩)
        _questionRefreshCounts = List.filled(questions.length, 3);
        _questionRefreshLoading = List.filled(questions.length, false);
      });

      debugPrint('✅ 상담 질문 로드 완료: ${questions.length}개');
    } catch (e) {
      debugPrint('❌ 상담 질문 로드 오류: $e');
      setState(() {
        _isLoadingQuestions = false;
      });
    }
  }

  /// 개별 질문 새로고침
  Future<void> _refreshSingleQuestion(int index) async {
    if (_questionRefreshCounts[index] <= 0) return;
    if (_questionRefreshLoading[index]) return;

    setState(() {
      _questionRefreshLoading[index] = true;
    });

    try {
      final newQuestion = await _gptService.regenerateSingleQuestion(
        category: widget.categoryName,
        description: widget.description.isEmpty
            ? '${widget.categoryName} 관련 법률 상담이 필요합니다.'
            : widget.description,
        summary: _result?.summary ?? '',
        currentQuestion: _consultationQuestions[index],
        questionIndex: index + 1,
      );

      setState(() {
        _consultationQuestions[index] = newQuestion;
        _questionRefreshCounts[index]--;
        _questionRefreshLoading[index] = false;
      });

      debugPrint('✅ 질문 ${index + 1} 새로고침 완료 (남은 횟수: ${_questionRefreshCounts[index]})');
    } catch (e) {
      debugPrint('❌ 질문 새로고침 오류: $e');
      setState(() {
        _questionRefreshLoading[index] = false;
      });
    }
  }

  String _getUrgencyText(String urgency) {
    switch (urgency) {
      case 'urgent':
        return '매우 급함';
      case 'normal':
        return '보통';
      case 'simple':
        return '단순 상담';
      default:
        return '보통';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CaseBloc, CaseState>(
      listener: (context, state) {
        if (state is CaseCreated) {
          setState(() {
            _isCaseSaved = true;
            _savedCaseId = state.legalCase.id;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ 사건이 저장되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: PopScope(
        canPop: false, // 뒤로가기 방지
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _showExitDialog(context);
          }
        },
        child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('사건 요약'),
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 16),
            ),
            onPressed: () => _showExitDialog(context),
          ),
        ),
        body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI가 사건을 요약 중입니다...'),
                ],
              ),
            )
              : _error != null
              ? Center(child: Text('오류: $_error'))
              : _buildContent(),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('홈으로 이동'),
        content: Text(_isCaseSaved 
            ? '홈으로 이동하시겠습니까?\n사건은 \'내 사건\'에서 확인할 수 있습니다.'
            : '홈으로 이동하시겠습니까?'),
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

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI 사건 요약
                _buildSummarySection(),
                const SizedBox(height: AppSizes.paddingL),
                // 관련 법령
                _buildLawsSection(),
                const SizedBox(height: AppSizes.paddingL),
                // 유사 판례
                _buildCasesSection(),
                const SizedBox(height: AppSizes.paddingL),
                // 전문가 상담 전 질문 리스트
                _buildQuestionsSection(),
                const SizedBox(height: AppSizes.paddingL),
                // 추천 전문가
                // _buildExpertsSection(),
                // const SizedBox(height: AppSizes.paddingXL),
              ],
            ),
          ),
        ),
        // 하단 버튼
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 결제 버튼 (결제 미완료 시에만 표시)
              if (!_isSurveyCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _startPayment(),
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text(
                      '결제하고 내용 보기',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(color: AppColors.success, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // 콘텐츠 피드백 버튼 (설문 완료 후에만 표시)
              if (_isSurveyCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showContentFeedbackDialog(),
                    icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                    label: const Text(
                      '추가 설문 작성하고 무료 상담 쿠폰받기!',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // 상담 글 등록 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 상담 글 작성 팝업 표시
                    _showConsultationPostDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                  child: const Text(
                    '상담 글 등록 및 전문가 목록 보기',
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.article_outlined, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    '사건 요약',
                    style: TextStyle(
                      fontSize: AppSizes.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditingSummary = !_isEditingSummary;
                  });
                },
                icon: Icon(_isEditingSummary ? Icons.check : Icons.edit, size: 16),
                label: Text(_isEditingSummary ? '완료' : '수정'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '변경하고 싶은 내용을 자유롭게 수정하세요.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: _isEditingSummary
                ? TextField(
                    controller: _summaryController,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: AppSizes.fontM,
                      height: 1.6,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    _summaryController.text.isEmpty
                        ? (_result?.summary ?? '')
                        : _summaryController.text,
                    style: const TextStyle(
                      fontSize: AppSizes.fontM,
                      height: 1.6,
                    ),
                  ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '위 내용은 사용자가 입력한 정보를 바탕으로 AI가 정리한 것입니다. 법적 판단이나 자문이 아닙니다.',
                    style: TextStyle(
                      fontSize: AppSizes.fontXS,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.success),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '전문가에게 물어보세요',
                  style: TextStyle(
                    fontSize: AppSizes.fontL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '상담 전 아래 질문들을 참고하여 준비하시면 더 효율적인 상담이 가능합니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 블러 처리가 적용되는 질문 리스트 영역
          Stack(
            children: [
              ImageFiltered(
                imageFilter: _isSurveyCompleted
                    ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                    : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Column(
                  children: [
                    if (_isLoadingQuestions)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.paddingM),
                          child: Column(
                            children: [
                              CircularProgressIndicator(strokeWidth: 2),
                              SizedBox(height: 8),
                              Text(
                                '질문 리스트를 생성 중입니다...',
                                style: TextStyle(
                                  fontSize: AppSizes.fontS,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_consultationQuestions.isNotEmpty)
                      ...List.generate(_consultationQuestions.length, (index) {
                        return _buildQuestionCard(index + 1, _consultationQuestions[index]);
                      })
                    else
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        child: Center(
                          child: Text(
                            '질문 리스트를 불러올 수 없습니다.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: AppSizes.fontS,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSizes.paddingS),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingS),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI가 생성한 질문입니다. 본인의 상황에 맞게 수정하여 활용하세요.',
                              style: TextStyle(
                                fontSize: AppSizes.fontXS,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 잠금 오버레이
              if (!_isSurveyCompleted)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('결제를 완료해야 질문 리스트를 확인할 수 있습니다.'),
                          action: SnackBarAction(
                            label: '결제하기',
                            onPressed: () => _startPayment(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.lock, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '결제 후 확인 가능',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, String question) {
    final listIndex = index - 1; // 0-based index
    final refreshCount = listIndex < _questionRefreshCounts.length
        ? _questionRefreshCounts[listIndex]
        : 0;
    final isLoading = listIndex < _questionRefreshLoading.length
        ? _questionRefreshLoading[listIndex]
        : false;
    final isEnabled = refreshCount > 0 && !isLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 질문 카드 영역
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusM),
                    bottomLeft: Radius.circular(AppSizes.radiusM),
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.fontS,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question,
                        style: const TextStyle(
                          fontSize: AppSizes.fontM,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 새로고침 버튼 영역
            GestureDetector(
              onTap: isEnabled ? () => _refreshSingleQuestion(listIndex) : null,
              child: Container(
                width: 48,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.border.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppSizes.radiusM),
                    bottomRight: Radius.circular(AppSizes.radiusM),
                  ),
                  border: Border.all(
                    color: isEnabled
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.success,
                        ),
                      )
                    else
                      Icon(
                        Icons.refresh,
                        size: 20,
                        color: isEnabled
                            ? AppColors.success
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '$refreshCount',
                      style: TextStyle(
                        fontSize: AppSizes.fontXS,
                        fontWeight: FontWeight.bold,
                        color: isEnabled
                            ? AppColors.success
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLawsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                '관련될 수 있는 법령 (일반 정보)',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // API에서 로드한 법령 표시
          if (_isLoadingLaws)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingM),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_lawResults.isNotEmpty)
            ..._lawResults.map((law) => _buildApiLawCard(law))
          else if ((_result?.relatedLaws ?? []).isNotEmpty)
            // API 결과가 없으면 GPT 결과 표시 (폴백)
            ...(_result?.relatedLaws ?? []).map((law) => _buildLawCard(law))
          else
            // 둘 다 없으면 빈 상태 메시지
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Center(
                child: Text(
                  '관련 법령 정보를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontS,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSizes.paddingS),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '제공된 법령 및 판례는 참고 정보이며, 귀하의 사건에 직접 적용된다고 단정할 수 없습니다.',
                    style: TextStyle(
                      fontSize: AppSizes.fontXS,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// API에서 받아온 법령 카드
  Widget _buildApiLawCard(LawSummary law) {
    final detail = _lawDetails[law.mst];
    // 첫 번째 조문 가져오기 (있으면)
    final firstArticle = detail?.articles.isNotEmpty == true
        ? detail!.articles.first
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 영역 (항상 보임)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  law.lawType.isNotEmpty ? law.lawType : '법률',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontXS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  law.name,
                  style: const TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          // 내용 영역 (블러 처리)
          Stack(
            children: [
              // 실제 내용
              ImageFiltered(
                imageFilter: _isSurveyCompleted
                    ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                    : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (firstArticle != null) ...[
                      Text(
                        '${firstArticle.number}${firstArticle.title.isNotEmpty ? ' (${firstArticle.title})' : ''}',
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        firstArticle.content.length > 150
                            ? '${firstArticle.content.substring(0, 150)}...'
                            : firstArticle.content,
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '시행일: ${law.enforcementDate}',
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '소관부처: ${law.department}',
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.paddingS),
                    Row(
                      children: [
                        Text(
                          '법령 원문 보기',
                          style: TextStyle(
                            fontSize: AppSizes.fontS,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
              // 오버레이 (설문 완료 여부에 따라 다른 동작)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _isSurveyCompleted
                      ? () => _showLawDetailPopup(law)
                      : () => _showSurveyRequiredMessage(),
                  child: Container(
                    color: Colors.transparent,
                    child: !_isSurveyCompleted
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 결제 필요 메시지 표시
  void _showSurveyRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('결제를 완료하면 내용을 볼 수 있습니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 법령 상세 팝업 표시
  void _showLawDetailPopup(LawSummary law) {
    final detail = _lawDetails[law.mst];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        law.lawType.isNotEmpty ? law.lawType : '법률',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontXS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        law.name,
                        style: const TextStyle(
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // 조문 목록 (블러 처리)
              Expanded(
                child: Stack(
                  children: [
                    ImageFiltered(
                      imageFilter: _isSurveyCompleted
                          ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                          : ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: detail != null && detail.articles.isNotEmpty
                          ? ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              itemCount: detail.articles.length,
                              itemBuilder: (context, index) {
                                final article = detail.articles[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                                  padding: const EdgeInsets.all(AppSizes.paddingM),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${article.number}${article.title.isNotEmpty ? ' (${article.title})' : ''}',
                                        style: const TextStyle(
                                          fontSize: AppSizes.fontM,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        article.content,
                                        style: TextStyle(
                                          fontSize: AppSizes.fontS,
                                          color: AppColors.textSecondary,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.paddingL),
                                child: Text(
                                  '조문 정보를 불러오는 중...',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                    ),
                    // 자물쇠 오버레이 (설문 미완료 시)
                    if (!_isSurveyCompleted)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.3),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '결제 완료 후 열람 가능',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppSizes.fontS,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // 하단 버튼
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // PDF 다운로드 버튼 (설문 완료 시에만 활성화)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSurveyCompleted && detail != null && detail.articles.isNotEmpty
                              ? () => _downloadLawPdf(law, detail)
                              : null,
                          icon: Icon(_isSurveyCompleted ? Icons.download : Icons.lock, size: 18),
                          label: Text(_isSurveyCompleted ? '전체 내용 PDF 다운' : '결제 완료 후 다운로드 가능'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSurveyCompleted ? AppColors.primary : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 국가법령정보센터 링크 버튼
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: OutlinedButton.icon(
                      //     onPressed: () => _openLawUrl(law.mst, law.name),
                      //     icon: const Icon(Icons.open_in_new, size: 18),
                      //     label: const Text('국가법령정보센터에서 전체 보기'),
                      //     style: OutlinedButton.styleFrom(
                      //       foregroundColor: AppColors.primary,
                      //       side: BorderSide(color: AppColors.primary),
                      //       padding: const EdgeInsets.symmetric(vertical: 12),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 국가법령정보센터 법령 페이지 열기
  Future<void> _openLawUrl(String mst, String lawName) async {
    // 국가법령정보센터 법령 상세 페이지 URL
    final url = Uri.parse('https://www.law.go.kr/법령/${Uri.encodeComponent(lawName)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열 수 없습니다')),
        );
      }
    }
  }

  /// 법령 PDF 다운로드
  Future<void> _downloadLawPdf(LawSummary law, LawDetail detail) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 한글 폰트 로드
      final ttf = await _loadKoreanFont();
      final ttfBold = await _loadKoreanFont(bold: true);

      // PDF 생성
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          maxPages: 200,
          build: (context) => [
            // 제목
            pw.Header(
              level: 0,
              child: pw.Text(
                law.name,
                style: pw.TextStyle(font: ttfBold, fontSize: 20),
              ),
            ),
            pw.SizedBox(height: 10),

            // 기본 정보
            _buildPdfInfoRow('법령 유형', law.lawType, ttf, ttfBold),
            _buildPdfInfoRow('시행일', law.enforcementDate, ttf, ttfBold),
            _buildPdfInfoRow('소관부처', law.department, ttf, ttfBold),
            pw.SizedBox(height: 20),

            // 조문 목록
            pw.Text('조문 내용', style: pw.TextStyle(font: ttfBold, fontSize: 14)),
            pw.SizedBox(height: 10),

            ...detail.articles.map((article) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 15),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${article.number}${article.title.isNotEmpty ? ' (${article.title})' : ''}',
                    style: pw.TextStyle(font: ttfBold, fontSize: 11),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    article.content,
                    style: pw.TextStyle(font: ttf, fontSize: 9, lineSpacing: 3),
                  ),
                ],
              ),
            )),
          ],
        ),
      );

      // 파일 저장
      final output = await getTemporaryDirectory();
      final fileName = '법령_${law.name.replaceAll(RegExp(r'[^\w가-힣]'), '_')}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // 로딩 닫기
      if (mounted) Navigator.pop(context);

      // 공유/저장
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '법령: ${law.name}',
      );
    } catch (e) {
      // 로딩 닫기
      if (mounted) Navigator.pop(context);

      debugPrint('PDF 생성 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF 생성 실패: $e')),
        );
      }
    }
  }

  Widget _buildLawCard(RelatedLaw law) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  law.lawName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontXS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${law.article} (${law.title})',
                  style: const TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            law.content,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: [
              Text(
                '법령 원문 보기',
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCasesSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                '유사 판례',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // API에서 로드한 판례 표시
          if (_isLoadingPrecedents)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingM),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_precedentResults.isNotEmpty)
            ..._precedentResults.map((prec) => _buildApiPrecedentCard(prec))
          else if ((_result?.similarCases ?? []).isNotEmpty)
            // API 결과가 없으면 GPT 결과 표시 (폴백)
            ...(_result?.similarCases ?? []).map((caseItem) => _buildCaseCard(caseItem))
          else
            // 둘 다 없으면 빈 상태 메시지
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Center(
                child: Text(
                  '유사 판례 정보를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontS,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSizes.paddingS),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '제공된 법령 및 판례는 참고 정보이며, 귀하의 사건에 직접 적용된다고 단정할 수 없습니다.',
                    style: TextStyle(
                      fontSize: AppSizes.fontXS,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// API에서 받아온 판례 카드
  Widget _buildApiPrecedentCard(PrecedentSummary prec) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 영역 (항상 보임)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  prec.court.isNotEmpty ? prec.court : '대법원',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontXS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prec.caseNumber,
                  style: const TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          // 내용 영역 (블러 처리)
          Stack(
            children: [
              // 실제 내용
              ImageFiltered(
                imageFilter: _isSurveyCompleted
                    ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                    : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (prec.caseName.isNotEmpty) ...[
                      Text(
                        prec.caseName,
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      prec.summary.isNotEmpty
                          ? (prec.summary.length > 150
                              ? '${prec.summary.substring(0, 150)}...'
                              : prec.summary)
                          : '선고일: ${prec.judgmentDate}',
                      style: TextStyle(
                        fontSize: AppSizes.fontS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Row(
                      children: [
                        Text(
                          '판례 상세보기',
                          style: TextStyle(
                            fontSize: AppSizes.fontS,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
              // 오버레이 (설문 완료 여부에 따라 다른 동작)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _isSurveyCompleted
                      ? () => _showPrecedentDetailPopup(prec)
                      : () => _showSurveyRequiredMessage(),
                  child: Container(
                    color: Colors.transparent,
                    child: !_isSurveyCompleted
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 판례 상세 팝업 표시
  void _showPrecedentDetailPopup(PrecedentSummary prec) {
    if (prec.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('해당 판례의 상세 정보를 조회할 수 없습니다.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: FutureBuilder<PrecedentDetail>(
            future: _lawApiService.getPrecedentDetail(prec.id),
            builder: (context, snapshot) {
              return Column(
                children: [
                  // 드래그 핸들
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                          child: Text(
                            prec.court.isNotEmpty ? prec.court : '대법원',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppSizes.fontXS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prec.caseNumber,
                            style: const TextStyle(
                              fontSize: AppSizes.fontL,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // 판례 내용 (블러 처리)
                  Expanded(
                    child: Stack(
                      children: [
                        ImageFiltered(
                          imageFilter: _isSurveyCompleted
                              ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                              : ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: snapshot.connectionState == ConnectionState.waiting
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('판례 정보를 불러오는 중...'),
                                    ],
                                  ),
                                )
                              : snapshot.hasError
                                  ? Center(
                                      child: Text(
                                        '판례 정보를 불러올 수 없습니다.\n${snapshot.error}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    )
                                  : _buildPrecedentDetailContent(
                                      snapshot.data!,
                                      scrollController,
                                    ),
                        ),
                        // 자물쇠 오버레이 (설문 미완료 시)
                        if (!_isSurveyCompleted)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white.withOpacity(0.3),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lock,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        '결제 완료 후 열람 가능',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppSizes.fontS,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 하단 버튼
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSurveyCompleted && snapshot.hasData
                              ? () => _downloadPrecedentPdf(snapshot.data!)
                              : null,
                          icon: Icon(_isSurveyCompleted ? Icons.download : Icons.lock, size: 18),
                          label: Text(_isSurveyCompleted ? '전체 내용 PDF 다운' : '결제 완료 후 다운로드 가능'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSurveyCompleted ? AppColors.primary : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // 폰트 캐시
  static pw.Font? _cachedFont;
  static pw.Font? _cachedFontBold;

  /// 한글 폰트 로드
  Future<pw.Font> _loadKoreanFont({bool bold = false}) async {
    if (bold && _cachedFontBold != null) return _cachedFontBold!;
    if (!bold && _cachedFont != null) return _cachedFont!;

    try {
      // Google Fonts CDN에서 NotoSansKR 다운로드
      final fontUrl = bold
          ? 'https://fonts.gstatic.com/s/notosanskr/v36/PbyxFmXiEBPT4ITbgNA5Cgms3VYcOA-vvnIzzuozeLTq8H4hfeE.ttf'
          : 'https://fonts.gstatic.com/s/notosanskr/v36/PbyxFmXiEBPT4ITbgNA5Cgms3VYcOA-vvnIzzuoyeLTq8H4hfeE.ttf';

      final response = await http_client.get(Uri.parse(fontUrl));
      if (response.statusCode == 200) {
        final font = pw.Font.ttf(response.bodyBytes.buffer.asByteData());
        if (bold) {
          _cachedFontBold = font;
        } else {
          _cachedFont = font;
        }
        return font;
      }
    } catch (e) {
      debugPrint('폰트 로드 실패: $e');
    }

    // 폴백: 기본 폰트 (한글 미지원)
    return bold ? pw.Font.helveticaBold() : pw.Font.helvetica();
  }

  /// 판례 PDF 다운로드
  Future<void> _downloadPrecedentPdf(PrecedentDetail detail) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 한글 폰트 로드
      final ttf = await _loadKoreanFont();
      final ttfBold = await _loadKoreanFont(bold: true);

      // PDF 생성
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          maxPages: 200,
          build: (context) => [
            // 제목
            pw.Header(
              level: 0,
              child: pw.Text(
                detail.caseNumber,
                style: pw.TextStyle(font: ttfBold, fontSize: 20),
              ),
            ),
            pw.SizedBox(height: 10),

            // 기본 정보
            _buildPdfInfoRow('사건명', detail.caseName, ttf, ttfBold),
            _buildPdfInfoRow('법원', detail.court, ttf, ttfBold),
            _buildPdfInfoRow('사건종류', detail.caseType, ttf, ttfBold),
            _buildPdfInfoRow('선고일', _formatDate(detail.judgmentDate), ttf, ttfBold),
            _buildPdfInfoRow('선고', detail.verdict, ttf, ttfBold),
            _buildPdfInfoRow('판결유형', detail.verdictType, ttf, ttfBold),
            pw.SizedBox(height: 20),

            // 판시사항
            if (detail.holding.isNotEmpty) ...[
              _buildPdfSection('판시사항', detail.holding, ttf, ttfBold),
              pw.SizedBox(height: 15),
            ],

            // 판결요지
            if (detail.summary.isNotEmpty) ...[
              _buildPdfSection('판결요지', detail.summary, ttf, ttfBold),
              pw.SizedBox(height: 15),
            ],

            // 참조조문
            if (detail.refArticles.isNotEmpty) ...[
              _buildPdfSection('참조조문', detail.refArticles, ttf, ttfBold),
              pw.SizedBox(height: 15),
            ],

            // 참조판례
            if (detail.refCases.isNotEmpty) ...[
              _buildPdfSection('참조판례', detail.refCases, ttf, ttfBold),
              pw.SizedBox(height: 15),
            ],

            // 판례내용
            if (detail.content.isNotEmpty) ...[
              _buildPdfSection('판례내용', detail.content, ttf, ttfBold),
            ],
          ],
        ),
      );

      // 파일 저장
      final output = await getTemporaryDirectory();
      final fileName = '판례_${detail.caseNumber.replaceAll(RegExp(r'[^\w가-힣]'), '_')}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // 로딩 닫기
      if (mounted) Navigator.pop(context);

      // 공유/저장
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '판례: ${detail.caseNumber}',
      );
    } catch (e) {
      // 로딩 닫기
      if (mounted) Navigator.pop(context);

      debugPrint('PDF 생성 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF 생성 실패: $e')),
        );
      }
    }
  }

  /// PDF 정보 행
  pw.Widget _buildPdfInfoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    if (value.isEmpty) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 10)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  /// PDF 섹션
  pw.Widget _buildPdfSection(String title, String content, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            content,
            style: pw.TextStyle(font: font, fontSize: 9, lineSpacing: 3),
          ),
        ),
      ],
    );
  }

  /// 판례 상세 내용 위젯
  Widget _buildPrecedentDetailContent(
    PrecedentDetail detail,
    ScrollController scrollController,
  ) {
    final hasContent = detail.holding.isNotEmpty ||
        detail.summary.isNotEmpty ||
        detail.refArticles.isNotEmpty ||
        detail.refCases.isNotEmpty ||
        detail.content.isNotEmpty;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보
          _buildPrecedentInfoRow('사건명', detail.caseName),
          const SizedBox(height: AppSizes.paddingS),
          _buildPrecedentInfoRow('사건종류', detail.caseType),
          const SizedBox(height: AppSizes.paddingS),
          _buildPrecedentInfoRow('선고일', _formatDate(detail.judgmentDate)),
          const SizedBox(height: AppSizes.paddingS),
          _buildPrecedentInfoRow('선고', detail.verdict),
          const SizedBox(height: AppSizes.paddingS),
          _buildPrecedentInfoRow('판결유형', detail.verdictType),
          const SizedBox(height: AppSizes.paddingL),

          if (!hasContent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 40),
                  SizedBox(height: 12),
                  Text(
                    '해당 판례의 상세 내용을 제공받지 못했습니다.\n국가법령정보센터에서 직접 확인해 주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // 판시사항
          if (detail.holding.isNotEmpty) ...[
            _buildPrecedentSection('판시사항', detail.holding),
            const SizedBox(height: AppSizes.paddingL),
          ],

          // 판결요지
          if (detail.summary.isNotEmpty) ...[
            _buildPrecedentSection('판결요지', detail.summary),
            const SizedBox(height: AppSizes.paddingL),
          ],

          // 참조조문
          if (detail.refArticles.isNotEmpty) ...[
            _buildPrecedentSection('참조조문', detail.refArticles),
            const SizedBox(height: AppSizes.paddingL),
          ],

          // 참조판례
          if (detail.refCases.isNotEmpty) ...[
            _buildPrecedentSection('참조판례', detail.refCases),
            const SizedBox(height: AppSizes.paddingL),
          ],

          // 판례내용 (전문)
          if (detail.content.isNotEmpty) ...[
            _buildPrecedentSection('판례내용', detail.content),
            const SizedBox(height: AppSizes.paddingL),
          ],
        ],
      ),
    );
  }

  /// 판례 섹션 위젯
  Widget _buildPrecedentSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  /// 판례 정보 행 위젯
  Widget _buildPrecedentInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.fontS,
            ),
          ),
        ),
      ],
    );
  }

  /// 날짜 포맷팅 (YYYYMMDD → YYYY.MM.DD)
  String _formatDate(String date) {
    if (date.length == 8) {
      return '${date.substring(0, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}';
    }
    return date;
  }

  /// 국가법령정보센터 판례 페이지 열기
  Future<void> _openPrecedentUrl(String precId, String caseNumber) async {
    // 국가법령정보센터 판례 상세 페이지 URL
    // 형식: https://www.law.go.kr/판례/(사건번호)
    final url = Uri.parse('https://www.law.go.kr/판례/(${Uri.encodeComponent(caseNumber)})');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열 수 없습니다')),
        );
      }
    }
  }

  Widget _buildCaseCard(SimilarCase caseItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  caseItem.court,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontXS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                caseItem.caseNumber,
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            caseItem.summary,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: [
              Text(
                '판례 상세보기',
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👨‍💼', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text(
                '추천 전문가',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: AppSizes.fontM,
                color: Colors.black,
              ),
              children: [
                const TextSpan(text: '해당 분야를 전문으로 하는 전문가가 '),
                TextSpan(
                  text: '$_realExpertCount명',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' 있습니다.'),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            _realExpertCount > 0
                ? '${widget.categoryName} 관련 법률에 전문성을 가진 변호사 $_realExpertCount명을 추천합니다. 이들은 ${widget.categoryName} 사건 처리 경험이 풍부합니다.'
                : '현재 해당 분야의 전문가가 등록되어 있지 않습니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// PayApp 결제 시작
  Future<void> _startPayment() async {
    // 로그인 확인
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      showDialog(context: context, builder: (_) => const SignupPromptDialog());
      return;
    }

    final user = authState.user;
    String phone = user.phone ?? '';

    // 전화번호가 없으면 입력받기
    if (phone.isEmpty) {
      final inputPhone = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('전화번호 입력'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '010-0000-0000',
                labelText: '결제 수신 전화번호',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      if (inputPhone == null || inputPhone.isEmpty || !mounted) return;
      phone = inputPhone;
    }

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await PayAppService.requestPayment(
        goodName: '사건 요약 상세 열람 - ${widget.categoryName}',
        price: 1000, // TODO: 실제 금액 설정
        recvPhone: phone.replaceAll('-', ''),
        memo: '로디코드 사건 요약 결제',
        var1: user.id,
      );

      if (!mounted) return;
      Navigator.pop(context); // 로딩 닫기

      if (result.success) {
        _paymentMulNo = result.mulNo;

        // 결제 URL을 브라우저에서 열기
        final uri = Uri.parse(result.payUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          // 결제 완료 확인 다이얼로그
          if (!mounted) return;
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('결제 확인'),
              content: const Text('결제를 완료하셨나요?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('아니오'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('예, 완료했습니다'),
                ),
              ],
            ),
          );

          if (confirmed == true && mounted) {
            // TODO: 추후 Firebase Cloud Functions + feedbackUrl 웹훅으로 서버 검증 전환
            // 현재는 PayApp API에 결제 상태 조회 cmd가 없으므로 사용자 확인 기반으로 처리
            setState(() {
              _isSurveyCompleted = true;
            });

            // Firebase에 결제 상태 저장
            if (_savedCaseId != null) {
              context.read<CaseBloc>().add(CasePaymentUpdated(
                caseId: _savedCaseId!,
                isPaid: true,
              ));
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('결제가 완료되었습니다. 이제 모든 내용을 볼 수 있습니다.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('결제 페이지를 열 수 없습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? '결제 요청에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 설문조사 다이얼로그 표시
  Future<void> _showSurveyDialog() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (context) => const SurveyPage(),
      ),
    );

    // result가 문서 ID인 경우 (설문 완료)
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _isSurveyCompleted = true;
        _surveyDocId = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설문조사를 완료했습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// 콘텐츠 피드백 설문 다이얼로그 표시 (Q2, Q3, Q4, Q5)
  Future<void> _showContentFeedbackDialog() async {
    if (_surveyDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설문조사를 먼저 완료해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ContentFeedbackPage(surveyDocId: _surveyDocId!),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('피드백을 주셔서 감사합니다!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// 상담 글 작성 팝업 표시
  Future<void> _showConsultationPostDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsultationPostDialog(
        // 상담 글 내용 초기값은 GPT 요약이 아니라
        // 사용자가 직접 입력한 사건 상세(description)를 사용
        initialSummary: widget.description,
        category: widget.categoryName,
      ),
    );

    // 작성 성공 시 전문가 목록으로 이동
    if (result == true && mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.experts,
        arguments: {
          'category': widget.category,
          'urgency': widget.urgency,
        },
      );
    }
  }
}

/// 설문조사 페이지
class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 설문 응답 저장 (Q2, Q3, Q4, Q5 제거 - 콘텐츠 피드백 설문으로 분리)
  List<String> _usageReasons = [];
  String _usageReasonOther = ''; // Q1 기타
  String _feltLikeJudgment = '';
  String _judgmentReason = '';
  String _rolePerception = '';
  String _rolePerceptionOther = ''; // Q8 기타
  int _trustRating = 3;
  String _wouldRecommend = '';
  String _recommendReason = '';
  String _improvementSuggestion = '';

  final List<String> _usageReasonOptions = [
    '내 상황이 법적으로 어떤 문제인지 확인하고 싶어서',
    '사건을 정리하고 상담 전 사전 준비를 싶어서',
    '변호사/전문가 상담이 부담스러워서',
    '사건 관련 법률 정보를 빠르게 알고 싶어서',
    '기타',
  ];

  final List<String> _feltLikeJudgmentOptions = [
    '전혀 그렇지 않았다',
    '가끔 그렇게 느껴졌다',
    '판단처럼 느껴졌다',
  ];

  final List<String> _rolePerceptionOptions = [
    '상담 전 상황 정리 및 사전 준비 도구',
    '법률 정보 (법조항,유사판례 & 질문리스트) 탐색 도구',
    '전문가 상담 필요 여부를 판단하는 도구',
    '바로 상담을 연결해주는 서비스',
    '잘 모르겠음',
    '기타',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // 현재 페이지의 필수 항목 검증
    if (!_validateCurrentPage()) {
      return;
    }

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // Page 1: Q1 필수
        if (_usageReasons.isEmpty) {
          _showValidationError('Q1. 사용 이유를 하나 이상 선택해주세요.');
          return false;
        }
        return true;
      case 1: // Page 2: Q6, Q8 필수 (Q7 선택)
        if (_feltLikeJudgment.isEmpty) {
          _showValidationError('Q6. 법적 판단처럼 느껴졌는지 선택해주세요.');
          return false;
        }
        if (_rolePerception.isEmpty) {
          _showValidationError('Q8. 로디코드의 역할에 대해 선택해주세요.');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  bool _validateFinalPage() {
    // Page 3: Q9 (슬라이더 - 기본값 있음), Q10 필수 (Q11, Q12 선택)
    if (_wouldRecommend.isEmpty) {
      _showValidationError('Q10. 추천 의향을 선택해주세요.');
      return false;
    }
    return true;
  }

  void _validateAndSubmit() {
    if (_validateFinalPage()) {
      _submitSurvey();
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isSubmitting = false;

  Future<void> _submitSurvey() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    _formKey.currentState?.save();

    try {
      // 현재 로그인한 사용자 정보 가져오기
      final currentUser = FirebaseAuth.instance.currentUser;

      // Firestore users 컬렉션에서 사용자 이름 가져오기
      String userName = '';
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          userName = userDoc.data()?['name'] ?? '';
        }
      }

      // Firebase에 설문 데이터 저장 (Q2-Q5는 콘텐츠 피드백 설문으로 분리)
      final docRef = await FirebaseFirestore.instance.collection('surveys').add({
        // 사용자 정보
        'user_id': currentUser?.uid ?? 'anonymous',
        'user_email': currentUser?.email ?? '',
        'user_name': userName,
        // 설문 응답
        'q1_usage_reasons': _usageReasons,
        'q1_usage_reasons_other': _usageReasonOther,
        'q6_felt_like_judgment': _feltLikeJudgment,
        'q7_judgment_reason': _judgmentReason,
        'q8_role_perception': _rolePerception,
        'q8_role_perception_other': _rolePerceptionOther,
        'q9_trust_rating': _trustRating,
        'q10_would_recommend': _wouldRecommend,
        'q11_recommend_reason': _recommendReason,
        'q12_improvement_suggestion': _improvementSuggestion,
        'content_feedback_completed': false, // 콘텐츠 피드백 미완료 상태
        'submitted_at': FieldValue.serverTimestamp(),
      });

      debugPrint('설문 제출 완료 - Firebase 저장 성공, 문서 ID: ${docRef.id}');
      if (mounted) {
        Navigator.pop(context, docRef.id); // 문서 ID 반환
      }
    } catch (e) {
      debugPrint('설문 저장 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설문 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('로디코드 설문조사'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, null), // 취소 시 null 반환
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // 진행률 표시
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Text(
                '${_currentPage + 1} / 3',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontS,
                ),
              ),
            ),
            // 설문 내용
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),
            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('이전'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : (_currentPage < 2 ? _nextPage : _validateAndSubmit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_currentPage < 2 ? '다음' : '완료'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설문 안내
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '설문 완료 시 법조항, 유사판례, 질문리스트를 열람할 수 있습니다.',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: AppSizes.fontS,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Q1. 로디코드를 사용하게 된 이유는 무엇인가요? (복수 선택)'),
          const SizedBox(height: 8),
          ..._usageReasonOptions.map((option) => CheckboxListTile(
                title: Text(option, style: const TextStyle(fontSize: AppSizes.fontM)),
                value: _usageReasons.contains(option),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _usageReasons.add(option);
                    } else {
                      _usageReasons.remove(option);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              )),
          // Q1 기타 입력 필드
          if (_usageReasons.contains('기타')) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: '기타 이유를 입력해주세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (value) => _usageReasonOther = value,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Q6. 제공된 정보가 법적 판단처럼 느껴진 적이 있나요?'),
          const SizedBox(height: 8),
          ..._feltLikeJudgmentOptions.map((option) => RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: AppSizes.fontM)),
                value: option,
                groupValue: _feltLikeJudgment,
                onChanged: (value) => setState(() => _feltLikeJudgment = value ?? ''),
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: 16),
          _buildSectionTitle('Q7. 6번에서"판단처럼 느껴졌다" 선택하신 분만 그렇게 느낀 이유를 알려주세요 (선택)'),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: '자유롭게 작성해주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            maxLines: 3,
            onChanged: (value) => _judgmentReason = value,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Q8. 전문가 상담 전 로디코드의 역할은 무엇이라고 생각하시나요?'),
          const SizedBox(height: 8),
          ..._rolePerceptionOptions.map((option) => RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: AppSizes.fontM)),
                value: option,
                groupValue: _rolePerception,
                onChanged: (value) => setState(() => _rolePerception = value ?? ''),
                contentPadding: EdgeInsets.zero,
              )),
          // Q8 기타 입력 필드
          if (_rolePerception == '기타') ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: '기타 의견을 입력해주세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (value) => _rolePerceptionOther = value,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Q9. 로디코드를 통해 제공된 정보는 얼마나 신뢰할 수 있다고 느끼셨나요?'),
          const SizedBox(height: 8),
          _buildRatingSlider(
            value: _trustRating,
            onChanged: (value) => setState(() => _trustRating = value.round()),
            minLabel: '전혀 신뢰 안됨',
            maxLabel: '매우 신뢰됨',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Q10. 법률 문제에 빠진 지인에게 로디코드를 추천할 의향이 있나요?'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('있음'),
                  value: '있음',
                  groupValue: _wouldRecommend,
                  onChanged: (value) => setState(() => _wouldRecommend = value ?? ''),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('없음'),
                  value: '없음',
                  groupValue: _wouldRecommend,
                  onChanged: (value) => setState(() => _wouldRecommend = value ?? ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Q11. 추천 또는 비추천 이유가 있다면 자유롭게 적어주세요.'),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: '자유롭게 작성해주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            maxLines: 2,
            onSaved: (value) => _recommendReason = value ?? '',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Q12. 이용하면서 불편했거나 개선이 또는 추가 되었으면 하는 기능이 있다면 자세히 알려주세요.'),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: '바라는 점이 있다면 알려주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            maxLines: 3,
            onSaved: (value) => _improvementSuggestion = value ?? '',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_open, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '설문 완료 시 법조항, 유사판례, 질문리스트를 열람할 수 있습니다!',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRatingSlider({
    required int value,
    required ValueChanged<double> onChanged,
    required String minLabel,
    required String maxLabel,
  }) {
    return Column(
      children: [
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: TextStyle(fontSize: AppSizes.fontXS, color: AppColors.textSecondary)),
            Text('$value점', style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.bold, color: AppColors.primary)),
            Text(maxLabel, style: TextStyle(fontSize: AppSizes.fontXS, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

/// 콘텐츠 피드백 설문 페이지 (Q2, Q3, Q4, Q5)
class ContentFeedbackPage extends StatefulWidget {
  final String surveyDocId;

  const ContentFeedbackPage({super.key, required this.surveyDocId});

  @override
  State<ContentFeedbackPage> createState() => _ContentFeedbackPageState();
}

class _ContentFeedbackPageState extends State<ContentFeedbackPage> {
  final _formKey = GlobalKey<FormState>();

  // 설문 응답 저장
  int _helpfulnessRating = 3; // Q2
  String _lawExplanation = ''; // Q3
  String _lawExplanationOther = '';
  String _precedentHelp = ''; // Q4
  String _precedentHelpOther = '';
  int _questionListRating = 3; // Q5

  final List<String> _lawExplanationOptions = [
    '이해하기 쉬웠다',
    '대략적인 맥락을 파악하는 데 도움이 됐다',
    '정보는 있었지만 어렵게 느껴졌다',
    '잘 이해되지 않았다',
    '기타',
  ];

  final List<String> _precedentHelpOptions = [
    '내 상황이 특이한지 아닌지 판단',
    '나와 비슷한 사건이 실제로 다뤄졌다는 점',
    '전문가 상담 전에 질문을 정리',
    '큰 도움은 없었다',
    '기타',
  ];

  bool _isSubmitting = false;

  bool _validateFeedback() {
    // Q2, Q5는 슬라이더 (기본값 있음) - 항상 유효
    // Q3, Q4는 라디오 버튼 - 필수 선택
    if (_lawExplanation.isEmpty) {
      _showValidationError('Q3. 법조항 방식에 대해 선택해주세요.');
      return false;
    }
    if (_precedentHelp.isEmpty) {
      _showValidationError('Q4. 유사 판례 도움에 대해 선택해주세요.');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (_isSubmitting) return;

    // 필수 항목 검증
    if (!_validateFeedback()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _formKey.currentState?.save();

    try {
      // 기존 설문 문서에 콘텐츠 피드백 데이터 추가 (업데이트)
      await FirebaseFirestore.instance
          .collection('surveys')
          .doc(widget.surveyDocId)
          .update({
        'q2_helpfulness_rating': _helpfulnessRating,
        'q3_law_explanation': _lawExplanation,
        'q3_law_explanation_other': _lawExplanationOther,
        'q4_precedent_help': _precedentHelp,
        'q4_precedent_help_other': _precedentHelpOther,
        'q5_question_list_rating': _questionListRating,
        'content_feedback_completed': true,
        'content_feedback_at': FieldValue.serverTimestamp(),
      });

      debugPrint('콘텐츠 피드백 제출 완료 - 기존 문서 업데이트 성공');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('피드백 저장 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('피드백 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('내용 피드백'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 안내 메시지
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '법조항, 판례, 질문리스트에 대한 피드백을 남겨주세요!\n설문 완료 시, 추첨을 통해 무료 상담 쿠폰 지급 (정식 출시 후 지급 예정)',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: AppSizes.fontS,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Q2
                    _buildSectionTitle('Q2. 사건 요약 결과, 법조항, 유사 판례 및 질문리스트를 통해 본인의 상황을 이해하는 데 도움이 되었나요?'),
                    const SizedBox(height: 8),
                    _buildRatingSlider(
                      value: _helpfulnessRating,
                      onChanged: (value) => setState(() => _helpfulnessRating = value.round()),
                      minLabel: '전혀 도움 안됨',
                      maxLabel: '매우 도움됨',
                    ),
                    const SizedBox(height: 24),

                    // Q3
                    _buildSectionTitle('Q3. 관련 법조항을 보여주는 방식은 어떻게 느끼셨나요?'),
                    const SizedBox(height: 8),
                    ..._lawExplanationOptions.map((option) => RadioListTile<String>(
                          title: Text(option, style: const TextStyle(fontSize: AppSizes.fontM)),
                          value: option,
                          groupValue: _lawExplanation,
                          onChanged: (value) => setState(() => _lawExplanation = value ?? ''),
                          contentPadding: EdgeInsets.zero,
                        )),
                    if (_lawExplanation == '기타') ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: '기타 의견을 입력해주세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onChanged: (value) => _lawExplanationOther = value,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Q4
                    _buildSectionTitle('Q4. 유사 판례 정보는 어떤 부분으로 도움이 되었나요?'),
                    const SizedBox(height: 8),
                    ..._precedentHelpOptions.map((option) => RadioListTile<String>(
                          title: Text(option, style: const TextStyle(fontSize: AppSizes.fontM)),
                          value: option,
                          groupValue: _precedentHelp,
                          onChanged: (value) => setState(() => _precedentHelp = value ?? ''),
                          contentPadding: EdgeInsets.zero,
                        )),
                    if (_precedentHelp == '기타') ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: '기타 의견을 입력해주세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onChanged: (value) => _precedentHelpOther = value,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Q5
                    _buildSectionTitle('Q5. 질문리스트가 얼마나 필요하다고 느끼셨나요?'),
                    const SizedBox(height: 8),
                    _buildRatingSlider(
                      value: _questionListRating,
                      onChanged: (value) => setState(() => _questionListRating = value.round()),
                      minLabel: '전혀 필요 없음',
                      maxLabel: '매우 필요함',
                    ),
                  ],
                ),
              ),
            ),
            // 제출 버튼
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '피드백 제출하기',
                          style: TextStyle(
                            fontSize: AppSizes.fontM,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRatingSlider({
    required int value,
    required ValueChanged<double> onChanged,
    required String minLabel,
    required String maxLabel,
  }) {
    return Column(
      children: [
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: AppColors.warning,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: TextStyle(fontSize: AppSizes.fontXS, color: AppColors.textSecondary)),
            Text('$value점', style: TextStyle(fontSize: AppSizes.fontM, fontWeight: FontWeight.bold, color: AppColors.warning)),
            Text(maxLabel, style: TextStyle(fontSize: AppSizes.fontXS, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

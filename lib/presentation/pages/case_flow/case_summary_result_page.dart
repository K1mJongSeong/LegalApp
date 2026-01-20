import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/gpt_service.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/case/case_bloc.dart';
import '../../blocs/case/case_event.dart';
import '../../blocs/case/case_state.dart';
import '../../widgets/common/signup_prompt_dialog.dart';
import '../../widgets/common/consultation_post_dialog.dart';

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
  });

  @override
  State<CaseSummaryResultPage> createState() => _CaseSummaryResultPageState();
}

class _CaseSummaryResultPageState extends State<CaseSummaryResultPage> {
  final GptService _gptService = GptService();
  CaseSummaryResult? _result;
  bool _isLoading = true;
  String? _error;
  
  // Firebase에서 가져온 실제 전문가 수
  int _realExpertCount = 0;
  
  // 사건 저장 여부
  bool _isCaseSaved = false;
  String? _savedCaseId;
  
  // 사건 요약 수정용
  final TextEditingController _summaryController = TextEditingController();
  bool _isEditingSummary = false;

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
    if (_isCaseSaved) {
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
      
      // 분석 완료 후 Firebase에 사건 저장
      _saveCase();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
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
          child: SizedBox(
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
          ...(_result?.relatedLaws ?? []).map((law) => _buildLawCard(law)),
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
          ...(_result?.similarCases ?? []).map((caseItem) => _buildCaseCard(caseItem)),
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

  /// 상담 글 작성 팝업 표시
  void _showConsultationPostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsultationPostDialog(
        // 상담 글 내용 초기값은 GPT 요약이 아니라
        // 사용자가 직접 입력한 사건 상세(description)를 사용
        initialSummary: widget.description,
        category: widget.categoryName,
      ),
    );
  }
}




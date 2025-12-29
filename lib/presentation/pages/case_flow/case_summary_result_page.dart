import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/gpt_service.dart';
import '../../../core/router/app_router.dart';

/// 사건 요약 결과 페이지
class CaseSummaryResultPage extends StatefulWidget {
  final String category;
  final String categoryName;
  final String description;
  final String urgency;

  const CaseSummaryResultPage({
    super.key,
    required this.category,
    required this.categoryName,
    required this.description,
    required this.urgency,
  });

  @override
  State<CaseSummaryResultPage> createState() => _CaseSummaryResultPageState();
}

class _CaseSummaryResultPageState extends State<CaseSummaryResultPage> {
  final GptService _gptService = GptService();
  CaseSummaryResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyzCase();
  }

  Future<void> _analyzCase() async {
    try {
      final result = await _gptService.analyzeLegalCase(
        category: widget.categoryName,
        description: widget.description.isEmpty 
            ? '${widget.categoryName} 관련 법률 상담이 필요합니다.' 
            : widget.description,
        urgency: _getUrgencyText(widget.urgency),
      );
      setState(() {
        _result = result;
        _isLoading = false;
      });
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
    return PopScope(
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
                  Text('AI가 사건을 분석 중입니다...'),
                ],
              ),
            )
              : _error != null
              ? Center(child: Text('오류: $_error'))
              : _buildContent(),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('홈으로 이동'),
        content: const Text('홈으로 이동하시겠습니까?\n분석 결과는 저장되지 않습니다.'),
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
                _buildExpertsSection(),
                const SizedBox(height: AppSizes.paddingXL),
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
                Navigator.pushNamed(context, AppRoutes.experts);
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
                '전문가 목록 보기',
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
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('수정'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Text(
              _result?.summary ?? '',
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
              Text(
                '${law.article} (${law.title})',
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.bold,
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
                  text: '${_result?.expertCount ?? 0}명',
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
            _result?.expertDescription ?? '아래 전문가들이 가장 적합할 것으로 예상됩니다. 상담 여부 및 선택은 사용자의 판단에 따릅니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}




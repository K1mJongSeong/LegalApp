import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// 사건 상세 입력 페이지
class CaseDetailInputPage extends StatefulWidget {
  final String category;
  final String categoryName;
  final List<String> progressItems;

  const CaseDetailInputPage({
    super.key,
    required this.category,
    required this.categoryName,
    this.progressItems = const [],
  });

  @override
  State<CaseDetailInputPage> createState() => _CaseDetailInputPageState();
}

class _CaseDetailInputPageState extends State<CaseDetailInputPage> {
  final _descriptionController = TextEditingController();
  final int _minLength = 20;
  final int _maxLength = 2000;

  /// 입력된 텍스트의 유효한 길이를 반환 (공백 제거 후)
  int get _validTextLength => _descriptionController.text.trim().length;

  /// 최소 글자 수 조건을 만족하는지 확인
  bool get _isValidInput => _validTextLength >= _minLength;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('사건 상세 입력'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    const Text(
                      '사건에 대해 상세히 설명해주세요',
                      style: TextStyle(
                        fontSize: AppSizes.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          color: AppColors.textSecondary,
                        ),
                        children: const [
                          TextSpan(
                            text: '언제',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(text: ', '),
                          TextSpan(
                            text: '어디서',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(text: ', '),
                          TextSpan(
                            text: '누가',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(text: ', '),
                          TextSpan(
                            text: '무엇을',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(text: ', '),
                          TextSpan(
                            text: '어떻게',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(text: ', '),
                          TextSpan(
                            text: '왜',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(text: '에 대해 구체적으로 작성할수록 더 정확한 정보를 받을 수 있습니'),
                          TextSpan(
                            text: '다',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      '최소 ${_minLength}자 이상 입력해주세요',
                      style: TextStyle(
                        fontSize: AppSizes.fontS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    // 입력 필드
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        border: Border.all(
                          color: !_isValidInput && _descriptionController.text.isNotEmpty
                              ? AppColors.warning
                              : AppColors.border,
                        ),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 10,
                        maxLength: _maxLength,
                        decoration: InputDecoration(
                          hintText:
                              '예시: 2024년 1월 15일, 회사에서 급여를 3개월째 받지 못했습니다. 사장님께 여러 번 말씀드렸지만...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(AppSizes.paddingM),
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 최소 글자 수 안내
                        if (!_isValidInput && _descriptionController.text.isNotEmpty)
                          Text(
                            '최소 ${_minLength}자 이상 입력해주세요 (현재: ${_validTextLength}자)',
                            style: TextStyle(
                              fontSize: AppSizes.fontS,
                              color: AppColors.warning,
                            ),
                          )
                        else if (!_isValidInput)
                          Text(
                            '최소 ${_minLength}자 이상 입력해주세요',
                            style: TextStyle(
                              fontSize: AppSizes.fontS,
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        // 글자 수 표시
                        Text(
                          '${_validTextLength} / ${_maxLength}자',
                          style: TextStyle(
                            fontSize: AppSizes.fontS,
                            color: !_isValidInput
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    // 작성 팁
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: AppColors.warning, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                '작성 팁',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.fontM,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          _buildTipItem('시간 순서대로 작성하면 이해가 쉬워요'),
                          _buildTipItem('증거 자료가 있다면 언급해주세요'),
                          _buildTipItem('상대방과의 대화 내용도 도움이 돼요'),
                        ],
                      ),
                    ),
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
                  onPressed: _isValidInput
                      ? () {
                          // 추가 검증 (안전장치)
                          if (!_isValidInput) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '최소 ${_minLength}자 이상 입력해주세요. (현재: ${_validTextLength}자)'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            AppRoutes.consultationGoal,
                            arguments: {
                              'category': widget.category,
                              'categoryName': widget.categoryName,
                              'progressItems': widget.progressItems,
                              'description': _descriptionController.text.trim(),
                            },
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidInput
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '다음',
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

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(color: AppColors.primary),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// 사건 진행 상황 페이지
class CaseProgressPage extends StatefulWidget {
  final String category;
  final String categoryName;

  const CaseProgressPage({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<CaseProgressPage> createState() => _CaseProgressPageState();
}

class _CaseProgressPageState extends State<CaseProgressPage> {
  final List<String> _selectedItems = [];

  final List<String> _progressOptions = [
    '상대방 측에서 고소장이 접수됨',
    '경찰/수사기관에서 출석 요구를 받음',
    '내용증명을 발송했거나 받음',
    '이미 합의 요청을 받음',
    '불합리하고 억울한 상황이라고 느껴짐',
    '상대방과 연락이 끊김',
    '아직 공식적인 절차는 없음',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('사건 진행 상황'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행 단계 표시
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              color: AppColors.surface,
              child: Row(
                children: [
                  Text(
                    '2/5단계',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '현재 어떤 상황인가요?',
                      style: TextStyle(
                        fontSize: AppSizes.fontXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      '해당되는 항목을 모두 선택해주세요',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    ..._progressOptions.map((option) => _buildSelectableItem(option)),
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
                  onPressed: _selectedItems.isEmpty
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.caseDetailInput,
                            arguments: {
                              'category': widget.category,
                              'categoryName': widget.categoryName,
                              'progressItems': _selectedItems,
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
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

  Widget _buildSelectableItem(String option) {
    final isSelected = _selectedItems.contains(option);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedItems.remove(option);
          } else {
            _selectedItems.add(option);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}










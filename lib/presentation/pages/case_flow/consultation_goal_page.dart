import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// 상담 목표 선택 페이지
class ConsultationGoalPage extends StatefulWidget {
  final String category;
  final String categoryName;
  final List<String> progressItems;
  final String description;

  const ConsultationGoalPage({
    super.key,
    required this.category,
    required this.categoryName,
    this.progressItems = const [],
    this.description = '',
  });

  @override
  State<ConsultationGoalPage> createState() => _ConsultationGoalPageState();
}

class _ConsultationGoalPageState extends State<ConsultationGoalPage> {
  String? _selectedGoal;

  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'recover_damages',
      'title': '손해를 최대한 회복하고 싶어요',
      'subtitle': '금전적 손해배상, 보상금 회수 등',
      'icon': Icons.favorite_outline,
    },
    {
      'id': 'legal_judgment',
      'title': '법적 판단을 받아보고 싶어요',
      'subtitle': '법리적 판단, 권리 여부 검토',
      'icon': Icons.balance_outlined,
    },
    {
      'id': 'amicable_resolution',
      'title': '원만하게 정리하고 싶어요',
      'subtitle': '합의, 조정, 원만한 종결',
      'icon': Icons.handshake_outlined,
    },
    {
      'id': 'consultation_only',
      'title': '상황 설명과 상담만 원해요',
      'subtitle': '전문가 의견 청취, 정보 수집',
      'icon': Icons.chat_bubble_outline,
    },
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
        title: const Text('상담 목표 선택'),
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
                    '4/5단계',
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
                      '현재 상황에서 가장 중요하게 생각하는 방향을 선택해주세요',
                      style: TextStyle(
                        fontSize: AppSizes.fontXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      '이에 따라 적절한 전문가를 선택할 수 있습니다',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    ..._goals.map((goal) => _buildGoalCard(goal)),
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
                  onPressed: _selectedGoal == null
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.consultationCondition,
                            arguments: {
                              'category': widget.category,
                              'categoryName': widget.categoryName,
                              'progressItems': widget.progressItems,
                              'description': widget.description,
                              'goal': _selectedGoal!,
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

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final isSelected = _selectedGoal == goal['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = goal['id'] as String;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(
                goal['icon'] as IconData,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['title'] as String,
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal['subtitle'] as String,
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}










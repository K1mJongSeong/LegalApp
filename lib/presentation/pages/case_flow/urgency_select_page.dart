import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// 긴급도 선택 페이지
class UrgencySelectPage extends StatefulWidget {
  final String category;
  final String categoryName;
  final String description;

  const UrgencySelectPage({
    super.key,
    required this.category,
    required this.categoryName,
    required this.description,
  });

  @override
  State<UrgencySelectPage> createState() => _UrgencySelectPageState();
}

class _UrgencySelectPageState extends State<UrgencySelectPage> {
  String? _selectedUrgency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('긴급도 선택'),
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
                    const Text(
                      '얼마나 급하신가요?',
                      style: TextStyle(
                        fontSize: AppSizes.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      '상황의 긴급도를 선택하시면 적합한 전문가를 우선적으로 추천해드려요',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    _buildUrgencyOption(
                      'urgent',
                      Icons.error_outline,
                      '매우 급함',
                      '즉시 대응이 필요한 상황',
                      AppColors.error,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildUrgencyOption(
                      'normal',
                      Icons.access_time,
                      '보통',
                      '1-2주 내 상담이 필요함',
                      AppColors.warning,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildUrgencyOption(
                      'simple',
                      Icons.chat_bubble_outline,
                      '단순 상담',
                      '정보만 알아보고 싶음',
                      AppColors.textSecondary,
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
                  onPressed: _selectedUrgency != null
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/case-summary-result',
                            arguments: {
                              'category': widget.category,
                              'categoryName': widget.categoryName,
                              'description': widget.description,
                              'urgency': _selectedUrgency,
                            },
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
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

  Widget _buildUrgencyOption(
    String value,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    final isSelected = _selectedUrgency == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUrgency = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}





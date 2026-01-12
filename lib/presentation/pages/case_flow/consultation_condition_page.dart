import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// 상담 조건 설정 페이지
class ConsultationConditionPage extends StatefulWidget {
  final String category;
  final String categoryName;
  final List<String> progressItems;
  final String description;
  final String goal;

  const ConsultationConditionPage({
    super.key,
    required this.category,
    required this.categoryName,
    this.progressItems = const [],
    this.description = '',
    required this.goal,
  });

  @override
  State<ConsultationConditionPage> createState() => _ConsultationConditionPageState();
}

class _ConsultationConditionPageState extends State<ConsultationConditionPage> {
  final List<String> _selectedMethods = [];
  String? _selectedRegion;
  String? _selectedExperience;
  String? _selectedFee;
  bool _freeConsultation = false;
  String? _selectedTime;

  final List<String> _consultationMethods = ['전화', '채팅', '방문'];
  final List<String> _regions = [
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '광주',
    '대전',
    '울산',
    '세종',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];
  final List<String> _experiences = [
    '1년 이상',
    '3년 이상',
    '5년 이상',
    '10년 이상',
    '20년 이상',
  ];
  final List<String> _fees = [
    '무료',
    '5만원 이하',
    '10만원 이하',
    '20만원 이하',
    '30만원 이하',
    '상관없음',
  ];
  final List<String> _times = [
    '오전 (9시~12시)',
    '오후 (12시~18시)',
    '저녁 (18시~21시)',
    '상관없음',
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
        title: const Text('상담 조건 설정'),
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
                    '5/7단계',
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
                      '상담 조건을 설정해주세요',
                      style: TextStyle(
                        fontSize: AppSizes.fontXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      '설정하신 조건은 참고 자료입니다. 모두 선택사항입니다.',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    // 선호하는 상담 방식
                    _buildSection(
                      title: '선호하는 상담 방식',
                      isOptional: true,
                      child: Column(
                        children: _consultationMethods.map((method) {
                          final isSelected = _selectedMethods.contains(method);
                          return _buildCheckboxItem(
                            method,
                            isSelected,
                            () {
                              setState(() {
                                if (isSelected) {
                                  _selectedMethods.remove(method);
                                } else {
                                  _selectedMethods.add(method);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    // 선호 지역
                    _buildSection(
                      title: '선호 지역',
                      isOptional: true,
                      child: _buildDropdown(
                        value: _selectedRegion,
                        hint: '지역을 선택해주세요',
                        items: _regions,
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    // 전문가 경력 범위
                    _buildSection(
                      title: '전문가 경력 범위',
                      isOptional: true,
                      child: _buildDropdown(
                        value: _selectedExperience,
                        hint: '경력을 선택해주세요',
                        items: _experiences,
                        onChanged: (value) {
                          setState(() {
                            _selectedExperience = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    // 상담비 범위
                    _buildSection(
                      title: '상담비 범위',
                      isOptional: true,
                      child: _buildDropdown(
                        value: _selectedFee,
                        hint: '금액을 선택해주세요',
                        items: _fees,
                        onChanged: (value) {
                          setState(() {
                            _selectedFee = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    // 무료 상담 희망
                    _buildSection(
                      title: '무료 상담 희망',
                      isOptional: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '무료 상담 가능한 전문가만 표시됩니다',
                            style: TextStyle(
                              fontSize: AppSizes.fontS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          Row(
                            children: [
                              Checkbox(
                                value: _freeConsultation,
                                onChanged: (value) {
                                  setState(() {
                                    _freeConsultation = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              const Text('무료 상담 희망'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    // 상담 가능 시간대
                    _buildSection(
                      title: '상담 가능 시간대',
                      isOptional: true,
                      child: _buildDropdown(
                        value: _selectedTime,
                        hint: '시간을 선택해주세요',
                        items: _times,
                        onChanged: (value) {
                          setState(() {
                            _selectedTime = value;
                          });
                        },
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
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.caseSummaryResult,
                      arguments: {
                        'category': widget.category,
                        'categoryName': widget.categoryName,
                        'progressItems': widget.progressItems,
                        'description': widget.description,
                        'goal': widget.goal,
                        'consultationMethod': _selectedMethods,
                        'preferredRegion': _selectedRegion,
                        'expertExperience': _selectedExperience,
                        'consultationFee': _selectedFee,
                        'freeConsultation': _freeConsultation,
                        'availableTime': _selectedTime,
                        'urgency': 'normal', // 기본값으로 설정
                      },
                    );
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

  Widget _buildSection({
    required String title,
    required bool isOptional,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isOptional) ...[
                const SizedBox(width: AppSizes.paddingS),
                Text(
                  '(선택)',
                  style: TextStyle(
                    fontSize: AppSizes.fontS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}


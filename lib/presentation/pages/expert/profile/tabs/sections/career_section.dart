import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/career.dart';

/// 경력사항 섹션
class CareerSection extends StatefulWidget {
  const CareerSection({super.key});

  @override
  State<CareerSection> createState() => _CareerSectionState();
}

class _CareerSectionState extends State<CareerSection> {
  List<CareerItem> _careerItems = [CareerItem()];

  // 년도 옵션 (1997~2026)
  List<int> get _yearOptions {
    return List.generate(2026 - 1997 + 1, (index) => 1997 + index);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '경력사항',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 경력 항목들
                ...List.generate(_careerItems.length, (index) {
                  return _buildCareerItem(index);
                }),
                const SizedBox(height: AppSizes.paddingL),
                // 항목추가/삭제 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addCareerItem,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: const Text(
                          '항목추가',
                          style: TextStyle(
                            fontSize: AppSizes.fontM,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical: AppSizes.paddingM,
                          ),
                        ),
                      ),
                    ),
                    if (_careerItems.length > 1) ...[
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _removeCareerItem,
                          icon: const Icon(
                            Icons.remove,
                            color: AppColors.error,
                            size: 20,
                          ),
                          label: const Text(
                            '항목삭제',
                            style: TextStyle(
                              fontSize: AppSizes.fontM,
                              color: AppColors.error,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingM,
                              vertical: AppSizes.paddingM,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 저장하기 버튼
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: const Text(
                '저장하기',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 경력 항목 빌더
  Widget _buildCareerItem(int index) {
    final item = _careerItems[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          const Divider(height: AppSizes.paddingXL),
          const SizedBox(height: AppSizes.paddingL),
        ],
        // 경력시작/종료
        Row(
          children: [
            Expanded(
              child: _buildYearDropdown(
                label: '경력시작',
                value: item.startYear?.toString(),
                hint: '[ 경력시작 ]',
                onChanged: (value) {
                  setState(() {
                    _careerItems[index] = item.copyWith(
                      startYear: value != null ? int.parse(value) : null,
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: _buildYearDropdown(
                label: '경력종료',
                value: item.endYear?.toString(),
                hint: '[ 경력종료 ]',
                onChanged: (value) {
                  setState(() {
                    _careerItems[index] = item.copyWith(
                      endYear: value != null ? int.parse(value) : null,
                    );
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 경력사항 설명
        _buildTextField(
          label: '경력사항',
          controller: item.descriptionController,
          hint: '경력사항을 입력해주세요.',
          maxLines: 5,
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 대표항목 라디오 버튼
        _buildRepresentativeRadio(index),
      ],
    );
  }

  /// 년도 드롭다운 빌더
  Widget _buildYearDropdown({
    required String label,
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingM,
              ),
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  hint,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ..._yearOptions.map((year) {
                return DropdownMenuItem<String>(
                  value: year.toString(),
                  child: Text(year.toString()),
                );
              }),
            ],
            onChanged: onChanged,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 텍스트 필드 빌더
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
        ),
      ],
    );
  }

  /// 대표항목 라디오 버튼
  Widget _buildRepresentativeRadio(int index) {
    final item = _careerItems[index];
    final isSelected = item.isRepresentative;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // 다른 항목들의 대표항목 해제
              for (int i = 0; i < _careerItems.length; i++) {
                if (i != index && _careerItems[i].isRepresentative) {
                  _careerItems[i] = _careerItems[i].copyWith(isRepresentative: false);
                }
              }
              // 현재 항목의 대표항목 토글
              _careerItems[index] = item.copyWith(isRepresentative: !isSelected);
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              color: Colors.white,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        Text(
          '대표항목',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 경력 항목 추가
  void _addCareerItem() {
    setState(() {
      _careerItems.add(CareerItem());
    });
  }

  /// 경력 항목 삭제
  void _removeCareerItem() {
    if (_careerItems.length > 1) {
      setState(() {
        final removedItem = _careerItems.removeLast();
        removedItem.descriptionController.dispose();
      });
    }
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // Career 엔티티로 변환
    final careers = _careerItems.map((item) {
      return Career(
        startYear: item.startYear,
        endYear: item.endYear,
        description: item.descriptionController.text.trim().isEmpty
            ? null
            : item.descriptionController.text.trim(),
        isRepresentative: item.isRepresentative,
      );
    }).toList();

    // TODO: 데이터 저장 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('저장되었습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    for (var item in _careerItems) {
      item.descriptionController.dispose();
    }
    super.dispose();
  }
}

/// 경력 항목 데이터 클래스
class CareerItem {
  final int? startYear;
  final int? endYear;
  final TextEditingController descriptionController;
  final bool isRepresentative;

  CareerItem({
    this.startYear,
    this.endYear,
    TextEditingController? descriptionController,
    this.isRepresentative = false,
  }) : descriptionController = descriptionController ?? TextEditingController();

  CareerItem copyWith({
    int? startYear,
    int? endYear,
    TextEditingController? descriptionController,
    bool? isRepresentative,
  }) {
    return CareerItem(
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      descriptionController: descriptionController ?? this.descriptionController,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}


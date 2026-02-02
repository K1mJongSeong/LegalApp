import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/other_activity.dart';

/// 기타활동 섹션
class OtherActivitySection extends StatefulWidget {
  const OtherActivitySection({super.key});

  @override
  State<OtherActivitySection> createState() => _OtherActivitySectionState();
}

class _OtherActivitySectionState extends State<OtherActivitySection> {
  List<OtherActivityItem> _otherActivityItems = [OtherActivityItem()];

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
                  '활동사항',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 기타활동 항목들
                ...List.generate(_otherActivityItems.length, (index) {
                  return _buildOtherActivityItem(index);
                }),
                const SizedBox(height: AppSizes.paddingL),
                // 항목추가/제거 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addOtherActivityItem,
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
                    if (_otherActivityItems.length > 1) ...[
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _removeOtherActivityItem,
                          icon: const Icon(
                            Icons.remove,
                            color: AppColors.error,
                            size: 20,
                          ),
                          label: const Text(
                            '항목제거',
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

  /// 기타활동 항목 빌더
  Widget _buildOtherActivityItem(int index) {
    final item = _otherActivityItems[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          const Divider(height: AppSizes.paddingXL),
          const SizedBox(height: AppSizes.paddingL),
        ],
        // 시작연도
        _buildYearDropdown(
          value: item.startYear?.toString(),
          hint: '[시작연도]',
          onChanged: (value) {
            setState(() {
              _otherActivityItems[index] = item.copyWith(
                startYear: value != null ? int.parse(value) : null,
              );
            });
          },
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 종료연도
        _buildYearDropdown(
          value: item.endYear?.toString(),
          hint: '[종료연도]',
          onChanged: (value) {
            setState(() {
              _otherActivityItems[index] = item.copyWith(
                endYear: value != null ? int.parse(value) : null,
              );
            });
          },
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 내용
        _buildTextField(
          label: '내용',
          controller: item.contentController,
          hint: '내용',
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
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
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
    final item = _otherActivityItems[index];
    final isSelected = item.isRepresentative;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // 다른 항목들의 대표항목 해제
              for (int i = 0; i < _otherActivityItems.length; i++) {
                if (i != index && _otherActivityItems[i].isRepresentative) {
                  _otherActivityItems[i] = _otherActivityItems[i].copyWith(isRepresentative: false);
                }
              }
              // 현재 항목의 대표항목 토글
              _otherActivityItems[index] = item.copyWith(isRepresentative: !isSelected);
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

  /// 기타활동 항목 추가
  void _addOtherActivityItem() {
    setState(() {
      _otherActivityItems.add(OtherActivityItem());
    });
  }

  /// 기타활동 항목 제거
  void _removeOtherActivityItem() {
    if (_otherActivityItems.length > 1) {
      setState(() {
        final removedItem = _otherActivityItems.removeLast();
        removedItem.contentController.dispose();
      });
    }
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // OtherActivity 엔티티로 변환
    final otherActivities = _otherActivityItems.map((item) {
      return OtherActivity(
        startYear: item.startYear,
        endYear: item.endYear,
        content: item.contentController.text.trim().isEmpty
            ? null
            : item.contentController.text.trim(),
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
    for (var item in _otherActivityItems) {
      item.contentController.dispose();
    }
    super.dispose();
  }
}

/// 기타활동 항목 데이터 클래스
class OtherActivityItem {
  final int? startYear;
  final int? endYear;
  final TextEditingController contentController;
  final bool isRepresentative;

  OtherActivityItem({
    this.startYear,
    this.endYear,
    TextEditingController? contentController,
    this.isRepresentative = false,
  }) : contentController = contentController ?? TextEditingController();

  OtherActivityItem copyWith({
    int? startYear,
    int? endYear,
    TextEditingController? contentController,
    bool? isRepresentative,
  }) {
    return OtherActivityItem(
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      contentController: contentController ?? this.contentController,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}







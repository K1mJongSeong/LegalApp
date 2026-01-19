import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/press_release.dart';

/// 보도자료 섹션
class PressReleaseSection extends StatefulWidget {
  const PressReleaseSection({super.key});

  @override
  State<PressReleaseSection> createState() => _PressReleaseSectionState();
}

class _PressReleaseSectionState extends State<PressReleaseSection> {
  List<PressReleaseItem> _pressReleaseItems = [PressReleaseItem()];

  // 년도 옵션 (1997~2026)
  List<int> get _yearOptions {
    return List.generate(2026 - 1997 + 1, (index) => 1997 + index);
  }

  // 월 옵션 (1~12)
  List<int> get _monthOptions {
    return List.generate(12, (index) => index + 1);
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
                  '보도 내용',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 보도자료 항목들
                ...List.generate(_pressReleaseItems.length, (index) {
                  return _buildPressReleaseItem(index);
                }),
                const SizedBox(height: AppSizes.paddingL),
                // 항목추가/제거 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addPressReleaseItem,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: const Text(
                          '항목 추가',
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
                    if (_pressReleaseItems.length > 1) ...[
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _removePressReleaseItem,
                          icon: const Icon(
                            Icons.remove,
                            color: AppColors.error,
                            size: 20,
                          ),
                          label: const Text(
                            '항목 제거',
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

  /// 보도자료 항목 빌더
  Widget _buildPressReleaseItem(int index) {
    final item = _pressReleaseItems[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          const Divider(height: AppSizes.paddingXL),
          const SizedBox(height: AppSizes.paddingL),
        ],
        // 보도 연도
        _buildYearDropdown(
          value: item.year?.toString(),
          hint: '[보도 연도]',
          onChanged: (value) {
            setState(() {
              _pressReleaseItems[index] = item.copyWith(
                year: value != null ? int.parse(value) : null,
              );
            });
          },
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 보도 월
        _buildMonthDropdown(
          value: item.month?.toString(),
          hint: '[보도 월]',
          onChanged: (value) {
            setState(() {
              _pressReleaseItems[index] = item.copyWith(
                month: value != null ? int.parse(value) : null,
              );
            });
          },
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 보도 내용 요약
        _buildTextField(
          label: '보도 내용 요약',
          controller: item.summaryController,
          hint: '보도 내용 요약',
          maxLines: 5,
        ),
        const SizedBox(height: AppSizes.paddingL),
        // URL 주소
        _buildTextField(
          label: 'URL 주소',
          controller: item.urlController,
          hint: 'url',
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

  /// 월 드롭다운 빌더
  Widget _buildMonthDropdown({
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
          ..._monthOptions.map((month) {
            return DropdownMenuItem<String>(
              value: month.toString(),
              child: Text(month.toString()),
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
    final item = _pressReleaseItems[index];
    final isSelected = item.isRepresentative;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // 다른 항목들의 대표항목 해제
              for (int i = 0; i < _pressReleaseItems.length; i++) {
                if (i != index && _pressReleaseItems[i].isRepresentative) {
                  _pressReleaseItems[i] = _pressReleaseItems[i].copyWith(isRepresentative: false);
                }
              }
              // 현재 항목의 대표항목 토글
              _pressReleaseItems[index] = item.copyWith(isRepresentative: !isSelected);
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
          '대표 항목',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 보도자료 항목 추가
  void _addPressReleaseItem() {
    setState(() {
      _pressReleaseItems.add(PressReleaseItem());
    });
  }

  /// 보도자료 항목 제거
  void _removePressReleaseItem() {
    if (_pressReleaseItems.length > 1) {
      setState(() {
        final removedItem = _pressReleaseItems.removeLast();
        removedItem.summaryController.dispose();
        removedItem.urlController.dispose();
      });
    }
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // PressRelease 엔티티로 변환
    final pressReleases = _pressReleaseItems.map((item) {
      return PressRelease(
        year: item.year,
        month: item.month,
        summary: item.summaryController.text.trim().isEmpty
            ? null
            : item.summaryController.text.trim(),
        url: item.urlController.text.trim().isEmpty
            ? null
            : item.urlController.text.trim(),
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
    for (var item in _pressReleaseItems) {
      item.summaryController.dispose();
      item.urlController.dispose();
    }
    super.dispose();
  }
}

/// 보도자료 항목 데이터 클래스
class PressReleaseItem {
  final int? year;
  final int? month;
  final TextEditingController summaryController;
  final TextEditingController urlController;
  final bool isRepresentative;

  PressReleaseItem({
    this.year,
    this.month,
    TextEditingController? summaryController,
    TextEditingController? urlController,
    this.isRepresentative = false,
  })  : summaryController = summaryController ?? TextEditingController(),
        urlController = urlController ?? TextEditingController();

  PressReleaseItem copyWith({
    int? year,
    int? month,
    TextEditingController? summaryController,
    TextEditingController? urlController,
    bool? isRepresentative,
  }) {
    return PressReleaseItem(
      year: year ?? this.year,
      month: month ?? this.month,
      summaryController: summaryController ?? this.summaryController,
      urlController: urlController ?? this.urlController,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}
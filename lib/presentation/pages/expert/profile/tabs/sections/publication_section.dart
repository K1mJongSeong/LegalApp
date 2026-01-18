import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/publication.dart';

/// 논문/출판 정보 섹션
class PublicationSection extends StatefulWidget {
  const PublicationSection({super.key});

  @override
  State<PublicationSection> createState() => _PublicationSectionState();
}

class _PublicationSectionState extends State<PublicationSection> {
  List<PublicationItem> _publicationItems = [PublicationItem()];

  // 분류 옵션
  static const List<String> _categoryOptions = [
    '논문',
    '저서',
    '번역서',
    '기타',
  ];

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
                  '논문/출판 정보',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 논문/출판 항목들
                ...List.generate(_publicationItems.length, (index) {
                  return _buildPublicationItem(index);
                }),
                const SizedBox(height: AppSizes.paddingL),
                // 항목추가/제거 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addPublicationItem,
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
                    if (_publicationItems.length > 1) ...[
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _removePublicationItem,
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

  /// 논문/출판 항목 빌더
  Widget _buildPublicationItem(int index) {
    final item = _publicationItems[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          const Divider(height: AppSizes.paddingXL),
          const SizedBox(height: AppSizes.paddingL),
        ],
        // 분류
        _buildCategoryDropdown(
          value: item.category,
          hint: '[분류]',
          onChanged: (value) {
            setState(() {
              _publicationItems[index] = item.copyWith(category: value);
            });
          },
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 연도
        _buildYearDropdown(
          value: item.year?.toString(),
          hint: '[연도]',
          onChanged: (value) {
            setState(() {
              _publicationItems[index] = item.copyWith(
                year: value != null ? int.parse(value) : null,
              );
            });
          },
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 제목
        _buildTextField(
          label: '제목',
          controller: item.titleController,
          hint: '제목',
        ),
        const SizedBox(height: AppSizes.paddingL),
        // URL 주소
        _buildTextField(
          label: 'URL 주소',
          controller: item.urlController,
          hint: 'URL 주소',
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 대표항목 라디오 버튼
        _buildRepresentativeRadio(index),
      ],
    );
  }

  /// 분류 드롭다운 빌더
  Widget _buildCategoryDropdown({
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
          ..._categoryOptions.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
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
    final item = _publicationItems[index];
    final isSelected = item.isRepresentative;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // 다른 항목들의 대표항목 해제
              for (int i = 0; i < _publicationItems.length; i++) {
                if (i != index && _publicationItems[i].isRepresentative) {
                  _publicationItems[i] = _publicationItems[i].copyWith(isRepresentative: false);
                }
              }
              // 현재 항목의 대표항목 토글
              _publicationItems[index] = item.copyWith(isRepresentative: !isSelected);
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

  /// 논문/출판 항목 추가
  void _addPublicationItem() {
    setState(() {
      _publicationItems.add(PublicationItem());
    });
  }

  /// 논문/출판 항목 제거
  void _removePublicationItem() {
    if (_publicationItems.length > 1) {
      setState(() {
        final removedItem = _publicationItems.removeLast();
        removedItem.titleController.dispose();
        removedItem.urlController.dispose();
      });
    }
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // Publication 엔티티로 변환
    final publications = _publicationItems.map((item) {
      return Publication(
        category: item.category,
        year: item.year,
        title: item.titleController.text.trim().isEmpty
            ? null
            : item.titleController.text.trim(),
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
    for (var item in _publicationItems) {
      item.titleController.dispose();
      item.urlController.dispose();
    }
    super.dispose();
  }
}

/// 논문/출판 항목 데이터 클래스
class PublicationItem {
  final String? category;
  final int? year;
  final TextEditingController titleController;
  final TextEditingController urlController;
  final bool isRepresentative;

  PublicationItem({
    this.category,
    this.year,
    TextEditingController? titleController,
    TextEditingController? urlController,
    this.isRepresentative = false,
  })  : titleController = titleController ?? TextEditingController(),
        urlController = urlController ?? TextEditingController();

  PublicationItem copyWith({
    String? category,
    int? year,
    TextEditingController? titleController,
    TextEditingController? urlController,
    bool? isRepresentative,
  }) {
    return PublicationItem(
      category: category ?? this.category,
      year: year ?? this.year,
      titleController: titleController ?? this.titleController,
      urlController: urlController ?? this.urlController,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}





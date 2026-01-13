import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';

/// 주요분야 섹션
class MainFieldsSection extends StatefulWidget {
  const MainFieldsSection({super.key});

  @override
  State<MainFieldsSection> createState() => _MainFieldsSectionState();
}

class _MainFieldsSectionState extends State<MainFieldsSection> {
  // 분야 옵션 목록
  static const List<String> _fieldOptions = [
    '이혼/가사',
    '형사',
    '교통사고/산재',
    '부동산/임대차',
    '의료/세금',
    '회사/창업',
    '민사',
    '행정/헌법',
    '노동/인사',
    '지적재산권',
    '국제거래/무역',
  ];

  static const int _maxFields = 7;
  List<String?> _selectedFields = [null]; // null은 선택 안됨을 의미

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
                // 제목
                const Text(
                  '주요분야',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                // 참고 문구
                _buildNoteBox(),
                const SizedBox(height: AppSizes.paddingXL),
                // 분야 선택 필드들
                ...List.generate(_selectedFields.length, (index) {
                  return _buildFieldSelector(index);
                }),
                const SizedBox(height: AppSizes.paddingL),
                // 항목추가 버튼
                if (_selectedFields.length < _maxFields)
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _addField,
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

  /// 참고 문구 박스
  Widget _buildNoteBox() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: AppSizes.fontS,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '[참고] ',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: '최대 7개 분야까지 선택 가능합니다.',
            ),
          ],
        ),
      ),
    );
  }

  /// 분야 선택 필드 빌더
  Widget _buildFieldSelector(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) const SizedBox(height: AppSizes.paddingL),
        Text(
          '분야',
          style: const TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        _buildDropdownField(index),
      ],
    );
  }

  /// 드롭다운 필드 빌더
  Widget _buildDropdownField(int index) {
    // 이미 선택된 분야들을 제외한 옵션 목록 생성
    final availableOptions = _fieldOptions.where((field) {
      // 현재 인덱스의 선택값은 제외하지 않음 (자기 자신)
      return !_selectedFields.asMap().entries.any((entry) {
        return entry.key != index && entry.value == field;
      });
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedFields[index],
        decoration: InputDecoration(
          hintText: '[ 분야선택 ]',
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
          const DropdownMenuItem<String>(
            value: null,
            child: Text(
              '[ 분야선택 ]',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ...availableOptions.map((field) {
            return DropdownMenuItem<String>(
              value: field,
              child: Text(field),
            );
          }),
        ],
        onChanged: (value) {
          setState(() {
            _selectedFields[index] = value;
          });
        },
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 분야 추가
  void _addField() {
    if (_selectedFields.length < _maxFields) {
      setState(() {
        _selectedFields.add(null);
      });
    }
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // null이 아닌 분야들만 필터링
    final selectedFields = _selectedFields
        .where((field) => field != null)
        .cast<String>()
        .toList();

    if (selectedFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1개 이상의 분야를 선택해주세요.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (selectedFields.length > _maxFields) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('최대 $_maxFields개까지 선택 가능합니다.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // TODO: 데이터 저장 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('저장되었습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

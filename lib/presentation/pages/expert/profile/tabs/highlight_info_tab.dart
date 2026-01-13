import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';


/// 강조정보 탭
class HighlightInfoTab extends StatefulWidget {
  const HighlightInfoTab({super.key});

  @override
  State<HighlightInfoTab> createState() => _HighlightInfoTabState();
}

class _HighlightInfoTabState extends State<HighlightInfoTab> {
  // 대한변호사협회 전문분야
  bool _isKbaSpecializationRegistered = false;
  List<String?> _kbaSpecializations = [null, null]; // 최대 2개

  // 특수자격
  final Set<String> _selectedSpecialQualifications = {};

  // 경험
  final Set<String> _selectedExperiences = {};

  // 외국어
  final Set<String> _selectedLanguages = {};
  final TextEditingController _otherLanguageController = TextEditingController();

  // 옵션 목록
  static const List<String> _kbaSpecializationOptions = [
    '민사',
    '형사',
    '가사',
    '노동',
    '기업',
  ];

  static const List<String> _specialQualificationOptions = [
    '세무사',
    '노무사',
    '변리사',
    '관세사',
    '회계사',
    '행정사',
    '공인중개사',
    '감정평가사',
    '의사',
    '한의사',
    '약사',
  ];

  static const List<String> _experienceOptions = [
    '판사 경험',
    '검사 경험',
    '경찰 경험',
    '국선변호인 경험',
    '대형 로펌 경험',
    '사업 경험',
    '기업 근무 경험',
    '공직 근무 경험',
  ];

  static const List<String> _languageOptions = [
    '영어',
    '중국어',
    '일본어',
  ];

  @override
  void dispose() {
    _otherLanguageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 및 설명
          const Text(
            '변호사 프로필에서 강조할 정보에 답변해 주세요.',
            style: TextStyle(
              fontSize: AppSizes.fontXXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '변호사 프로필 상단에 아이콘 형태로 강조되어 보여집니다.',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 대한변호사협회 전문분야 섹션
          _buildKbaSpecializationSection(),
          const SizedBox(height: AppSizes.paddingL),
          // 특수자격 섹션
          _buildSpecialQualificationSection(),
          const SizedBox(height: AppSizes.paddingL),
          // 경험 섹션
          _buildExperienceSection(),
          const SizedBox(height: AppSizes.paddingL),
          // 외국어 섹션
          _buildLanguageSection(),
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

  /// 대한변호사협회 전문분야 섹션
  Widget _buildKbaSpecializationSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대한변호사협회에서 전문분야가 등록되어 있습니까?',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 등록되어 있음 라디오 버튼
          _buildRadioOption(
            value: true,
            label: '등록되어 있음',
            groupValue: _isKbaSpecializationRegistered,
            onChanged: (value) {
              setState(() {
                _isKbaSpecializationRegistered = value;
                if (!value) {
                  _kbaSpecializations = [null, null];
                }
              });
            },
          ),
          if (_isKbaSpecializationRegistered) ...[
            const SizedBox(height: AppSizes.paddingL),
            // 전문분야 선택 드롭다운
            _buildKbaSpecializationDropdown(0),
            const SizedBox(height: AppSizes.paddingM),
            _buildKbaSpecializationDropdown(1),
          ],
        ],
      ),
    );
  }

  /// 전문분야 드롭다운 빌더
  Widget _buildKbaSpecializationDropdown(int index) {
    return _buildDropdownField(
      value: _kbaSpecializations[index],
      hint: '전문분야 선택',
      items: _kbaSpecializationOptions
          .where((option) =>
              !_kbaSpecializations.asMap().entries.any((entry) =>
                  entry.key != index && entry.value == option))
          .map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _kbaSpecializations[index] = value;
        });
      },
    );
  }

  /// 특수자격 섹션
  Widget _buildSpecialQualificationSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '보유하고 있는 특수자격을 선택해 주세요.',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ..._specialQualificationOptions.map((qualification) {
            return _buildCheckboxOption(
              value: qualification,
              label: qualification,
              isSelected: _selectedSpecialQualifications.contains(qualification),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecialQualifications.add(qualification);
                  } else {
                    _selectedSpecialQualifications.remove(qualification);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  /// 경험 섹션
  Widget _buildExperienceSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '변호사 이외에 어떤 경험을 해보셨나요?',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ..._experienceOptions.map((experience) {
            return _buildCheckboxOption(
              value: experience,
              label: experience,
              isSelected: _selectedExperiences.contains(experience),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selectedExperiences.add(experience);
                  } else {
                    _selectedExperiences.remove(experience);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  /// 외국어 섹션
  Widget _buildLanguageSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대응 가능한 외국어가 있나요?',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ..._languageOptions.map((language) {
            return _buildCheckboxOption(
              value: language,
              label: language,
              isSelected: _selectedLanguages.contains(language),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLanguages.add(language);
                  } else {
                    _selectedLanguages.remove(language);
                  }
                });
              },
            );
          }),
          const SizedBox(height: AppSizes.paddingS),
          // 기타 외국어
          _buildCheckboxOption(
            value: '기타',
            label: '기타',
            isSelected: _selectedLanguages.contains('기타'),
            onChanged: (selected) {
              setState(() {
                if (selected) {
                  _selectedLanguages.add('기타');
                } else {
                  _selectedLanguages.remove('기타');
                  _otherLanguageController.clear();
                }
              });
            },
          ),
          if (_selectedLanguages.contains('기타')) ...[
            const SizedBox(height: AppSizes.paddingS),
            TextField(
              controller: _otherLanguageController,
              decoration: InputDecoration(
                hintText: '가능한 외국어',
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
        ],
      ),
    );
  }

  /// 라디오 옵션 빌더
  Widget _buildRadioOption({
    required bool value,
    required String label,
    required bool? groupValue,
    required ValueChanged<bool> onChanged,
  }) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: AppSizes.paddingS),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 체크박스 옵션 빌더
  Widget _buildCheckboxOption({
    required String value,
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!isSelected),
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
            label,
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 드롭다운 필드 빌더
  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
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
          ...items,
        ],
        onChanged: onChanged,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // 전문분야 등록되어 있음인데 선택하지 않은 경우 체크
    if (_isKbaSpecializationRegistered &&
        _kbaSpecializations.every((s) => s == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('등록된 전문분야를 선택해주세요'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // 기타 외국어 선택했는데 입력하지 않은 경우 체크
    if (_selectedLanguages.contains('기타') &&
        _otherLanguageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('기타 외국어를 입력해주세요'),
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


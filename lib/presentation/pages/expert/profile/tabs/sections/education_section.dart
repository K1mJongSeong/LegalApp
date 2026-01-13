import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/education.dart';

/// 학력사항 섹션
class EducationSection extends StatefulWidget {
  const EducationSection({super.key});

  @override
  State<EducationSection> createState() => _EducationSectionState();
}

class _EducationSectionState extends State<EducationSection> {
  bool _isEducationPublic = true;
  List<EducationItem> _educationItems = [EducationItem()];

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
                // 제목과 공개 토글
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '학력사항',
                      style: TextStyle(
                        fontSize: AppSizes.fontXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isEducationPublic = !_isEducationPublic;
                            });
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isEducationPublic
                                  ? AppColors.primary
                                  : Colors.white,
                              border: Border.all(
                                color: _isEducationPublic
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: _isEducationPublic
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                        Text(
                          '공개',
                          style: TextStyle(
                            fontSize: AppSizes.fontM,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 학력 항목들
                ...List.generate(_educationItems.length, (index) {
                  return _buildEducationItem(index);
                }),
                const SizedBox(height: AppSizes.paddingL),
                // 항목추가 버튼
                OutlinedButton.icon(
                  onPressed: _addEducationItem,
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

  /// 학력 항목 빌더
  Widget _buildEducationItem(int index) {
    final item = _educationItems[index];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          const Divider(height: AppSizes.paddingXL),
          const SizedBox(height: AppSizes.paddingL),
        ],
        // 입학/졸업연도
        _buildYearFields(item, index),
        const SizedBox(height: AppSizes.paddingL),
        // 학위/상태
        _buildDegreeStatusFields(item, index),
        const SizedBox(height: AppSizes.paddingL),
        // 학교/학과
        _buildSchoolFields(item, index),
        const SizedBox(height: AppSizes.paddingL),
        // 대표항목 라디오 버튼
        _buildRepresentativeRadio(index),
      ],
    );
  }

  /// 입학/졸업연도 필드
  Widget _buildYearFields(EducationItem item, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '입학/졸업연도',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                value: item.enrollmentYear?.toString(),
                hint: '입학연도 선택',
                items: _generateYearItems(),
                onChanged: (value) {
                  setState(() {
                    _educationItems[index] = item.copyWith(
                      enrollmentYear: value != null ? int.parse(value) : null,
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: _buildDropdownField(
                value: item.graduationYear?.toString(),
                hint: '졸업연도 선택',
                items: _generateYearItems(),
                onChanged: (value) {
                  setState(() {
                    _educationItems[index] = item.copyWith(
                      graduationYear: value != null ? int.parse(value) : null,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 학위/상태 필드
  Widget _buildDegreeStatusFields(EducationItem item, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '학위/상태',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                value: item.degree,
                hint: '학위 선택',
                items: const [
                  DropdownMenuItem(value: '고등학교', child: Text('고등학교')),
                  DropdownMenuItem(value: '전문대학', child: Text('전문대학')),
                  DropdownMenuItem(value: '학사', child: Text('학사')),
                  DropdownMenuItem(value: '석사', child: Text('석사')),
                  DropdownMenuItem(value: '박사', child: Text('박사')),
                ],
                onChanged: (value) {
                  setState(() {
                    _educationItems[index] = item.copyWith(degree: value);
                  });
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: _buildDropdownField(
                value: item.status,
                hint: '상태 선택',
                items: const [
                  DropdownMenuItem(value: '재학', child: Text('재학')),
                  DropdownMenuItem(value: '졸업', child: Text('졸업')),
                  DropdownMenuItem(value: '중퇴', child: Text('중퇴')),
                  DropdownMenuItem(value: '휴학', child: Text('휴학')),
                ],
                onChanged: (value) {
                  setState(() {
                    _educationItems[index] = item.copyWith(status: value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 학교/학과 필드
  Widget _buildSchoolFields(EducationItem item, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '학교/학과',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: item.schoolNameController,
                decoration: InputDecoration(
                  hintText: '학교명',
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
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: TextField(
                controller: item.departmentNameController,
                decoration: InputDecoration(
                  hintText: '학과명',
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
            ),
          ],
        ),
      ],
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
        items: items,
        onChanged: onChanged,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 연도 목록 생성
  List<DropdownMenuItem<String>> _generateYearItems() {
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 1950 + 1, (index) => currentYear - index);
    return years.map((year) {
      return DropdownMenuItem(
        value: year.toString(),
        child: Text(year.toString()),
      );
    }).toList();
  }

  /// 대표항목 라디오 버튼
  Widget _buildRepresentativeRadio(int index) {
    final item = _educationItems[index];
    final isSelected = item.isRepresentative;
    
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // 다른 항목들의 대표항목 해제
              for (int i = 0; i < _educationItems.length; i++) {
                if (i != index && _educationItems[i].isRepresentative) {
                  _educationItems[i] = _educationItems[i].copyWith(isRepresentative: false);
                }
              }
              // 현재 항목의 대표항목 토글
              _educationItems[index] = item.copyWith(isRepresentative: !isSelected);
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

  /// 학력 항목 추가
  void _addEducationItem() {
    setState(() {
      _educationItems.add(EducationItem());
    });
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // Education 엔티티로 변환
    final educations = _educationItems.map((item) {
      return Education(
        enrollmentYear: item.enrollmentYear,
        graduationYear: item.graduationYear,
        degree: item.degree,
        status: item.status,
        schoolName: item.schoolNameController.text.trim().isEmpty
            ? null
            : item.schoolNameController.text.trim(),
        departmentName: item.departmentNameController.text.trim().isEmpty
            ? null
            : item.departmentNameController.text.trim(),
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
    for (var item in _educationItems) {
      item.schoolNameController.dispose();
      item.departmentNameController.dispose();
    }
    super.dispose();
  }
}

/// 학력 항목 데이터 클래스
class EducationItem {
  final int? enrollmentYear;
  final int? graduationYear;
  final String? degree;
  final String? status;
  final TextEditingController schoolNameController;
  final TextEditingController departmentNameController;
  final bool isRepresentative;

  EducationItem({
    this.enrollmentYear,
    this.graduationYear,
    this.degree,
    this.status,
    TextEditingController? schoolNameController,
    TextEditingController? departmentNameController,
    this.isRepresentative = false,
  })  : schoolNameController = schoolNameController ?? TextEditingController(),
        departmentNameController = departmentNameController ?? TextEditingController();

  EducationItem copyWith({
    int? enrollmentYear,
    int? graduationYear,
    String? degree,
    String? status,
    TextEditingController? schoolNameController,
    TextEditingController? departmentNameController,
    bool? isRepresentative,
  }) {
    return EducationItem(
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      graduationYear: graduationYear ?? this.graduationYear,
      degree: degree ?? this.degree,
      status: status ?? this.status,
      schoolNameController: schoolNameController ?? this.schoolNameController,
      departmentNameController: departmentNameController ?? this.departmentNameController,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';

/// 사무실 정보 섹션
class OfficeInfoSection extends StatefulWidget {
  const OfficeInfoSection({super.key});

  @override
  State<OfficeInfoSection> createState() => _OfficeInfoSectionState();
}

class _OfficeInfoSectionState extends State<OfficeInfoSection> {
  // 사무실 기본 정보
  final TextEditingController _officeNameController = TextEditingController();
  String? _officeRegion1; // 시/도
  String? _officeRegion2; // 시/군/구
  String? _affiliatedBranch; // 소속 지회 (필수)
  final TextEditingController _officeAddressSearchController =
      TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  // 주소 정보
  final TextEditingController _lotNumberAddressController =
      TextEditingController();
  final TextEditingController _roadNameAddressController =
      TextEditingController();
  final TextEditingController _detailedAddressController =
      TextEditingController();

  // 기타 정보
  final TextEditingController _homepageUrlController = TextEditingController();

  // 운영시간
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // 휴일
  final Set<String> _selectedHolidays = {};

  // 서비스사항
  final Set<String> _selectedServiceDetails = {};

  // 지역 옵션 (예시 - 실제로는 더 많은 옵션이 필요)
  static const List<String> _region1Options = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원도',
    '충청북도',
    '충청남도',
    '전라북도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  static const List<String> _holidayOptions = [
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
    '일요일',
    '법정공휴일',
  ];

  static const List<String> _serviceDetailOptions = [
    '전화상담가능',
    '당일상담가능',
    '휴일상담가능',
    '야간상담가능',
    '출장상담가능',
    '여성직원응대가능',
  ];

  @override
  void dispose() {
    _officeNameController.dispose();
    _officeAddressSearchController.dispose();
    _postalCodeController.dispose();
    _lotNumberAddressController.dispose();
    _roadNameAddressController.dispose();
    _detailedAddressController.dispose();
    _homepageUrlController.dispose();
    super.dispose();
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
                  '사무실정보',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 사무실이름
                _buildTextField(
                  label: '사무실이름',
                  controller: _officeNameController,
                  hint: '없음',
                ),
                const SizedBox(height: AppSizes.paddingL),
                // 사무실지역
                _buildOfficeRegionField(),
                const SizedBox(height: AppSizes.paddingL),
                // 소속 지회
                _buildAffiliatedBranchField(),
                const SizedBox(height: AppSizes.paddingL),
                // 사무실주소
                _buildOfficeAddressField(),
                const SizedBox(height: AppSizes.paddingL),
                // 우편번호
                _buildTextField(
                  label: '우편번호',
                  controller: _postalCodeController,
                  hint: '우편번호',
                  enabled: false,
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 지번 주소
                _buildTextField(
                  label: '지번 주소',
                  controller: _lotNumberAddressController,
                  hint: '지번 주소',
                  enabled: false,
                ),
                const SizedBox(height: AppSizes.paddingL),
                // 도로명 주소
                _buildTextField(
                  label: '도로명 주소',
                  controller: _roadNameAddressController,
                  hint: '도로명 주소',
                  enabled: false,
                ),
                const SizedBox(height: AppSizes.paddingL),
                // 상세 주소
                _buildTextField(
                  label: '상세 주소',
                  controller: _detailedAddressController,
                  hint: '상세 주소',
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 홈페이지 주소
                _buildTextField(
                  label: '홈페이지 주소 (선택)',
                  controller: _homepageUrlController,
                  hint: '홈페이지 주소 (선택)',
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 운영시간
                _buildOperatingHoursField(),
                const SizedBox(height: AppSizes.paddingXL),
                const Divider(),
                const SizedBox(height: AppSizes.paddingXL),
                // 휴일
                _buildHolidaysField(),
                const SizedBox(height: AppSizes.paddingXL),
                const Divider(),
                const SizedBox(height: AppSizes.paddingXL),
                // 서비스사항
                _buildServiceDetailsField(),
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

  /// 텍스트 필드 빌더
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
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
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            disabledBorder: OutlineInputBorder(
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

  /// 사무실지역 필드
  Widget _buildOfficeRegionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사무실지역',
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
                value: _officeRegion1,
                hint: '[ 지역선택 ]',
                items: _region1Options.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _officeRegion1 = value;
                    _officeRegion2 = null; // 지역1 변경 시 지역2 초기화
                  });
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: _buildDropdownField(
                value: _officeRegion2,
                hint: '[ 지역선택 ]',
                items: [], // TODO: 지역1에 따라 동적으로 생성
                onChanged: (value) {
                  setState(() {
                    _officeRegion2 = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 소속 지회 필드
  Widget _buildAffiliatedBranchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '소속 지회',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        _buildDropdownField(
          value: _affiliatedBranch,
          hint: '소속 지회를 선택해 주세요.',
          items: const [
            // TODO: 실제 지회 목록으로 교체
            DropdownMenuItem(value: '서울지회', child: Text('서울지회')),
            DropdownMenuItem(value: '부산지회', child: Text('부산지회')),
            DropdownMenuItem(value: '대구지회', child: Text('대구지회')),
            DropdownMenuItem(value: '인천지회', child: Text('인천지회')),
            DropdownMenuItem(value: '광주지회', child: Text('광주지회')),
            DropdownMenuItem(value: '대전지회', child: Text('대전지회')),
            DropdownMenuItem(value: '울산지회', child: Text('울산지회')),
          ],
          onChanged: (value) {
            setState(() {
              _affiliatedBranch = value;
            });
          },
        ),
        if (_affiliatedBranch == null) ...[
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            '소속 지회 선택은 필수입니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  /// 사무실주소 필드
  Widget _buildOfficeAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사무실주소',
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
                controller: _officeAddressSearchController,
                decoration: InputDecoration(
                  hintText: '예) 서초동 1552-16 또는 반포',
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
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingM,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: _searchAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
                child: const Icon(Icons.search, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          '사무실 주소를 검색하시면 우편번호, 지번주소, 도로명 주소가 자동으로 입력됩니다.',
          style: TextStyle(
            fontSize: AppSizes.fontS,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 운영시간 필드
  Widget _buildOperatingHoursField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '운영시간',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            // 시작시간
            Expanded(
              child: _buildIOSTimeField(
                label: '시작시간',
                time: _startTime,
                onTap: () => _showIOSTimePicker(context, isStartTime: true),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            const Text(
              '~',
              style: TextStyle(
                fontSize: AppSizes.fontXL,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            // 종료시간
            Expanded(
              child: _buildIOSTimeField(
                label: '종료시간',
                time: _endTime,
                onTap: () => _showIOSTimePicker(context, isStartTime: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// iOS 스타일 시간 필드 빌더
  Widget _buildIOSTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontS,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null
                      ? _formatTime(time!)
                      : '시간 선택',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: time != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 시간 포맷팅 (iOS 스타일)
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// iOS 스타일 시간 선택기 표시
  Future<void> _showIOSTimePicker(
    BuildContext context, {
    required bool isStartTime,
  }) async {
    final currentTime = isStartTime
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 18, minute: 0));

    // 24시간 형식을 12시간 형식으로 변환
    int hour24 = currentTime.hour;
    bool isAM = hour24 < 12;
    int selectedHour;
    if (hour24 == 0) {
      selectedHour = 12; // 자정
      isAM = true;
    } else if (hour24 == 12) {
      selectedHour = 12; // 정오
      isAM = false;
    } else if (hour24 < 12) {
      selectedHour = hour24;
      isAM = true;
    } else {
      selectedHour = hour24 - 12;
      isAM = false;
    }

    int selectedMinute = currentTime.minute;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    isStartTime ? '시작시간' : '종료시간',
                    style: const TextStyle(
                      fontSize: AppSizes.fontL,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        int hour24;
                        if (isAM) {
                          hour24 = selectedHour == 12 ? 0 : selectedHour;
                        } else {
                          hour24 = selectedHour == 12 ? 12 : selectedHour + 12;
                        }
                        final time = TimeOfDay(
                          hour: hour24,
                          minute: selectedMinute,
                        );
                        if (isStartTime) {
                          _startTime = time;
                        } else {
                          _endTime = time;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // iOS 스타일 휠 피커
            Expanded(
              child: Row(
                children: [
                  // 시간
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedHour - 1, // 1-12를 0-11 인덱스로 변환
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        selectedHour = index + 1;
                      },
                      children: List.generate(12, (index) {
                        final hour = index + 1;
                        return Center(
                          child: Text(
                            hour.toString(),
                            style: const TextStyle(
                              fontSize: AppSizes.fontXL,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // 분
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: (selectedMinute / 15).round().clamp(0, 3),
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        selectedMinute = index * 15;
                      },
                      children: [0, 15, 30, 45].map((minute) {
                        return Center(
                          child: Text(
                            minute.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: AppSizes.fontXL,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // AM/PM
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: isAM ? 0 : 1,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        isAM = index == 0;
                      },
                      children: const [
                        Center(
                          child: Text(
                            'AM',
                            style: TextStyle(
                              fontSize: AppSizes.fontXL,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'PM',
                            style: TextStyle(
                              fontSize: AppSizes.fontXL,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 휴일 필드
  Widget _buildHolidaysField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '휴일',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        ..._holidayOptions.map((holiday) {
          return _buildCheckboxOption(
            value: holiday,
            label: holiday,
            isSelected: _selectedHolidays.contains(holiday),
            onChanged: (selected) {
              setState(() {
                if (selected) {
                  _selectedHolidays.add(holiday);
                } else {
                  _selectedHolidays.remove(holiday);
                }
              });
            },
          );
        }),
      ],
    );
  }

  /// 서비스사항 필드
  Widget _buildServiceDetailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스사항',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        ..._serviceDetailOptions.map((service) {
          return _buildCheckboxOption(
            value: service,
            label: service,
            isSelected: _selectedServiceDetails.contains(service),
            onChanged: (selected) {
              setState(() {
                if (selected) {
                  _selectedServiceDetails.add(service);
                } else {
                  _selectedServiceDetails.remove(service);
                }
              });
            },
          );
        }),
      ],
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
        isExpanded: true,
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

  /// 주소 검색
  void _searchAddress() {
    // TODO: 주소 검색 API 연동 (예: 다음 주소 API, 카카오 주소 API)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('주소 검색 기능 준비 중입니다'),
      ),
    );
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // 소속 지회 필수 체크
    if (_affiliatedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('소속 지회를 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 운영시간 포맷팅
    final startTime = _startTime != null
        ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
        : null;
    final endTime = _endTime != null
        ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
        : null;
    final isStartAM = _startTime != null ? _startTime!.hour < 12 : true;
    final isEndAM = _endTime != null ? _endTime!.hour < 12 : false;

    // TODO: 데이터 저장 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('저장되었습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

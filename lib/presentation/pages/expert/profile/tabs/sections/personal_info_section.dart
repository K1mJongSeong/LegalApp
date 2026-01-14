import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/expert_profile.dart';
import '../../../../../../domain/repositories/expert_profile_repository.dart';
import '../../../../../../data/repositories/expert_profile_repository_impl.dart';
import '../../../../../blocs/auth/auth_bloc.dart';
import '../../../../../blocs/auth/auth_state.dart';

/// 인적사항 섹션
class PersonalInfoSection extends StatefulWidget {
  const PersonalInfoSection({super.key});

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  // 인적사항
  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _birthDateController = TextEditingController(text: '');
  String _gender = 'male'; // 'male' or 'female'
  final TextEditingController _phoneController = TextEditingController(text: '');

  // 연락처 정보
  final TextEditingController _officePhoneController = TextEditingController(text: '');
  String _representativePhoneType = 'mobile'; // 'office', 'mobile', 'custom'
  final TextEditingController _customPhoneController = TextEditingController();
  bool _isPhonePublic = false;
  bool _convertTo050 = false;
  final TextEditingController _emailController = TextEditingController(text: '');

  // 추가 정보
  final TextEditingController _auxiliaryEmailController = TextEditingController();
  final TextEditingController _oneLineIntroController = TextEditingController();

  // Repository
  final ExpertProfileRepository _profileRepository = ExpertProfileRepositoryImpl();
  
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// 기존 프로필 데이터 로드
  Future<void> _loadProfile() async {
    if (_isInitialized) return;

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        return;
      }

      final userId = authState.user.id;
      final profile = await _profileRepository.getProfileByUserId(userId);

      if (profile != null && mounted) {
        setState(() {
          _nameController.text = profile.name ?? '';
          if (profile.birthDate != null) {
            _birthDateController.text = DateFormat('yyyy.MM.dd').format(profile.birthDate!);
          }
          _gender = profile.gender ?? 'male';
          _phoneController.text = profile.phoneNumber ?? '';
          _officePhoneController.text = profile.officePhoneNumber ?? '';
          _representativePhoneType = profile.representativePhoneType ?? 'mobile';
          _customPhoneController.text = profile.customPhoneNumber ?? '';
          _isPhonePublic = profile.isPhonePublic;
          _convertTo050 = profile.convertTo050;
          _emailController.text = profile.email ?? '';
          _auxiliaryEmailController.text = profile.auxiliaryEmail ?? '';
          _oneLineIntroController.text = profile.oneLineIntro ?? '';
          _isInitialized = true;
        });
      } else {
        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('프로필 로드 오류: $e');
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _officePhoneController.dispose();
    _customPhoneController.dispose();
    _emailController.dispose();
    _auxiliaryEmailController.dispose();
    _oneLineIntroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인적사항 섹션
          _buildPersonalInfoSection(),
          const SizedBox(height: AppSizes.paddingL),
          // 연락처 정보 섹션
          _buildContactInfoSection(),
          const SizedBox(height: AppSizes.paddingL),
          // 추가 정보 섹션
          _buildAdditionalInfoSection(),
        ],
      ),
    );
  }

  /// 인적사항 섹션
  Widget _buildPersonalInfoSection() {
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
            '인적사항',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXL),
          // 이름
          _buildTextField(
            label: '이름',
            controller: _nameController,
            hint: '이름',
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 생년월일
          _buildDateField(
            label: '생년월일',
            controller: _birthDateController,
            hint: 'YYYY.MM.DD',
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 성별
          _buildGenderField(),
          const SizedBox(height: AppSizes.paddingL),
          // 휴대폰 번호
          _buildPhoneNumberField(),
          const SizedBox(height: AppSizes.paddingM),
          // 알림톡 안내 문구
          _buildNotificationInfo(),
        ],
      ),
    );
  }

  /// 연락처 정보 섹션
  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사무실 전화번호
          _buildTextField(
            label: '사무실 전화번호',
            controller: _officePhoneController,
            hint: '사무실 전화번호',
          ),
          const SizedBox(height: AppSizes.paddingXL),
          // 대표 전화번호
          _buildRepresentativePhoneField(),
          const SizedBox(height: AppSizes.paddingXL),
          // 번호 공개 여부
          _buildPhonePublicToggle(),
          const SizedBox(height: AppSizes.paddingXL),
          // 050번호로 변환
          _build050ConversionToggle(),
          const SizedBox(height: AppSizes.paddingXL),
          // 메일주소
          _buildTextField(
            label: '메일주소',
            controller: _emailController,
            hint: '메일주소',
          ),
        ],
      ),
    );
  }

  /// 추가 정보 섹션
  Widget _buildAdditionalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 보조 메일주소
          _buildTextField(
            label: '보조 메일주소',
            controller: _auxiliaryEmailController,
            hint: '보조 메일주소',
          ),
          const SizedBox(height: AppSizes.paddingXL),
          // 한 줄 소개
          _buildTextField(
            label: '한 줄 소개',
            controller: _oneLineIntroController,
            hint: '한 줄 소개는 매우 중요하므로 10자 이상 입력해주세요.',
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.paddingXL),
          // 저장하기 버튼
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                disabledBackgroundColor: AppColors.textSecondary,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
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

  /// 날짜 필드 빌더
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required String hint,
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
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textSecondary),
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

  /// 날짜 선택
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy.MM.dd').format(picked);
      });
    }
  }

  /// 성별 필드 빌더
  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성별',
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
              child: _buildRadioOption(
                value: 'male',
                label: '남자',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildRadioOption(
                value: 'female',
                label: '여자',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 라디오 옵션 빌더
  Widget _buildRadioOption({
    required String value,
    required String label,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 휴대폰 번호 필드 빌더
  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '휴대폰 번호',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),

        Row(
          children: [
            Flexible(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '휴대폰 번호',
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
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
              width: 88,
              height: AppSizes.buttonHeight,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('휴대폰 번호 변경 기능 준비 중입니다'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
                child: const Text(
                  '변경',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  /// 알림톡 안내 문구
  Widget _buildNotificationInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '로톡 상담 예약 안내 등의 알림이 입력하신 휴대전화로 연결된 카카오톡 알림톡으로 발송됩니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '알림톡 수신이 불가하신 경우, 고객센터로 연락주세요. (02-6959-5080, cs@lawcompany.co.kr)',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '변호사님의 휴대폰 번호는 로앤컴퍼니에서 연락을 드리기 위해 수집하는 것으로, 로톡 서비스 상에 노출되지 않습니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 대표 전화번호 필드 빌더
  Widget _buildRepresentativePhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '대표 전화번호',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          '아래 번호 중 대표 전화번호로 사용할 번호를 선택해주세요.',
          style: TextStyle(
            fontSize: AppSizes.fontS,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        _buildRadioOption(
          value: 'office',
          label: '사무실 전화번호',
          groupValue: _representativePhoneType,
          onChanged: (value) {
            setState(() {
              _representativePhoneType = value!;
            });
          },
        ),
        const SizedBox(height: AppSizes.paddingS),
        _buildRadioOption(
          value: 'mobile',
          label: '휴대폰 번호',
          groupValue: _representativePhoneType,
          onChanged: (value) {
            setState(() {
              _representativePhoneType = value!;
            });
          },
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                value: 'custom',
                label: '직접 입력',
                groupValue: _representativePhoneType,
                onChanged: (value) {
                  setState(() {
                    _representativePhoneType = value!;
                  });
                },
              ),
            ),
            if (_representativePhoneType == 'custom') ...[
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _customPhoneController,
                  decoration: InputDecoration(
                    hintText: '전화번호 입력',
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
          ],
        ),
      ],
    );
  }

  /// 번호 공개 여부 토글
  Widget _buildPhonePublicToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '번호 공개 여부',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Switch(
              value: _isPhonePublic,
              onChanged: (value) {
                setState(() {
                  _isPhonePublic = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          '의뢰인이 직접 연락할 수 있도록 변호사 홈페이지에 대표 전화번호를 노출합니다.',
          style: TextStyle(
            fontSize: AppSizes.fontS,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 050번호로 변환 토글
  Widget _build050ConversionToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '050번호로 변환',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Switch(
              value: _convertTo050,
              onChanged: (value) {
                setState(() {
                  _convertTo050 = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          '개인 정보 보호와 광고 성과 확인을 위해 대표 전화번호를 가상번호로 변경하여 노출합니다. 050번호로 변환하지 않는 경우 선택하신 대표 전화번호가 그대로 노출합니다.',
          style: TextStyle(
            fontSize: AppSizes.fontS,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 저장하기 핸들러
  Future<void> _handleSave() async {
    // 유효성 검증
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이름을 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_birthDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생년월일을 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('휴대폰 번호를 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 이메일 또는 대표 전화번호 타입이 설정되어 있어야 함
    if (_emailController.text.trim().isEmpty && 
        (_representativePhoneType == null || _representativePhoneType.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일 또는 대표 전화번호를 설정해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 사용자 ID 가져오기
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 필요합니다'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final userId = authState.user.id;

      // 기존 프로필 가져오기
      ExpertProfile? existingProfile = await _profileRepository.getProfileByUserId(userId);

      // 생년월일 파싱 (YYYY.MM.DD 형식)
      DateTime? birthDate;
      try {
        if (_birthDateController.text.trim().isNotEmpty) {
          birthDate = DateFormat('yyyy.MM.dd').parse(_birthDateController.text.trim());
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('생년월일 형식이 올바르지 않습니다'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // 대표 전화번호 결정
      String? representativePhone;
      if (_representativePhoneType == 'office') {
        representativePhone = _officePhoneController.text.trim().isEmpty
            ? null
            : _officePhoneController.text.trim();
      } else if (_representativePhoneType == 'mobile') {
        representativePhone = _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim();
      } else if (_representativePhoneType == 'custom') {
        representativePhone = _customPhoneController.text.trim().isEmpty
            ? null
            : _customPhoneController.text.trim();
      }

      // ExpertProfile 생성 또는 업데이트
      final profile = existingProfile != null
          ? existingProfile.copyWith(
              name: _nameController.text.trim().isEmpty
                  ? null
                  : _nameController.text.trim(),
              birthDate: birthDate,
              gender: _gender,
              phoneNumber: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              officePhoneNumber: _officePhoneController.text.trim().isEmpty
                  ? null
                  : _officePhoneController.text.trim(),
              representativePhoneType: _representativePhoneType,
              customPhoneNumber: _representativePhoneType == 'custom'
                  ? (_customPhoneController.text.trim().isEmpty
                      ? null
                      : _customPhoneController.text.trim())
                  : null,
              isPhonePublic: _isPhonePublic,
              convertTo050: _convertTo050,
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              auxiliaryEmail: _auxiliaryEmailController.text.trim().isEmpty
                  ? null
                  : _auxiliaryEmailController.text.trim(),
              oneLineIntro: _oneLineIntroController.text.trim().isEmpty
                  ? null
                  : _oneLineIntroController.text.trim(),
            )
          : ExpertProfile(
              id: '', // 새 프로필인 경우 Firestore에서 자동 생성
              userId: userId,
              name: _nameController.text.trim().isEmpty
                  ? null
                  : _nameController.text.trim(),
              birthDate: birthDate,
              gender: _gender,
              phoneNumber: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              officePhoneNumber: _officePhoneController.text.trim().isEmpty
                  ? null
                  : _officePhoneController.text.trim(),
              representativePhoneType: _representativePhoneType,
              customPhoneNumber: _representativePhoneType == 'custom'
                  ? (_customPhoneController.text.trim().isEmpty
                      ? null
                      : _customPhoneController.text.trim())
                  : null,
              isPhonePublic: _isPhonePublic,
              convertTo050: _convertTo050,
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              auxiliaryEmail: _auxiliaryEmailController.text.trim().isEmpty
                  ? null
                  : _auxiliaryEmailController.text.trim(),
              oneLineIntro: _oneLineIntroController.text.trim().isEmpty
                  ? null
                  : _oneLineIntroController.text.trim(),
            );

      // 프로필 저장
      await _profileRepository.saveProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

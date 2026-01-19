import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/expert_profile.dart';
import '../../../../../../domain/repositories/expert_profile_repository.dart';
import '../../../../../../data/repositories/expert_profile_repository_impl.dart';
import '../../../../../blocs/auth/auth_bloc.dart';
import '../../../../../blocs/auth/auth_state.dart';

/// 기본정보 섹션
class BasicInfoSection extends StatefulWidget {
  final Function(File?)? onProfileImageChanged;

  const BasicInfoSection({
    super.key,
    this.onProfileImageChanged,
  });

  @override
  State<BasicInfoSection> createState() => _BasicInfoSectionState();
}

class _BasicInfoSectionState extends State<BasicInfoSection> {
  final TextEditingController _virtualNumberController = TextEditingController();
  final TextEditingController _examTypeController = TextEditingController();
  final TextEditingController _examSessionController = TextEditingController();
  final TextEditingController _passYearController = TextEditingController(text: '2021');
  bool _isExamPublic = true;
  File? _profileImage;

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
        _isInitialized = true;
        return;
      }

      final userId = authState.user.id;
      final profile = await _profileRepository.getProfileByUserId(userId);

      if (profile != null && mounted) {
        setState(() {
          _virtualNumberController.text = profile.virtualNumber ?? '';
          _examTypeController.text = profile.examType ?? '';
          _examSessionController.text = profile.examSession ?? '';
          if (profile.passYear != null) {
            _passYearController.text = profile.passYear.toString();
          }
          _isExamPublic = profile.isExamPublic;
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
    _virtualNumberController.dispose();
    _examTypeController.dispose();
    _examSessionController.dispose();
    _passYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 사진 업로드 섹션
          _buildProfileImageSection(),
          const SizedBox(height: AppSizes.paddingL),
          // 기본정보 입력 섹션
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
            '기본정보',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXL),
          // 050 가상 번호
          _buildTextField(
            label: '050 가상 번호',
            controller: _virtualNumberController,
            hint: '050 가상 번호',
            enabled: true,
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 출신시험
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '출신시험',
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        '공개',
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Switch(
                        value: _isExamPublic,
                        onChanged: (value) {
                          setState(() {
                            _isExamPublic = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              _buildTextField(
                label: '',
                controller: _examTypeController,
                hint: '변호사시험',
                enabled: true,
              ),
              const SizedBox(height: AppSizes.paddingS),
              _buildTextField(
                label: '',
                controller: _examSessionController,
                hint: '10회',
                enabled: true,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 시험 합격 년도
          _buildTextField(
            label: '시험 합격 년도',
            controller: _passYearController,
            hint: '시험 합격 년도',
            enabled: true,
          ),
          const SizedBox(height: AppSizes.paddingXL),
          // 관리자 연락 안내
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기본정보는 로디코드 관리자만 수정 가능합니다. 수정을 원하시는 경우 로디코드 관리자',
                  style: TextStyle(
                    fontSize: AppSizes.fontS,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // TODO: 전화 걸기
                      },
                      child: Text(
                        '02-1234-5678',
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(
                        fontSize: AppSizes.fontS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: 이메일 보내기
                      },
                      child: Text(
                        'contact@lodicode.co.kr',
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingS),
                const Text(
                  '로 연락주세요!',
                  style: TextStyle(
                    fontSize: AppSizes.fontS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
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
          ),
        ],
      ),
    );
  }

  /// 프로필 사진 업로드 섹션
  Widget _buildProfileImageSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        children: [
          // 프로필 사진
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                  ),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          const Text(
            '아직 프로필 사진이 등록되지 않았어요!',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '좋은 느낌의 프로필 사진은 의뢰인의 선택에 큰 영향을 줍니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '등록할 사진이 로디코드 가이드에 적합하지 않은 사진 있다면 등록이 되지 않을 수 있습니다. 가이드를 참고하시어 적합한 사진을 보내주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          TextButton(
            onPressed: () {
              // TODO: 가이드 페이지로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('가이드 페이지 준비 중입니다')),
              );
            },
            child: const Text(
              '가이드보기 >',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 프로필 사진 선택
  Future<void> _pickProfileImage() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('프로필 사진 선택'),
          content: const Text('사진을 선택하세요'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('카메라'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('갤러리'),
            ),
          ],
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        widget.onProfileImageChanged?.call(_profileImage);
        // TODO: Firebase Storage에 업로드
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 오류: $e')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
        ],
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

  /// 저장하기 핸들러
  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 사용자 ID 가져오기
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인이 필요합니다'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final userId = authState.user.id;

      // 기존 프로필 가져오기
      ExpertProfile? existingProfile = await _profileRepository.getProfileByUserId(userId);

      // 시험 합격 년도 파싱
      int? passYear;
      if (_passYearController.text.trim().isNotEmpty) {
        passYear = int.tryParse(_passYearController.text.trim());
        if (passYear == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('시험 합격 년도는 숫자로 입력해주세요'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
      }

      // ExpertProfile 생성 또는 업데이트
      final profile = existingProfile != null
          ? existingProfile.copyWith(
              virtualNumber: _virtualNumberController.text.trim().isEmpty
                  ? null
                  : _virtualNumberController.text.trim(),
              examType: _examTypeController.text.trim().isEmpty
                  ? null
                  : _examTypeController.text.trim(),
              examSession: _examSessionController.text.trim().isEmpty
                  ? null
                  : _examSessionController.text.trim(),
              passYear: passYear,
              isExamPublic: _isExamPublic,
            )
          : ExpertProfile(
              id: '', // 새 프로필인 경우 Firestore에서 자동 생성
              userId: userId,
              virtualNumber: _virtualNumberController.text.trim().isEmpty
                  ? null
                  : _virtualNumberController.text.trim(),
              examType: _examTypeController.text.trim().isEmpty
                  ? null
                  : _examTypeController.text.trim(),
              examSession: _examSessionController.text.trim().isEmpty
                  ? null
                  : _examSessionController.text.trim(),
              passYear: passYear,
              isExamPublic: _isExamPublic,
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
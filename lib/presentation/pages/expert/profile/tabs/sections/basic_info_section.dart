import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';

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
}


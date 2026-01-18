import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

/// 간편 문의 탭
class SimpleInquiryTab extends StatefulWidget {
  const SimpleInquiryTab({super.key});

  @override
  State<SimpleInquiryTab> createState() => _SimpleInquiryTabState();
}

class _SimpleInquiryTabState extends State<SimpleInquiryTab> {
  // 전화 문의
  bool _isPhoneInquiryEnabled = false;
  final TextEditingController _phoneInquiryController = TextEditingController();

  // 이메일 문의
  bool _isEmailInquiryEnabled = false;
  final TextEditingController _emailInquiryController = TextEditingController();

  // 카카오톡 문의
  bool _isKakaoTalkInquiryEnabled = false;
  final TextEditingController _kakaoTalkInquiryController = TextEditingController();

  @override
  void dispose() {
    _phoneInquiryController.dispose();
    _emailInquiryController.dispose();
    _kakaoTalkInquiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 설명
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
                  '간편 문의를 설정하려면 필수 정보를 입력해 주세요',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Text(
                  '간편 문의로 더 많은 의뢰인과 빠르게 연결될 수 있으며, 상담 가능성을 높일 수 있습니다.',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  '필요 시 사무실 직원이 응대하여 상담을 더욱 효율적으로 진행할 수 있습니다.',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 간편 문의 섹션
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 간편 문의 제목 (자물쇠 아이콘 포함)
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: AppSizes.paddingS),
                    const Text(
                      '간편 문의',
                      style: TextStyle(
                        fontSize: AppSizes.fontL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 전화 문의 섹션
                _buildPhoneInquirySection(),
                const SizedBox(height: AppSizes.paddingXL),
                // 이메일 문의 섹션
                _buildEmailInquirySection(),
                const SizedBox(height: AppSizes.paddingXL),
                // 카카오톡 문의 섹션
                _buildKakaoTalkInquirySection(),
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

  /// 전화 문의 섹션
  Widget _buildPhoneInquirySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목과 토글
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '전화 문의',
              style: TextStyle(
                fontSize: AppSizes.fontL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Switch(
              value: _isPhoneInquiryEnabled,
              onChanged: (value) {
                setState(() {
                  _isPhoneInquiryEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (_isPhoneInquiryEnabled) ...[
          const SizedBox(height: AppSizes.paddingL),
          // 전화번호 입력 필드
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '연락 받을 전화번호 (대표 전화번호)',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    TextField(
                      controller: _phoneInquiryController,
                      keyboardType: TextInputType.phone,
                      enabled: false, // 프로필에서 자동 입력되므로 비활성화
                      decoration: InputDecoration(
                        hintText: '대표 전화번호',
                        filled: true,
                        fillColor: AppColors.background,
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingM,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              TextButton(
                onPressed: () {
                  // TODO: 전화번호 변경 페이지로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('전화번호 변경 기능 준비 중'),
                    ),
                  );
                },
                child: const Text(
                  '변경하기',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 설명 텍스트
          Text(
            '프로필에 설정하신 대표 전화번호로 자동 입력되며, 050 가상번호로 변경하여 노출합니다.',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildBulletPoint(
            '의뢰인이 사무소로 직접 전화해 간단한 문의를 할 수 있습니다.',
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildBulletPoint(
            '변호사님이 직접 답변하거나, 필요에 따라 사무실 직원이 답변할 수 있습니다.',
          ),
        ],
      ],
    );
  }

  /// 이메일 문의 섹션
  Widget _buildEmailInquirySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목과 토글
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '이메일 문의',
              style: TextStyle(
                fontSize: AppSizes.fontL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Switch(
              value: _isEmailInquiryEnabled,
              onChanged: (value) {
                setState(() {
                  _isEmailInquiryEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (_isEmailInquiryEnabled) ...[
          const SizedBox(height: AppSizes.paddingL),
          // 이메일 입력 필드
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '연락 받을 이메일 주소',
                style: TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              TextField(
                controller: _emailInquiryController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'example@email.com',
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
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 설명 텍스트
          _buildBulletPoint(
            '의뢰인은 이메일로 간단한 문의를 할 수 있습니다.',
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildBulletPoint(
            '변호사님이 직접 답변하거나, 필요에 따라 사무실 직원이 답변할 수 있습니다.',
          ),
        ],
      ],
    );
  }

  /// 카카오톡 문의 섹션
  Widget _buildKakaoTalkInquirySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목과 토글
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '카카오톡 문의',
              style: TextStyle(
                fontSize: AppSizes.fontL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Switch(
              value: _isKakaoTalkInquiryEnabled,
              onChanged: (value) {
                setState(() {
                  _isKakaoTalkInquiryEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (_isKakaoTalkInquiryEnabled) ...[
          const SizedBox(height: AppSizes.paddingL),
          // 카카오톡 링크 입력 필드
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '카카오톡 오픈채팅 or 채널 링크',
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  GestureDetector(
                    onTap: () {
                      // TODO: 정보 다이얼로그 표시
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('카카오톡 오픈채팅 링크'),
                          content: const Text(
                            '카카오톡 오픈채팅방 또는 채널 링크를 입력해주세요.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              TextField(
                controller: _kakaoTalkInquiryController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: '채팅방 링크를 입력해 주세요',
                  hintStyle: TextStyle(
                    color: AppColors.primary.withOpacity(0.5),
                  ),
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
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 설명 텍스트
          _buildBulletPoint(
            '의뢰인은 카카오톡 오픈 채팅방 혹은 채널에 간단한 문의를 할 수 있습니다.',
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildBulletPoint(
            '의뢰인이 변호사님 혹은 사무소를 쉽게 알아볼 수 있도록, 채팅방 이름과 프로필을 설정해 주세요.',
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildBulletPoint(
            '변호사님이 직접 답변하거나, 필요에 따라 사무실 직원이 답변할 수 있습니다.',
          ),
        ],
      ],
    );
  }

  /// 불릿 포인트 빌더
  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, right: AppSizes.paddingS),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // 유효성 검증
    if (_isPhoneInquiryEnabled && _phoneInquiryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('전화 문의를 활성화하려면 전화번호를 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isEmailInquiryEnabled) {
      final email = _emailInquiryController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이메일 문의를 활성화하려면 이메일 주소를 입력해주세요'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      // 간단한 이메일 형식 검증
      if (!email.contains('@') || !email.contains('.')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('올바른 이메일 주소를 입력해주세요'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (_isKakaoTalkInquiryEnabled && _kakaoTalkInquiryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카카오톡 문의를 활성화하려면 링크를 입력해주세요'),
          backgroundColor: AppColors.error,
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





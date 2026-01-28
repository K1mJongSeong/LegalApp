import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// 이용약관 페이지
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('이용약관'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: '제1조 (목적)',
                    content:
                        '본 약관은 법디코드(이하 "회사")가 제공하는 법률 정보 서비스의 이용 조건 및 절차를 규정합니다.',
                  ),
                  _buildSection(
                    title: '제2조 (정의)',
                    content:
                        '"서비스"란 회사가 제공하는 법률 상담 정보 및 관련 콘텐츠를 의미합니다. "이용자"란 본 약관에 동의하고 서비스를 이용하는 자를 의미합니다.',
                  ),
                  _buildSection(
                    title: '제3조 (약관의 효력)',
                    content:
                        '본 약관은 서비스 이용 시점부터 효력이 발생합니다.',
                  ),
                  _buildSection(
                    title: '제4조 (서비스 이용)',
                    content:
                        '서비스는 정보 탐색 목적으로만 이용할 수 있습니다. 회사의 사전 동의 없이 상업적 이용, 데이터 수집, 자동화 접근을 금지합니다.',
                  ),
                  _buildSection(
                    title: '제5조 (이용자의 의무)',
                    content: '이용자는 다음 행위를 해서는 안 됩니다.\n'
                        '1. 타인의 개인정보 도용\n'
                        '2. 불법적 목적의 사용\n'
                        '3. 서비스 운영을 방해하는 행위\n'
                        '4. 시스템 해킹 및 무단 접근',
                  ),
                  _buildSection(
                    title: '제6조 (서비스 중단)',
                    content:
                        '회사는 시스템 점검, 기술적 문제 발생 시 서비스 제공을 일시 중단할 수 있습니다.',
                  ),
                  _buildSection(
                    title: '제7조 (책임의 제한)',
                    content:
                        '회사는 서비스 제공 결과에 대해 법적 책임을 지지 않습니다. 이용자가 서비스 정보를 신뢰하여 발생한 손해에 대해 회사는 책임을 부담하지 않습니다.',
                  ),
                  _buildSection(
                    title: '제8조 (약관 변경)',
                    content:
                        '회사는 필요 시 본 약관을 변경할 수 있으며, 변경 시 서비스 내 공지합니다.',
                  ),
                  _buildSection(
                    title: '제9조 (준거법)',
                    content: '본 약관은 대한민국 법률을 따릅니다.',
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  Center(
                    child: Text(
                      '시행일: 2026년 1월 1일',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontS,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            content,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

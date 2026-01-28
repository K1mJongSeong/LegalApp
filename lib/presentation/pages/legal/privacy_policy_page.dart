import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// 개인정보처리방침 페이지
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('개인정보처리방침'),
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
                    title: '제1조 (개인정보의 수집 및 이용 목적)',
                    content:
                        '회사는 다음의 목적을 위하여 개인정보를 처리합니다.\n'
                        '1. 회원 가입 및 관리\n'
                        '2. 서비스 제공 및 운영\n'
                        '3. 고객 문의 응대 및 불만 처리\n'
                        '4. 서비스 개선 및 신규 서비스 개발',
                  ),
                  _buildSection(
                    title: '제2조 (수집하는 개인정보 항목)',
                    content:
                        '회사는 서비스 제공을 위해 다음의 개인정보를 수집합니다.\n'
                        '1. 필수항목: 이메일, 이름, 비밀번호\n'
                        '2. 선택항목: 프로필 사진, 연락처\n'
                        '3. 자동 수집항목: 접속 IP, 쿠키, 서비스 이용 기록',
                  ),
                  _buildSection(
                    title: '제3조 (개인정보의 보유 및 이용 기간)',
                    content:
                        '회사는 개인정보 수집 및 이용 목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다. '
                        '단, 관계 법령에 따라 보존할 필요가 있는 경우 해당 기간 동안 보관합니다.\n\n'
                        '1. 계약 또는 청약철회 등에 관한 기록: 5년\n'
                        '2. 대금결제 및 재화 등의 공급에 관한 기록: 5년\n'
                        '3. 소비자의 불만 또는 분쟁처리에 관한 기록: 3년\n'
                        '4. 접속에 관한 기록: 3개월',
                  ),
                  _buildSection(
                    title: '제4조 (개인정보의 제3자 제공)',
                    content:
                        '회사는 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. '
                        '다만, 다음의 경우에는 예외로 합니다.\n'
                        '1. 이용자가 사전에 동의한 경우\n'
                        '2. 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우',
                  ),
                  _buildSection(
                    title: '제5조 (개인정보의 파기)',
                    content:
                        '회사는 개인정보 보유 기간의 경과, 처리 목적 달성 등 개인정보가 불필요하게 되었을 때에는 '
                        '지체 없이 해당 개인정보를 파기합니다.\n\n'
                        '1. 전자적 파일 형태: 복구 불가능한 방법으로 영구 삭제\n'
                        '2. 종이 문서: 분쇄기로 분쇄하거나 소각',
                  ),
                  _buildSection(
                    title: '제6조 (이용자의 권리)',
                    content:
                        '이용자는 언제든지 다음의 권리를 행사할 수 있습니다.\n'
                        '1. 개인정보 열람 요구\n'
                        '2. 오류 등이 있을 경우 정정 요구\n'
                        '3. 삭제 요구\n'
                        '4. 처리 정지 요구',
                  ),
                  _buildSection(
                    title: '제7조 (개인정보 보호책임자)',
                    content:
                        '회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, '
                        '개인정보 처리와 관련한 이용자의 불만 처리 및 피해 구제 등을 위하여 '
                        '아래와 같이 개인정보 보호책임자를 지정하고 있습니다.\n\n'
                        '개인정보 보호책임자\n'
                        '- 이메일: privacy@lawdecode.com',
                  ),
                  _buildSection(
                    title: '제8조 (개인정보 처리방침 변경)',
                    content:
                        '이 개인정보처리방침은 시행일로부터 적용되며, '
                        '법령 및 방침에 따른 변경 내용의 추가, 삭제 및 정정이 있는 경우에는 '
                        '변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.',
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

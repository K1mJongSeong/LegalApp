import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// 사건 전송 완료 안내 페이지
class CaseSubmissionCompletePage extends StatelessWidget {
  const CaseSubmissionCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('사건 전송 완료'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 안내 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 아이콘
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingL),
                        // 제목
                        const Text(
                          '베타서비스 안내',
                          style: TextStyle(
                            fontSize: AppSizes.fontXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        // 내용
                        Text(
                          '베타서비스로 인한 전문가에게 사건 전송 불가 및 상담 글 작성 및 작성 내역 저장 안내',
                          style: const TextStyle(
                            fontSize: AppSizes.fontM,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingL),
                        // 상세 설명
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoItem('• 현재 베타서비스 기간 중으로 실제 전문가에게 사건이 전송되지 않습니다.'),
                              const SizedBox(height: AppSizes.paddingS),
                              _buildInfoItem('• 작성하신 상담 글은 저장되어 마이페이지에서 확인하실 수 있습니다.'),
                              const SizedBox(height: AppSizes.paddingS),
                              _buildInfoItem('• 정식 서비스 오픈 시 자동으로 전문가에게 전송됩니다.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  // 설문 참여 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _launchSurvey(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                      child: const Text(
                        '설문 참여하고 무료상담 쿠폰 받기',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  // 마이페이지로 이동 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.myPage,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                      child: const Text(
                        '마이페이지로 이동',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppSizes.fontS,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
    );
  }

  /// 설문조사 페이지 열기
  Future<void> _launchSurvey(BuildContext context) async {
    final Uri url = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLScvYEXxBHnNJpuBoBKxQh6avjrx5ZwkcJC6BpWt46Y9VwQtTA/viewform?usp=publish-editor',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설문 페이지를 열 수 없습니다')),
      );
    }
  }
}



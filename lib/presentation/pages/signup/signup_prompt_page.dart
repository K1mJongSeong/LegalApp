import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/common/primary_button.dart';
import 'signup_page.dart';

/// 회원가입 안내 / 전문가 추천 화면
class SignupPromptPage extends StatelessWidget {
  final String? category;
  final String? urgency;

  const SignupPromptPage({
    super.key,
    this.category,
    this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('전문가 상담'),
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
                  // 아이콘
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  const Text(
                    '전문가를 찾고 계신가요?',
                    style: TextStyle(
                      fontSize: AppSizes.fontXXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  const Text(
                    '회원가입 후 전문가와\n상담을 시작해보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontL,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXXL),
                  PrimaryButton(
                    text: '전문가 목록 보기',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '${AppRoutes.experts}?urgency=${urgency ?? 'simple'}',
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  PrimaryButton(
                    text: '회원가입하기',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('나중에 할게요'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// 앱 진입 화면 (로그인/비회원 선택)
class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    (AppSizes.paddingXL * 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // 로고 아이콘
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.balance,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  // 앱 이름
                  const Text(
                    '로디코드',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  // 태그라인
                  Text(
                    '당신과 법의 연결고리',
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 80),
                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '로그인 하기',
                        style: TextStyle(
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  // 비회원 이용 버튼
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                      child: const Text(
                        '비회원 이용하기',
                        style: TextStyle(
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                  // 하단 문구
                  Text(
                    '법률 전문가와의 빠른 연결, 지금 시작하세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
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
}


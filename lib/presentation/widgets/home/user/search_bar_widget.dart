import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';

/// 검색바 위젯
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: '어떤 법률 문제가 있으신가요?',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingM,
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pushNamed(context, AppRoutes.caseInput);
          }
        },
      ),
    );
  }
}













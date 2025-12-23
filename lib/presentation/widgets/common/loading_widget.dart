import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// 로딩 위젯
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSizes.paddingM),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontM,
              ),
            ),
          ],
        ],
      ),
    );
  }
}



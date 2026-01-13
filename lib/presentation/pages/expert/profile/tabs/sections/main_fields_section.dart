import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_sizes.dart';

/// 주요분야 섹션
class MainFieldsSection extends StatelessWidget {
  const MainFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: const Center(
        child: Text('주요분야 섹션 준비 중'),
      ),
    );
  }
}




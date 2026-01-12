import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_sizes.dart';


/// 인적사항 섹션
class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: const Center(
        child: Text('인적사항 섹션 준비 중'),
      ),
    );
  }
}


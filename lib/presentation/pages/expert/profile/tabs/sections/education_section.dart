import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_sizes.dart';


/// 학력사항 섹션
class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: const Center(
        child: Text('학력사항 섹션 준비 중'),
      ),
    );
  }
}




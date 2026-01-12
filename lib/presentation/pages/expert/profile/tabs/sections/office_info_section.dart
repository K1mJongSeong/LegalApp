import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_sizes.dart';


/// 사무실 정보 섹션
class OfficeInfoSection extends StatelessWidget {
  const OfficeInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: const Center(
        child: Text('사무실 정보 섹션 준비 중'),
      ),
    );
  }
}


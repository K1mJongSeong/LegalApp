import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import 'sections/basic_info_section.dart';
import 'sections/personal_info_section.dart';
import 'sections/education_section.dart';
import 'sections/main_fields_section.dart';
import 'sections/office_info_section.dart';

/// 필수정보 탭
class RequiredInfoTab extends StatefulWidget {
  const RequiredInfoTab({super.key});

  @override
  State<RequiredInfoTab> createState() => _RequiredInfoTabState();
}

class _RequiredInfoTabState extends State<RequiredInfoTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 5, vsync: this);
    _subTabController.addListener(() {
      setState(() {}); // 탭 변경 시 UI 업데이트
    });
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 가이드보기 링크
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton(
          //     onPressed: () {
          //       // TODO: 가이드 페이지로 이동
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(content: Text('가이드 페이지 준비 중입니다')),
          //       );
          //     },
          //     child: const Text(
          //       '가이드보기 >',
          //       style: TextStyle(
          //         fontSize: AppSizes.fontM,
          //         color: AppColors.primary,
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(height: AppSizes.paddingM),
          // 제목 및 설명
          const Text(
            '필수정보를 입력해 주세요.',
            style: TextStyle(
              fontSize: AppSizes.fontXXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '필수정보는 로디코드에서 변호사로 활동하기 위해 필수로 입력해야하는 정보입니다. 입력 단계가 100%가 되어야 의뢰인에게 변호사프로필이 노출됩니다.',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 하위 탭 (그리드 형태)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // 첫 번째 행 (3개 탭)
                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTab(
                        index: 0,
                        text: '기본정보',
                        hasAsterisk: false,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildCustomTab(
                        index: 1,
                        text: '인적사항',
                        hasAsterisk: true,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildCustomTab(
                        index: 2,
                        text: '학력사항',
                        hasAsterisk: true,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: AppColors.border,
                ),
                // 두 번째 행 (2개 탭)
                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTab(
                        index: 3,
                        text: '주요분야',
                        hasAsterisk: true,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildCustomTab(
                        index: 4,
                        text: '사무실 정보',
                        hasAsterisk: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 탭 내용
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: TabBarView(
              controller: _subTabController,
              children: const [
                BasicInfoSection(),
                PersonalInfoSection(),
                EducationSection(),
                MainFieldsSection(),
                OfficeInfoSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab({
    required int index,
    required String text,
    required bool hasAsterisk,
  }) {
    final isSelected = _subTabController.index == index;

    return GestureDetector(
      onTap: () => _subTabController.animateTo(index),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: _getTabBorderRadius(index),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                if (hasAsterisk) ...[
                  const SizedBox(width: 2),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B00),
                    ),
                  ),
                ],
              ],
            ),

            // 하단 indicator
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isSelected ? 32 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// 탭 인덱스에 따른 BorderRadius 반환
  BorderRadius _getTabBorderRadius(int index) {
    switch (index) {
      case 0: // 기본정보 (왼쪽 위)
        return const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusM),
        );
      case 2: // 학력사항 (오른쪽 위)
        return const BorderRadius.only(
          topRight: Radius.circular(AppSizes.radiusM),
        );
      case 3: // 주요분야 (왼쪽 아래)
        return const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusM),
        );
      case 4: // 사무실 정보 (오른쪽 아래)
        return const BorderRadius.only(
          bottomRight: Radius.circular(AppSizes.radiusM),
        );
      default:
        return BorderRadius.zero;
    }
  }

}


import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import 'sections/career_section.dart';
import 'sections/qualification_section.dart';
import 'sections/award_section.dart';
import 'sections/publication_section.dart';

/// 추가정보 탭
class AdditionalInfoTab extends StatefulWidget {
  const AdditionalInfoTab({super.key});

  @override
  State<AdditionalInfoTab> createState() => _AdditionalInfoTabState();
}

class _AdditionalInfoTabState extends State<AdditionalInfoTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 9, vsync: this);
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
          const SizedBox(height: AppSizes.paddingM),
          // 제목 및 설명
          const Text(
            '추가 정보를 입력해 주세요.',
            style: TextStyle(
              fontSize: AppSizes.fontXXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '변호사님의 정보가 많을수록, 의뢰인이 선택할때 더 좋은 기준이 됩니다.',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 하위 탭 (3x3 그리드 형태)
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
                        text: '경력사항',
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
                        text: '자격사항',
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
                        text: '수상내역',
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: AppColors.border,
                ),
                // 두 번째 행 (3개 탭)
                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTab(
                        index: 3,
                        text: '논문/출판',
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
                        text: '보도자료',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildCustomTab(
                        index: 5,
                        text: '세금계산서 정보',
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: AppColors.border,
                ),
                // 세 번째 행 (3개 탭)
                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTab(
                        index: 6,
                        text: '기타활동',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildCustomTab(
                        index: 7,
                        text: '수임료 정보',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildCustomTab(
                        index: 8,
                        text: '서비스 요금',
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
                CareerSection(),
                QualificationSection(),
                AwardSection(),
                PublicationSection(),
                Center(child: Text('보도자료 섹션 준비 중')),
                Center(child: Text('세금계산서 정보 섹션 준비 중')),
                Center(child: Text('기타활동 섹션 준비 중')),
                Center(child: Text('수임료 정보 섹션 준비 중')),
                Center(child: Text('서비스 요금 섹션 준비 중')),
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
            Text(
              text,
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      case 0: // 경력사항 (왼쪽 위)
        return const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusM),
        );
      case 2: // 수상내역 (오른쪽 위)
        return const BorderRadius.only(
          topRight: Radius.circular(AppSizes.radiusM),
        );
      case 6: // 기타활동 (왼쪽 아래)
        return const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusM),
        );
      case 8: // 서비스 요금 (오른쪽 아래)
        return const BorderRadius.only(
          bottomRight: Radius.circular(AppSizes.radiusM),
        );
      default:
        return BorderRadius.zero;
    }
  }
}


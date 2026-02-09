import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

/// 추천 카드 위젯
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3D4A7A),
            Color(0xFF2D3A6A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: Stack(
          children: [
            // 오른쪽 하단 장식 이미지 영역
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 120,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8, bottom: 8),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            // 텍스트 콘텐츠
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: const Text(
                      '로디코드의 추천',
                      style: TextStyle(
                        fontSize: AppSizes.fontXS,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  const Text(
                    '상속 전문 호사로 활동해 보세요!',
                    style: TextStyle(
                      fontSize: AppSizes.fontXL,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    '상속 분야 상담 요청이 증가하고 있습니다!',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

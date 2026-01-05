import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// 법률 분야 선택 페이지
class CategorySelectPage extends StatelessWidget {
  const CategorySelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('법률 분야 선택'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            _buildCategoryTile(
              context,
              Icons.gavel,
              '형사',
              '폭행/상해, 성범죄, 사기, 횡령/배임...',
              'criminal',
            ),
            _buildCategoryTile(
              context,
              Icons.description,
              '민사',
              '손해배상, 계약, 채권추심, 부당이득',
              'civil',
            ),
            _buildCategoryTile(
              context,
              Icons.favorite,
              '가족관계',
              '이혼, 양육권, 재산분할, 상속',
              'family',
            ),
            _buildCategoryTile(
              context,
              Icons.work,
              '노동/근로',
              '부당해고, 임금체불, 산재, 퇴직금',
              'labor',
            ),
            _buildCategoryTile(
              context,
              Icons.home,
              '부동산/임대차',
              '전월세, 매매, 명도, 재개발',
              'real',
            ),
            _buildCategoryTile(
              context,
              Icons.directions_car,
              '교통사고',
              '인적피해, 물적피해, 뺑소니, 음주...',
              'traffic',
            ),
            _buildCategoryTile(
              context,
              Icons.business,
              '기업/창업',
              '계약서, 투자, 지적재산권, 노무',
              'business',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String category,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/case-detail-input',
            arguments: {'category': category, 'categoryName': title},
          );
        },
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: AppSizes.fontS,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}









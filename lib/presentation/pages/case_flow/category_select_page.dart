import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// 법률 분야 선택 페이지
class CategorySelectPage extends StatefulWidget {
  const CategorySelectPage({super.key});

  @override
  State<CategorySelectPage> createState() => _CategorySelectPageState();
}

class _CategorySelectPageState extends State<CategorySelectPage> {
  String? _selectedCategory;
  String? _selectedCategoryName;

  // 카테고리 목록
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'labor',
      'name': '직장 / 노동',
      'subtitle': '해고, 임금체불, 근로계약',
      'icon': Icons.work,
      'subCategories': [
        '기업법무',
        '노동·인사',
      ],
    },
    {
      'id': 'real_estate',
      'name': '부동산 / 임대차',
      'subtitle': '전월세, 매매, 계약분쟁',
      'icon': Icons.home,
      'subCategories': [
        '건축·부동산 일반',
        '재개발·재건축',
        '매매·소유권 등',
        '임대차',
      ],
    },
    {
      'id': 'traffic',
      'name': '교통사고',
      'subtitle': '사고합의, 보험처리',
      'icon': Icons.directions_car,
      'subCategories': [
        '교통사고·도주',
        '음주·무면허',
      ],
    },
    {
      'id': 'criminal',
      'name': '형사',
      'subtitle': '고소, 고발, 형사사건',
      'icon': Icons.gavel,
      'subCategories': [
        '성범죄',
        '재산범죄',
        '교통사고·범죄',
        '형사절차',
        '폭행·협박',
        '명예훼손·모욕',
        '기타 형사범죄',
      ],
    },
    {
      'id': 'civil',
      'name': '민사',
      'subtitle': '계약, 손해배상, 채권',
      'icon': Icons.description,
      'subCategories': [
        '부동산·임대차',
        '금전·계약 문제',
        '민사절차',
        '기타 민사문제',
      ],
    },
    {
      'id': 'family',
      'name': '가사',
      'subtitle': '이혼, 상속, 양육권',
      'icon': Icons.favorite,
      'subCategories': [
        '이혼',
        '상속',
        '가사 일반',
      ],
    },
    {
      'id': 'company',
      'name': '회사',
      'subtitle': '기업법무, 노동·인사',
      'icon': Icons.business,
      'subCategories': [
        '기업법무',
        '노동·인사',
      ],
    },
    {
      'id': 'medical_tax_admin',
      'name': '의료·세금·행정',
      'subtitle': '세금·행정·헌법, 의료·식품·의약, 병역·군형법',
      'icon': Icons.local_hospital,
      'subCategories': [
        '세금·행정·헌법',
        '의료·식품·의약',
        '병역·군형법',
      ],
    },
    {
      'id': 'it_ip_finance',
      'name': 'IT·지식재산·금융',
      'subtitle': '소비자·공정거래, IT·개인정보, 지식재산권·엔터, 금융·보험',
      'icon': Icons.computer,
      'subCategories': [
        '소비자·공정거래',
        'IT·개인정보',
        '지식재산권·엔터',
        '금융·보험',
      ],
    },
  ];

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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                children: [
                  // 주요 카테고리 목록
                  ..._categories.map((category) {
                    return _buildCategoryTile(
                      category['id'] as String,
                      category['name'] as String,
                      category['subtitle'] as String,
                      category['icon'] as IconData,
                    );
                  }),
                  const SizedBox(height: AppSizes.paddingS),
                  // "잘 모르겠어요" 옵션
                  _buildUnknownOption(),
                ],
              ),
            ),
            // 하단 "다음" 버튼
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    String categoryId,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == categoryId;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            if (_selectedCategory == categoryId) {
              _selectedCategory = null;
              _selectedCategoryName = null;
            } else {
              _selectedCategory = categoryId;
              _selectedCategoryName = title;
            }
          });
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
            border: Border.all(
              color: AppColors.primary,
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              )
            : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
      ),
    );
  }

  Widget _buildUnknownOption() {
    final isSelected = _selectedCategory == 'unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: isSelected
            ? Border.all(
                color: AppColors.primary,
                width: 2,
              )
            : Border.all(
                color: AppColors.border.withOpacity(0.5),
                width: 1,
                style: BorderStyle.solid,
              ),
      ),
      child: ListTile(
            onTap: () {
              setState(() {
                if (_selectedCategory == 'unknown') {
                  _selectedCategory = null;
                  _selectedCategoryName = null;
                } else {
                  _selectedCategory = 'unknown';
                  _selectedCategoryName = '잘 모르겠어요';
                }
              });
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
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
              ),
            ),
            title: const Text(
              '잘 모르겠어요',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  )
                : null,
          ),
      );
  }

  Widget _buildNextButton() {
    final isEnabled = _selectedCategory != null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  if (_selectedCategory == 'unknown') {
                    // 잘 모르겠어요 선택 시 - 다음 단계로 바로 이동하지 않음
                    // 또는 특별한 처리
                    Navigator.pushNamed(
                      context,
                      AppRoutes.caseProgress,
                      arguments: {
                        'category': 'unknown',
                        'categoryName': '잘 모르겠어요',
                      },
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.caseProgress,
                      arguments: {
                        'category': _selectedCategory,
                        'categoryName': _selectedCategoryName,
                      },
                    );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            elevation: 0,
          ),
          child: const Text(
            '다음',
            style: TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
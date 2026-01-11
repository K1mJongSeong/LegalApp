import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// 로디코드 AD 페이지 (전문가용)
class ExpertAdPage extends StatefulWidget {
  const ExpertAdPage({super.key});

  @override
  State<ExpertAdPage> createState() => _ExpertAdPageState();
}

class _ExpertAdPageState extends State<ExpertAdPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('로디코드 AD'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 배너
            _buildTopBanner(),

            const SizedBox(height: AppSizes.paddingM),

            // 통계 카드
            _buildStatsSection(),

            const SizedBox(height: AppSizes.paddingM),

            // AD 상품별 특징 안내
            _buildAdTipCard(),

            const SizedBox(height: AppSizes.paddingL),

            // 탭바
            _buildTabBar(),

            const SizedBox(height: AppSizes.paddingM),

            // 탭별 컨텐츠
            _buildTabContent(),

            const SizedBox(height: AppSizes.paddingXL),

            // 하단 CTA 배너
            _buildBottomCTA(),

            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  /// 상단 배너
  Widget _buildTopBanner() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 광고 솔루션 태그
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                      SizedBox(width: 6),
                      Text(
                        '광고 솔루션',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                const Text(
                  '의뢰인에게\n더 잘 보이세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  '로디코드의 광고 상품으로 의뢰\n인이 방문하는\n가장 효과적인 위치에 프로필을\n노출하세요',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: AppSizes.fontS,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // 차트 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bar_chart,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 섹션
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: '월 가입자',
              value: '50만',
              description: '매일 로디코드를 방문',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: _buildStatCard(
              title: '상담 전환',
              value: '58.4%',
              description: '후기가 기여하는 비율',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 카드
  Widget _buildStatCard({
    required String title,
    required String value,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: AppSizes.fontXS,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// AD 상품별 특징 안내
  Widget _buildAdTipCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AD 상품별 특징',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontM,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '분야/플러스/포커스 광고를 함께 진행하면 광고 효과를 극대화할 수 있습니다',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: AppSizes.fontXS,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 탭바
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: _getTabColor(_tabController.index),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AppSizes.fontM,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: AppSizes.fontM,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '분야광고'),
          Tab(text: '플러스광고'),
          Tab(text: '포커스광고'),
        ],
      ),
    );
  }

  /// 탭 색상 가져오기
  Color _getTabColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primary;
      case 1:
        return Colors.orange;
      case 2:
        return const Color(0xFF1a237e);
      default:
        return AppColors.primary;
    }
  }

  /// 탭별 컨텐츠
  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0:
        return _buildFieldAdContent();
      case 1:
        return _buildPlusAdContent();
      case 2:
        return _buildFocusAdContent();
      default:
        return _buildFieldAdContent();
    }
  }

  /// 분야광고 컨텐츠
  Widget _buildFieldAdContent() {
    return Column(
      children: [
        // 분야광고 카드
        _buildAdCard(
          title: '분야광고',
          price: '25만원/월',
          icon: Icons.people_outline,
          color: AppColors.primary,
          features: [
            '분야 관련 모든 검색결과에 프로필 노출',
            '통합검색 및 변호사검색 상단 노출',
            '유료상담이 가장 많이 발생하는 영역',
            '프로필사진, 광고문구, 강조태그 활용',
          ],
        ),

        const SizedBox(height: AppSizes.paddingL),

        // 노출 위치
        _buildExposureSection(),

        const SizedBox(height: AppSizes.paddingL),

        // 분야광고의 특징
        _buildFieldAdFeatures(),

        const SizedBox(height: AppSizes.paddingL),

        // 분야 선택 안내
        _buildFieldSelectionGuide(),

        const SizedBox(height: AppSizes.paddingL),

        // 과금 방식
        _buildPricingSection(
          items: [
            '분야 1개당 월 25만원 (VAT 별도)',
            '광고 영역 내 동일 확률로 임의의 순서 노출',
            '언제든지 분야 추가/변경 가능',
          ],
        ),
      ],
    );
  }

  /// 플러스광고 컨텐츠
  Widget _buildPlusAdContent() {
    return Column(
      children: [
        // 플러스광고 카드
        _buildAdCard(
          title: '플러스광고',
          price: '25만원/월',
          icon: Icons.person_outline,
          color: Colors.orange,
          features: [
            '온라인상담 사례게시판의 AD+ LAWYERS 영역 노출',
            '답변을 하지 못해도 프로필이 매번 표시됨',
            '변호사 답변 상단에 차별화된 디자인으로 노출',
            '상담 예약 버튼으로 바로 상담 연결',
          ],
        ),

        const SizedBox(height: AppSizes.paddingL),

        // 플러스광고 특징
        _buildPlusAdFeatures(),

        const SizedBox(height: AppSizes.paddingL),

        // 과금 방식
        _buildPricingSection(
          items: [
            '월 25만원 (VAT 별도)',
            '온라인상담 게시판 전체에 노출',
            '언제든지 구독 시작/해지 가능',
          ],
        ),
      ],
    );
  }

  /// 포커스광고 컨텐츠
  Widget _buildFocusAdContent() {
    return Column(
      children: [
        // 포커스광고 카드
        _buildAdCard(
          title: '포커스광고',
          price: '25만원/월',
          icon: Icons.gps_fixed,
          color: const Color(0xFF1a237e),
          features: [
            '유료상담 예약 완료 페이지에 프로필 노출',
            '온라인상담글 작성 완료 페이지에 프로필 노출',
            'AI 모델로 법률분야 정확 파악 후 노출',
            '상담료 할인쿠폰으로 전환율 향상',
          ],
        ),

        const SizedBox(height: AppSizes.paddingL),

        // 포커스광고 특징
        _buildFocusAdFeatures(),

        const SizedBox(height: AppSizes.paddingL),

        // 과금 방식
        _buildPricingSection(
          items: [
            '월 25만원 (VAT 별도)',
            'AI 기반 정확한 타겟팅',
            '할인쿠폰 자동 발급 기능 포함',
          ],
        ),
      ],
    );
  }

  /// 광고 카드
  Widget _buildAdCard({
    required String title,
    required String price,
    required IconData icon,
    required Color color,
    required List<String> features,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: AppSizes.fontM,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            '주요 기능',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: AppSizes.fontS,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: AppSizes.fontM,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: AppSizes.fontS,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// 노출 위치 섹션
  Widget _buildExposureSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '노출 위치',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildExposureCard(
            title: '통합검색결과',
            description: '분야 관련 키워드 검색 시 통합탭 상단 노출',
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildExposureCard(
            title: '변호사검색결과',
            description: '분야 선택 후 변호사탭 가장 상단 노출',
          ),
        ],
      ),
    );
  }

  /// 노출 카드
  Widget _buildExposureCard({
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 분야광고 특징
  Widget _buildFieldAdFeatures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '분야광고의 특징',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildFeatureItem(
            title: '광범위한 노출',
            description: '의뢰인의 접근성이 가장 좋은 곳에 노출됩니다',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            title: '다양한 정보',
            description: '프로필사진, 광고문구, 강조태그 등으로 어필 가능',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            title: '공정한 노출',
            description: '광고 영역 내에서 동일 확률, 임의의 순서로 노출',
          ),
        ],
      ),
    );
  }

  /// 플러스광고 특징
  Widget _buildPlusAdFeatures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '플러스광고의 특징',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildFeatureItem(
            title: '지속적인 노출',
            description: '답변 여부와 관계없이 항상 프로필이 노출됩니다',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            title: '차별화된 디자인',
            description: 'AD+ LAWYERS 전용 영역에서 눈에 띄게 노출',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            title: '바로 상담 연결',
            description: '상담 예약 버튼으로 즉시 의뢰인과 연결 가능',
          ),
        ],
      ),
    );
  }

  /// 포커스광고 특징
  Widget _buildFocusAdFeatures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '포커스광고의 특징',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildFeatureItem(
            title: 'AI 기반 타겟팅',
            description: 'AI가 의뢰인의 법률 분야를 정확히 파악하여 노출',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            title: '완료 페이지 노출',
            description: '예약/글작성 완료 시점에 집중 노출',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            title: '전환율 향상',
            description: '할인쿠폰 자동 발급으로 상담 전환율 증가',
          ),
        ],
      ),
    );
  }

  /// 특징 아이템
  Widget _buildFeatureItem({
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 분야 선택 안내
  Widget _buildFieldSelectionGuide() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '분야 선택 안내',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildGuideItem('로톡 내 총 40개 분야 중 원하는 분야 선택 가능'),
          const SizedBox(height: AppSizes.paddingM),
          _buildGuideItem('광고를 구매한 분야 중 추가 광고 구매 가능'),
          const SizedBox(height: AppSizes.paddingM),
          _buildGuideItem('합리적인 개수 한도 내에서 광고 구매 가능'),
        ],
      ),
    );
  }

  /// 가이드 아이템
  Widget _buildGuideItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check, color: AppColors.primary, size: 18),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 과금 방식
  Widget _buildPricingSection({required List<String> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '과금 방식',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: AppSizes.fontM,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: AppSizes.fontS,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// 하단 CTA 배너
  Widget _buildBottomCTA() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            const Color(0xFF1a237e),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        children: [
          const Text(
            '광고로 의뢰인을\n더 많이 만나세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '분야/플러스/포커스 광고를 조합하여\n최대 광고 효과를 누려보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: AppSizes.fontM,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('광고 신청 기능은 준비 중입니다')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '광고 신청하기',
                    style: TextStyle(
                      fontSize: AppSizes.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

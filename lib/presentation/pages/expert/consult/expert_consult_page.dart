import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// 온라인 상담 페이지 (전문가용)
class ExpertConsultPage extends StatefulWidget {
  const ExpertConsultPage({super.key});

  @override
  State<ExpertConsultPage> createState() => _ExpertConsultPageState();
}

class _ExpertConsultPageState extends State<ExpertConsultPage>
    with SingleTickerProviderStateMixin {
  // 상담 유형 선택 (0: 전화, 1: 방문)
  int _selectedConsultType = 0;

  // 탭 컨트롤러 (상담료 설정 / 상담 시간 설정)
  late TabController _tabController;

  // 상담료 입력
  final TextEditingController _phoneConsultFeeController =
      TextEditingController(text: '20000');
  final TextEditingController _visitConsultFeeController =
      TextEditingController(text: '50000');

  // 상담 활성화 토글
  bool _isPhoneConsultEnabled = false;
  bool _isVisitConsultEnabled = false;

  // FAQ 확장 상태
  final Map<int, bool> _faqExpanded = {0: false, 1: false, 2: false};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener((){
      if(_tabController.indexIsChanging) return;

      setState(() {
        _selectedConsultType = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneConsultFeeController.dispose();
    _visitConsultFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('온라인 상담'),
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

            // 자동 정산 안내 카드
            _buildAutoSettlementCard(),

            const SizedBox(height: AppSizes.paddingL),

            // 상담 유형 선택
            _buildConsultTypeSection(),

            const SizedBox(height: AppSizes.paddingM),

            // 탭바 (상담료 설정 / 상담 시간 설정)
            _buildTabBar(),

            // 상담료 설정 섹션
            _buildConsultFeeSection(),

            const SizedBox(height: AppSizes.paddingM),

            // 상담료 저장 버튼
            _buildSaveButton(),

            const SizedBox(height: AppSizes.paddingXL),

            // 상담 진행 절차
            _buildProcessSection(),

            const SizedBox(height: AppSizes.paddingXL),

            // 자주 묻는 질문
            _buildFAQSection(),

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상담 솔루션 태그
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow, size: 16),
                SizedBox(width: 6),
                Text(
                  '상담 솔루션',
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
            '쉽고 간편하게\n상담료를 설정하세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '전화상담과 방문상담 중 선택하여 상담료와\n시간을 설정하면 의뢰인이 예약할 수 있습니다.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: AppSizes.fontM,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 자동 정산 안내 카드
  Widget _buildAutoSettlementCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '상담료는 자동 정산됩니다',
                  style: TextStyle(
                    fontSize: AppSizes.fontL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '상담 완료 후 5영업일 뒤 PAYAPP에서 자동으로 입금되며, 세금 계산서는 별도로 발행하지 않습니다.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: AppSizes.fontS,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 상담 유형 선택
  Widget _buildConsultTypeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상담 유형 선택',
            style: TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildConsultTypeCard(
                  index: 0,
                  icon: Icons.phone,
                  title: '전화 상담',
                  duration: '15분',
                  priceRange: '2~5만원',
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _buildConsultTypeCard(
                  index: 1,
                  icon: Icons.location_on,
                  title: '방문 상담',
                  duration: '30분',
                  priceRange: '5~30만원',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 상담 유형 카드
  Widget _buildConsultTypeCard({
    required int index,
    required IconData icon,
    required String title,
    required String duration,
    required String priceRange,
  }) {
    final isSelected = _selectedConsultType == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedConsultType = index),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey[400],
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.fontL,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.textPrimary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              duration,
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              priceRange,
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.orange : Colors.grey[400],
              ),
            ),
          ],
        ),
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
          color: AppColors.primary,
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
          Tab(text: '상담료 설정'),
          Tab(text: '상담 시간 설정'),
        ],
      ),
    );
  }

  /// 상담료 설정 섹션
  Widget _buildConsultFeeSection() {
    final isPhone = _selectedConsultType == 0;
    final controller = isPhone ? _phoneConsultFeeController : _visitConsultFeeController;
    final isEnabled = isPhone ? _isPhoneConsultEnabled : _isVisitConsultEnabled;
    final consultType = isPhone ? '전화' : '방문';
    final duration = isPhone ? '15분' : '30분';
    final priceRange = isPhone ? '2~5만원' : '5~30만원';

    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
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
            '$consultType 상담료 설정',
            style: const TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      color: Colors.grey[700],
                    ),
                    children: [
                      TextSpan(text: '$duration $consultType상담 요금을 '),
                      TextSpan(
                        text: priceRange,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' 사이로 설정하세요'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical: AppSizes.paddingM,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    const Text(
                      '원',
                      style: TextStyle(
                        fontSize: AppSizes.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '상담 활성화',
                    style: TextStyle(
                      fontSize: AppSizes.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '상담료 설정 완료 후 활성화해주세요',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    if (isPhone) {
                      _isPhoneConsultEnabled = value;
                    } else {
                      _isVisitConsultEnabled = value;
                    }
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 저장 버튼
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('상담료가 저장되었습니다')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            elevation: 0,
          ),
          child: const Text(
            '상담료 저장하기',
            style: TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// 상담 진행 절차
  Widget _buildProcessSection() {
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
            '상담 진행 절차',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildProcessStep(
            number: '1',
            title: '상담료 설정',
            description: '전화/방문 상담료와 시간을 설정합니다',
            isActive: true,
          ),
          _buildProcessConnector(),
          _buildProcessStep(
            number: '2',
            title: '상담 예약',
            description: '의뢰인이 상담료를 선결제하고 예약합니다',
            isActive: false,
          ),
          _buildProcessConnector(),
          _buildProcessStep(
            number: '3',
            title: '상담 진행',
            description: '예약 시간에 의뢰인과 상담을 진행합니다',
            isActive: false,
          ),
          _buildProcessConnector(),
          _buildProcessStep(
            number: '4',
            title: '결과 작성',
            description: '상담 결과를 작성하면 완료됩니다',
            isActive: false,
          ),
          _buildProcessConnector(),
          _buildProcessStep(
            number: '5',
            title: '자동 정산',
            description: '5영업일 뒤 상담료가 자동 입금됩니다',
            isActive: false,
          ),
        ],
      ),
    );
  }

  /// 프로세스 단계
  Widget _buildProcessStep({
    required String number,
    required String title,
    required String description,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 프로세스 연결선
  Widget _buildProcessConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 17),
      width: 2,
      height: 24,
      color: Colors.grey[200],
    );
  }

  /// 자주 묻는 질문
  Widget _buildFAQSection() {
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
            '자주 묻는 질문',
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildFAQItem(
            index: 0,
            question: '상담료는 언제 받나요?',
            answer: '상담 완료 후 5영업일 이내에 등록된 계좌로 자동 입금됩니다. PAYAPP을 통해 정산되며, 정산 내역은 마이페이지에서 확인할 수 있습니다.',
          ),
          const Divider(height: 1),
          _buildFAQItem(
            index: 1,
            question: '상담료 수수료가 있나요?',
            answer: '네, 플랫폼 이용 수수료 10%가 차감됩니다. 예를 들어 3만원 상담 시 2만 7천원이 정산됩니다.',
          ),
          const Divider(height: 1),
          _buildFAQItem(
            index: 2,
            question: '상담 시간이 초과되면 어떻게 되나요?',
            answer: '기본 상담 시간이 초과되어도 추가 요금은 발생하지 않습니다. 다만, 효율적인 상담 운영을 위해 정해진 시간 내에 상담을 마무리하시는 것을 권장드립니다.',
          ),
        ],
      ),
    );
  }

  /// FAQ 아이템
  Widget _buildFAQItem({
    required int index,
    required String question,
    required String answer,
  }) {
    final isExpanded = _faqExpanded[index] ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _faqExpanded[index] = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                      color: isExpanded ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

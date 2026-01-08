import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// 로디코드 소개 페이지 (전문가용)
class ExpertIntroPage extends StatefulWidget {
  const ExpertIntroPage({super.key});

  @override
  State<ExpertIntroPage> createState() => _ExpertIntroPageState();
}

class _ExpertIntroPageState extends State<ExpertIntroPage> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('로디코드 소개'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배너 슬라이드
            _buildBannerSlider(),

            const SizedBox(height: AppSizes.paddingXL),

            // 로디코드 솔루션을 이용해야 하는 이유
            _buildWhySection(),

            const SizedBox(height: AppSizes.paddingXL),

            // 의뢰인 후기가 변호사 선택의 기준
            _buildReviewStatsSection(),

            const SizedBox(height: AppSizes.paddingXL),

            // 신청 절차
            _buildProcessSection(),

            const SizedBox(height: AppSizes.paddingL),

            // 현재 무료 이용 가능 배너
            _buildFreeBanner(),

            const SizedBox(height: AppSizes.paddingXL),

            // 하단 카드
            _buildBottomCard(),

            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  /// 배너 슬라이드
  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 430,
          child: PageView(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            children: [
              _buildBanner1(),
              _buildBanner2(),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        // 인디케이터
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? AppColors.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 첫 번째 배너 - 상담 예약 과정
  Widget _buildBanner1() {
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
          const Text(
            '쉽고 부담 없는\n상담 예약 과정.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '의뢰인은 변호사님의 상담 가능 시간을\n미리 알고, 간편히 예약할 수 있습니다.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: AppSizes.fontM,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 예약 카드 미리보기
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      '15분 전화상담',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontM,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '3. 29(토)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: AppSizes.fontS,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.orange),
                    const SizedBox(width: 6),
                    const Text(
                      '오후 02:00',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: AppSizes.fontS,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),
                // 시간 선택 버튼들
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTimeChip('10:00', false),
                    _buildTimeChip('10:30', false),
                    _buildTimeChip('11:00', false),
                    _buildTimeChip('11:30', false),
                    _buildTimeChip('13:00', false),
                    _buildTimeChip('13:30', false),
                    _buildTimeChip('14:00', true),
                    _buildTimeChip('14:30', false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 시간 선택 칩
  Widget _buildTimeChip(String time, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontSize: AppSizes.fontS,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  /// 두 번째 배너 - 카카오톡 오픈채팅
  Widget _buildBanner2() {
    return GestureDetector(
      onTap: () => _launchKakaoOpenChat(),
      child: Container(
        margin: const EdgeInsets.all(AppSizes.paddingM),
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEE500), Color(0xFFFFD900)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 카카오톡 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF3C1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble,
                  color: Color(0xFFFEE500),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            const Text(
              '무엇부터 해야 할지\n모르겠다면,',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3C1E1E),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            const Text(
              '궁금하신 내용은 언제든 문의주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3C1E1E),
                fontSize: AppSizes.fontM,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3C1E1E),
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '카카오톡 오픈채팅 바로가기',
                    style: TextStyle(
                      color: Color(0xFFFEE500),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Color(0xFFFEE500), size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 카카오톡 오픈채팅 열기
  Future<void> _launchKakaoOpenChat() async {
    final Uri url = Uri.parse('https://open.kakao.com/o/pqlUIsai');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열 수 없습니다')),
        );
      }
    }
  }

  /// 로디코드 솔루션을 이용해야 하는 이유
  Widget _buildWhySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '로디코드 솔루션을\n이용해야 하는 이유',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildReasonCard(
            number: '01',
            title: '쉽고, 단순합니다',
            description: '의뢰인들이 느끼는 문턱을 낮췄습니다',
            icon: Icons.auto_awesome,
            iconColor: AppColors.primary,
            backgroundColor: Colors.blue[50]!,
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildReasonCard(
            number: '02',
            title: '더욱 매력적으로 보입니다',
            description: '후기가 신뢰도를 높여줍니다',
            icon: Icons.star_outline,
            iconColor: Colors.orange,
            backgroundColor: Colors.orange[50]!,
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildReasonCard(
            number: '03',
            title: '상담에만 집중하세요',
            description: '예약-상담-정산까지 자동화',
            icon: Icons.flash_on,
            iconColor: AppColors.primary,
            backgroundColor: Colors.blue[50]!,
          ),
        ],
      ),
    );
  }

  /// 이유 카드
  Widget _buildReasonCard({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: AppSizes.fontS,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: AppSizes.fontS,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 의뢰인 후기가 변호사 선택의 기준
  Widget _buildReviewStatsSection() {
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '의뢰인 후기가\n변호사 선택의 기준',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildStatBar('후기', 58, AppColors.primary),
          const SizedBox(height: AppSizes.paddingM),
          _buildStatBar('소개 문구', 39, Colors.blueAccent),
          const SizedBox(height: AppSizes.paddingM),
          _buildStatBar('주요 분야', 8, Colors.green),
          const SizedBox(height: AppSizes.paddingM),
          // Text(
          //   '2018 로디코드 의뢰인 survey 조사',
          //   style: TextStyle(
          //     color: Colors.grey[500],
          //     fontSize: AppSizes.fontXS,
          //   ),
          // ),
        ],
      ),
    );
  }

  /// 통계 바
  Widget _buildStatBar(String label, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// 신청 절차
  Widget _buildProcessSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '신청 절차',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildProcessStep(
            number: '1',
            title: '신청하기',
            description: '이용하고 싶은 솔루션 신청',
            isActive: true,
          ),
          _buildProcessConnector(),
          _buildProcessStep(
            number: '2',
            title: '서류 보내기',
            description: '필요서류 등록',
            isActive: false,
          ),
          _buildProcessConnector(),
          _buildProcessStep(
            number: '3',
            title: '승인 대기',
            description: '5-7일 이내 승인',
            isActive: false,
          ),
          _buildProcessConnector(),
          _buildProcessStep(
            number: '4',
            title: '이용하기',
            description: '많은 의뢰인을 만나세요!',
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
        Column(
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

  /// 무료 이용 배너
  Widget _buildFreeBanner() {
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
            child: const Text('🎉', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 무료 이용 가능!',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: AppSizes.fontL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '회원가입 완료 후 바로 이용하세요',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: AppSizes.fontS,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 카드
  Widget _buildBottomCard() {
    return Container(
      width: double.infinity,
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.balance,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          const Text(
            '누구에게나 쉽고 편한\n로디코드솔루션',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '변호사와 의뢰인에게\n편리한 법률 서비스를 경험하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: AppSizes.fontM,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

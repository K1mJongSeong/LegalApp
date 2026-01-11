import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/datasources/expert_account_remote_datasource.dart';
import '../../../../data/datasources/expert_video_remote_datasource.dart';

/// 동영상 업로드 페이지 (전문가용)
class ExpertVideoPage extends StatefulWidget {
  const ExpertVideoPage({super.key});

  @override
  State<ExpertVideoPage> createState() => _ExpertVideoPageState();
}

class _ExpertVideoPageState extends State<ExpertVideoPage> {
  final TextEditingController _videoLinkController = TextEditingController();

  String? _selectedCategory;
  bool _isImporting = false;

  // 카테고리 목록
  final List<String> _categories = [
    '법률가이드',
    '사건해결사례',
    '변호사 경험담',
    '법률상식',
    '분쟁해결방법',
    '기타',
  ];

  @override
  void dispose() {
    _videoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('동영상 업로드'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 정보 배너
            _buildInfoBanner(),

            const SizedBox(height: AppSizes.paddingL),

            // 동영상 업로드 방법
            _buildUploadSteps(),

            const SizedBox(height: AppSizes.paddingL),

            // 동영상 업로드 팁
            _buildTipsSection(),

            const SizedBox(height: AppSizes.paddingL),

            // 발행되지 않을 수 있는 동영상 경고
            _buildWarningSection(),

            const SizedBox(height: AppSizes.paddingL),

            // CTA 배너
            _buildCTABanner(),

            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  /// 상단 정보 배너
  Widget _buildInfoBanner() {
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
          // 콘텐츠 강화 태그
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  '콘텐츠 강화',
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
            '동영상으로\n전문성 강조하기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '출연하거나 제작한 동영상 콘텐츠를 업로드해 변호사님의 전문성을 강조해보세요.',
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

  /// 동영상 업로드 방법 섹션
  Widget _buildUploadSteps() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.play_circle,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                '동영상 업로드 방법',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Step 1: 동영상 링크 입력
          _buildStep(
            stepNumber: 1,
            title: '동영상 링크 입력',
            description: 'YouTube, Vimeo 등의 동영상 링크를 붙여넣으세요',
            child: TextField(
              controller: _videoLinkController,
              decoration: InputDecoration(
                hintText: 'https://youtube.com/watch?v=...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingM,
                ),
              ),
            ),
          ),

          const Divider(color: AppColors.divider, height: AppSizes.paddingXL),

          // Step 2: 가져오기
          _buildStep(
            stepNumber: 2,
            title: '가져오기',
            description: '입력한 링크를 확인하고 "가져오기" 버튼을 클릭하세요',
            child: SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _isImporting ? null : _importVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  elevation: 0,
                ),
                child: _isImporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '가져오기',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),

          const Divider(color: AppColors.divider, height: AppSizes.paddingXL),

          // Step 3: 카테고리 선택
          _buildStep(
            stepNumber: 3,
            title: '카테고리 선택',
            description: '동영상에 맞는 카테고리를 선택하세요',
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.paddingS,
                mainAxisSpacing: AppSizes.paddingS,
                childAspectRatio: 2.5,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return _buildCategoryButton(category, isSelected);
              },
            ),
          ),

          const Divider(color: AppColors.divider, height: AppSizes.paddingXL),

          // 동영상 업로드 버튼
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: _uploadVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                elevation: 0,
              ),
              child: const Text(
                '동영상 업로드',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 단계 아이템
  Widget _buildStep({
    required int stepNumber,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontL,
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
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: AppSizes.fontS,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              child,
            ],
          ),
        ),
      ],
    );
  }

  /// 카테고리 버튼
  Widget _buildCategoryButton(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : category;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// 동영상 가져오기
  Future<void> _importVideo() async {
    if (_videoLinkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('동영상 링크를 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      // TODO: 동영상 링크 유효성 검사 및 메타데이터 추출 (YouTube API 등)
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('동영상 링크를 가져왔습니다')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('동영상 가져오기 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  /// 동영상 업로드
  Future<void> _uploadVideo() async {
    // 유효성 검사
    if (_videoLinkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('동영상 링크를 입력해주세요')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요')),
      );
      return;
    }

    try {
      // 로딩 표시
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 현재 사용자 ID 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      // 전문가 계정 ID 가져오기
      final expertAccountDataSource = ExpertAccountRemoteDataSource();
      final expertAccount = await expertAccountDataSource
          .getExpertAccountByUserId(user.uid);

      if (expertAccount == null) {
        if (!mounted) return;
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('전문가 계정을 찾을 수 없습니다')),
        );
        return;
      }

      // 동영상 저장
      final videoDataSource = ExpertVideoRemoteDataSource();
      await videoDataSource.createVideo(
        expertAccountId: expertAccount.id,
        videoUrl: _videoLinkController.text.trim(),
        category: _selectedCategory!,
        isPublished: true, // 기본값으로 발행
      );

      if (!mounted) return;
      Navigator.pop(context); // 로딩 닫기

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('동영상이 업로드되었습니다')),
      );

      // 페이지 닫기
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // 로딩 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: $e')),
      );
    }
  }

  /// 동영상 업로드 팁 섹션
  Widget _buildTipsSection() {
    final tips = [
      {
        'title': '명확한 주제',
        'desc': '동영상의 주제가 카테고리와 일치하도록 명확하게 선택하세요',
      },
      {
        'title': '적절한 길이',
        'desc': '5분~30분 정도의 적당한 길이의 동영상을 권장합니다',
      },
      {
        'title': '높은 해상도',
        'desc': '1080p 이상의 높은 해상도 동영상을 업로드하세요',
      },
      {
        'title': '자막 포함',
        'desc': '청각 장애인을 위해 자막을 포함한 동영상을 권장합니다',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                '동영상 업로드 팁',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...tips.map((tip) => _buildTipItem(
                title: tip['title']!,
                description: tip['desc']!,
              )),
        ],
      ),
    );
  }

  /// 팁 아이템
  Widget _buildTipItem({
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '✓',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.fontXS,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 발행되지 않을 수 있는 동영상 경고 섹션
  Widget _buildWarningSection() {
    final warnings = [
      '사건 설명이나 내용 없이 이미지만 삽입한 경우',
      '변호사의 견해나 법률적 내용 없이 외부링크만 붙여넣기한 경우',
      '동영상이 play 되지 않거나 링크가 깨진 경우',
      '법률적 내용 없이 단순 홍보 목적으로 소개한 경우',
      '제목에 기호나 이모티콘이 포함된 경우',
      '법률사무소 직접 홍보 이미지나 전화번호가 포함된 경우',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4ED), // bg-[#FFF4ED]
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: const Color(0xFFFFE5B4)), // border-[#FFE5B4]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                '발행되지 않을 수 있는 동영상',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingS),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.textPrimary,
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

  /// CTA 배너
  Widget _buildCTABanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
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
        children: [
          Text(
            '동영상 콘텐츠로 더 많은 의뢰인 확보',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            '변호사님의 전문성을\n영상으로 표현하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

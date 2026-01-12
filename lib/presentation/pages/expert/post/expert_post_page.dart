import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/datasources/expert_account_remote_datasource.dart';
import '../../../../data/datasources/expert_post_remote_datasource.dart';
import '../../../../data/models/expert_post_model.dart';

/// 포스트 작성 페이지 (전문가용)
class ExpertPostPage extends StatefulWidget {
  const ExpertPostPage({super.key});

  @override
  State<ExpertPostPage> createState() => _ExpertPostPageState();
}

class _ExpertPostPageState extends State<ExpertPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedPostType = 'guide'; // 'guide', 'case', 'essay'
  String? _selectedCategory; // 카테고리는 하나만 선택 가능
  final List<String> _selectedTags = [];
  bool _publishImmediately = false;
  File? _selectedImageFile; // 선택된 이미지 파일

  final int _maxTitleLength = 50;
  final int _maxContentLength = 2500;

  // 카테고리 목록 (법률가이드용)
  final List<String> _categories = [
    '손해배상',
    '상속·증여',
    '부동산',
    '가족',
    '노동',
    '형사',
  ];

  // 태그 목록 (법률가이드용)
  final List<String> _tags = [
    '건설·부동산',
    '교통사고',
    '계약',
    '금융',
    '노동',
    '상속',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('포스트 작성'),
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

            // 포스트 유형 선택
            _buildPostTypeSection(),

            const SizedBox(height: AppSizes.paddingL),

            // 포스트 작성 폼
            _buildPostForm(),

            const SizedBox(height: AppSizes.paddingL),

            // 포스트 작성 팁
            _buildTipsSection(),

            const SizedBox(height: AppSizes.paddingL),

            // 발행되지 않을 수 있는 포스트 경고
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
          // 전문성 강화 태그
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  '전문성 강화',
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
            '전문성으로\n의뢰인 신뢰 획득',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '변호사님의 독특한 경험과 인사이트를 의뢰인들에게 보여주세요. 좋은 글이 가장 좋은 마케팅입니다.',
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

  /// 포스트 유형 선택 섹션
  Widget _buildPostTypeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '포스트 유형 선택',
            style: TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 법률가이드 카드
          _buildPostTypeCard(
            type: 'guide',
            title: '법률가이드',
            description: '다양한 법률분야에 관련한 정보글',
          ),
          // 해결사례 카드
          _buildPostTypeCard(
            type: 'case',
            title: '해결사례',
            description: '의뢰인의 문제를 해결한 실제 사례글',
          ),
          // 변호사 에세이 카드
          _buildPostTypeCard(
            type: 'essay',
            title: '변호사 에세이',
            description: '법률적 이야기 외 다양한 이야기',
          ),
        ],
      ),
    );
  }

  /// 포스트 유형 카드
  Widget _buildPostTypeCard({
    required String type,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedPostType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPostType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 아이콘 (포스트 유형별로 다른 아이콘)
            _buildPostTypeIcon(type: type),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppSizes.fontL,
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
                ],
              ),
            ),
            // 선택 표시
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// 포스트 유형별 아이콘
  Widget _buildPostTypeIcon({required String type}) {
    switch (type) {
      case 'guide':
        // 법률가이드 아이콘 (세 개의 책을 겹쳐서 표시)
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            children: [
              // 첫 번째 책 (주황색)
              Positioned(
                left: 0,
                top: 8,
                child: Container(
                  width: 24,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // 두 번째 책 (초록색)
              Positioned(
                left: 8,
                top: 4,
                child: Container(
                  width: 24,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // 세 번째 책 (파란색)
              Positioned(
                left: 16,
                top: 0,
                child: Container(
                  width: 24,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'case':
        // 해결사례 아이콘 (초록색 체크마크)
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 32,
          ),
        );
      case 'essay':
        // 변호사 에세이 아이콘 (문서와 펜)
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.description,
                color: AppColors.warning,
                size: 28,
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox(width: 48, height: 48);
    }
  }

  /// 포스트 작성 폼
  Widget _buildPostForm() {
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
          // 제목 입력
          _buildTitleField(),

          const SizedBox(height: AppSizes.paddingL),

          // 카테고리 선택 (법률가이드, 해결사례만)
          if (_selectedPostType == 'guide' || _selectedPostType == 'case')
            _buildCategorySection(),

          if (_selectedPostType == 'guide' || _selectedPostType == 'case')
            const SizedBox(height: AppSizes.paddingL),

          // 태그 선택 (법률가이드, 해결사례만)
          if (_selectedPostType == 'guide' || _selectedPostType == 'case')
            _buildTagSection(),

          if (_selectedPostType == 'guide') const SizedBox(height: AppSizes.paddingL),

          // 본문 입력
          _buildContentField(),

          const SizedBox(height: AppSizes.paddingL),

          // 대표이미지
          _buildImageSection(),

          const SizedBox(height: AppSizes.paddingL),

          // 구분선
          const Divider(color: AppColors.divider),

          const SizedBox(height: AppSizes.paddingM),

          // 작성 완료 후 바로 발행 체크박스
          _buildPublishCheckbox(),

          const SizedBox(height: AppSizes.paddingL),

          // 포스트 저장하기 버튼
          _buildSaveButton(),
        ],
      ),
    );
  }

  /// 제목 입력 필드
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '제목',
          style: TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextField(
          controller: _titleController,
          maxLength: _maxTitleLength,
          decoration: InputDecoration(
            hintText: '포스트 제목을 입력하세요',
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
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        Text(
          '${_titleController.text.length}/$_maxTitleLength (제목에 기호나 이모티콘은 포함될 수 없습니다)',
          style: const TextStyle(
            fontSize: AppSizes.fontXS,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 카테고리 선택 섹션
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리 선택',
          style: TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSizes.paddingS,
            mainAxisSpacing: AppSizes.paddingS,
            childAspectRatio: 2.5,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;
            return _buildSelectableButton(
              text: category,
              isSelected: isSelected,
              color: AppColors.primary,
              onTap: () {
                setState(() {
                  // 카테고리는 하나만 선택 가능
                  _selectedCategory = isSelected ? null : category;
                });
              },
            );
          },
        ),
      ],
    );
  }

  /// 태그 선택 섹션
  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '태그 선택',
          style: TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSizes.paddingS,
            mainAxisSpacing: AppSizes.paddingS,
            childAspectRatio: 2.5,
          ),
          itemCount: _tags.length,
          itemBuilder: (context, index) {
            final tag = _tags[index];
            final isSelected = _selectedTags.contains(tag);
            return _buildSelectableButton(
              text: tag,
              isSelected: isSelected,
              color: AppColors.warning,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  /// 선택 가능한 버튼 (카테고리/태그용)
  Widget _buildSelectableButton({
    required String text,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
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

  /// 본문 입력 필드
  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '본문',
          style: TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextField(
          controller: _contentController,
          maxLines: 10,
          maxLength: _maxContentLength,
          decoration: InputDecoration(
            hintText: '포스트 내용을 입력하세요 (1,000~2,500자 권장)',
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
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        Text(
          '${_contentController.text.length}/$_maxContentLength (A4 1~2장 정도의 분량, 약 1,000자~2,500자 권장)',
          style: const TextStyle(
            fontSize: AppSizes.fontXS,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 대표이미지 선택 섹션
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '대표이미지',
          style: TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: _selectedImageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    child: Image.file(
                      _selectedImageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  )
                : Column(
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      const Text(
                        '이미지를 선택하세요',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '80여종의 대표이미지 중 선택 가능',
                        style: TextStyle(
                          fontSize: AppSizes.fontXS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_selectedImageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.paddingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('변경'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImageFile = null;
                    });
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('삭제'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 작성 완료 후 바로 발행 체크박스
  Widget _buildPublishCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _publishImmediately = !_publishImmediately;
        });
      },
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _publishImmediately,
              onChanged: (value) {
                setState(() {
                  _publishImmediately = value ?? false;
                });
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.paddingS),
          const Text(
            '작성 완료 후 바로 발행',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 포스트 저장하기 버튼
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _savePost,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          elevation: 0,
        ),
        child: const Text(
          '포스트 저장하기',
          style: TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 포스트 저장
  Future<void> _savePost() async {
    // 유효성 검사
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('본문을 입력해주세요')),
      );
      return;
    }

    // 카테고리 검사 (법률가이드, 해결사례인 경우)
    if ((_selectedPostType == 'guide' || _selectedPostType == 'case') &&
        _selectedCategory == null) {
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

      // 포스트 저장
      final postDataSource = ExpertPostRemoteDataSource();
      await postDataSource.createPost(
        expertAccountId: expertAccount.id,
        postType: _selectedPostType,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        tags: _selectedTags,
        content: _contentController.text.trim(),
        imageFile: _selectedImageFile,
        isPublished: _publishImmediately,
      );

      if (!mounted) return;
      Navigator.pop(context); // 로딩 닫기

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _publishImmediately
                ? '포스트가 발행되었습니다'
                : '포스트가 저장되었습니다',
          ),
        ),
      );

      // 페이지 닫기
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // 로딩 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  /// 포스트 작성 팁 섹션
  Widget _buildTipsSection() {
    final tips = [
      {
        'title': '체계적인 글 구성',
        'desc': '대제목, 소제목 등을 잘 활용하여 글의 구성을 짜임새있게 하세요. 검색엔진최적화에 유리합니다.',
      },
      {
        'title': '적절한 분량',
        'desc': 'A4 1~2장(약 1,000자~2,500자) 정도의 분량을 권장합니다.',
      },
      {
        'title': 'AI 제목 추천 활용',
        'desc': '본문 500자 이상 작성 시, AI가 추천하는 제목으로 전환할 수 있습니다.',
      },
      {
        'title': '자신만의 경험 공유',
        'desc': '많은 사건을 해결하며 체득하신 변호사님의 인사이트를 의뢰인들에게 보여주세요.',
      },
      {
        'title': '명확한 이미지 선택',
        'desc': '포스트의 의미를 명확하게 전달할 수 있는 이미지를 선택하세요.',
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
                '포스트 작성 팁 5가지',
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
              color: AppColors.warning,
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

  /// 발행되지 않을 수 있는 포스트 경고 섹션
  Widget _buildWarningSection() {
    final warnings = [
      '사건 설명 없이 이미지(캡쳐, 판결문 등)만 삽입한 경우',
      '변호사의 견해나 법률적 내용 없이 외부링크만 붙여넣기한 경우',
      '첨부한 이미지가 깨지거나 동영상이 play 되지 않는 경우',
      '법률적 내용 없이 단순 홍보목적으로 소개한 경우',
      '본문과 무관한 지나치게 자극적인 제목이나 이미지를 사용한 경우',
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
                '발행되지 않을 수 있는 포스트',
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
            '처음 포스트를 작성하시나요?',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            '변호사님의 전문성을\n의뢰인에게 알려보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '좋은 글이 가장 좋은 마케팅입니다',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 이미지 선택
  Future<void> _pickImage() async {
    try {
      // 이미지 선택 (갤러리 또는 카메라)
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('이미지 선택'),
          content: const Text('이미지를 선택하세요'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('카메라'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('갤러리'),
            ),
          ],
        ),
      );

      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // 파일 크기 확인 (8MB)
        const maxSize = 8 * 1024 * 1024;
        final fileSize = await file.length();
        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ 파일 크기는 8MB를 초과할 수 없습니다')),
            );
          }
          return;
        }

        setState(() {
          _selectedImageFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 오류: $e')),
        );
      }
    }
  }
}





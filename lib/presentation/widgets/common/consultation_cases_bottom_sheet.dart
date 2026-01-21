import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/consultation_post.dart';
import '../../../domain/repositories/consultation_post_repository.dart';
import '../../../data/repositories/consultation_post_repository_impl.dart';
import '../../../data/datasources/consultation_post_remote_datasource.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

/// 상담 사례 바텀 시트
class ConsultationCasesBottomSheet extends StatefulWidget {
  const ConsultationCasesBottomSheet({super.key});

  @override
  State<ConsultationCasesBottomSheet> createState() => _ConsultationCasesBottomSheetState();
}

class _ConsultationCasesBottomSheetState extends State<ConsultationCasesBottomSheet> {
  List<ConsultationPost> _posts = [];
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadConsultationPosts();
  }

  Future<void> _deleteConsultationPost(ConsultationPost post) async {
    if (_isDeleting) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('상담 글 삭제'),
        content: const Text('해당 상담 글을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final repository = ConsultationPostRepositoryImpl(
        ConsultationPostRemoteDataSource(),
      );
      await repository.deleteConsultationPost(post.id);

      if (mounted) {
        setState(() {
          _posts.removeWhere((p) => p.id == post.id);
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상담 글이 삭제되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadConsultationPosts() async {
    try {
      final repository = ConsultationPostRepositoryImpl(
        ConsultationPostRemoteDataSource(),
      );
      // 모든 유저의 상담 글 가져오기
      final posts = await repository.getAllConsultationPosts();
      
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '상담 사례',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // 내용
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingXL),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _posts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingXL),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppSizes.paddingM),
                              Text(
                                '작성한 상담 글이 없습니다',
                                style: TextStyle(
                                  fontSize: AppSizes.fontM,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        shrinkWrap: true,
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          return _buildConsultationCaseCard(_posts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCaseCard(ConsultationPost post) {
    // 현재 로그인한 사용자 확인
    final authState = context.read<AuthBloc>().state;
    final isMyPost = authState is AuthAuthenticated && authState.user.id == post.userId;

    // 카테고리 태그
    final categoryTag = _getCategoryTag(post.category);
    final subCategoryTag = _getSubCategoryTag(post.category);

    // 시간 계산
    final timeAgo = DateTime.now().difference(post.createdAt);
    String timeString;
    if (timeAgo.inDays == 0) {
      if (timeAgo.inHours == 0) {
        timeString = '${timeAgo.inMinutes}분 전 작성';
      } else {
        timeString = '${timeAgo.inHours}시간 전 작성';
      }
    } else {
      timeString = '${timeAgo.inDays}일 전 작성';
    }

    // 답변 내용 (임시로 상담 글 내용 사용, 실제로는 답변 필드가 필요)
    final answerPreview = post.content.length > 80
        ? '${post.content.substring(0, 80)}..'
        : post.content;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그
          Row(
            children: [
              if (categoryTag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    categoryTag,
                    style: const TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (categoryTag != null && subCategoryTag != null)
                const SizedBox(width: AppSizes.paddingS),
              if (subCategoryTag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subCategoryTag,
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 제목
          Text(
            post.title,
            style: const TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          // 담당 변호사 및 소속 (임시 데이터, 실제로는 답변 정보에서 가져와야 함)
          Text(
            '담당 변호사 정보 없음', // TODO: 답변 정보에서 가져오기
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 답변 내용 미리보기
          Text(
            answerPreview,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 하단 정보 + 삭제 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 조회수, 좋아요
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.views}',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Icon(
                    Icons.favorite_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.comments}', // 임시로 comments를 좋아요로 표시
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // 시간
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // 본인 글일 때만 삭제 버튼 표시
                  if (isMyPost) ...[
                    const SizedBox(width: AppSizes.paddingM),
                    TextButton.icon(
                      onPressed: _isDeleting ? null : () => _deleteConsultationPost(post),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        '삭제',
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _getCategoryTag(String? category) {
    if (category == null) return null;
    
    // 카테고리 매핑
    final categoryMap = {
      'labor': '노동',
      'real_estate': '부동산',
      'traffic': '교통사고',
      'criminal': '형사',
      'civil': '민사',
      'family': '가사',
      'company': '회사',
      'medical_tax': '의료·세금·행정',
      'it_ip': 'IT·지식재산·금융',
    };
    
    return categoryMap[category] ?? category;
  }

  String? _getSubCategoryTag(String? category) {
    if (category == null) return null;
    
    // 세부 카테고리 매핑 (예시)
    final subCategoryMap = {
      'civil': '계약분쟁',
      'family': '이혼',
      'labor': '임금체불',
      'real_estate': '임대차',
    };
    
    return subCategoryMap[category];
  }
}

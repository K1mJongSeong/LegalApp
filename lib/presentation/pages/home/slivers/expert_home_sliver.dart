import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/entities/expert_profile.dart';
import '../../../../domain/entities/consultation_post.dart';
import '../../../../data/repositories/expert_profile_repository_impl.dart';
import '../../../../data/repositories/expert_account_repository_impl.dart';
import '../../../../data/repositories/consultation_post_repository_impl.dart';
import '../../../../data/datasources/expert_account_remote_datasource.dart';
import '../../../../data/datasources/consultation_post_remote_datasource.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../widgets/home/expert/expert_profile_card.dart';
import '../../../widgets/home/expert/consultation_section_header.dart';
import '../../../widgets/home/expert/consultation_card.dart';
import '../../../widgets/home/expert/recommendation_card.dart';
import '../../../widgets/home/expert/notice_card.dart';
import '../../../widgets/home/expert/expert_verification_card.dart';
import '../../../widgets/home/expert/expert_quick_menu.dart';

/// 전문가 홈 Sliver 위젯
class ExpertHomeSliver extends StatefulWidget {
  final String name;
  final bool isVerified;

  const ExpertHomeSliver({
    super.key,
    required this.name,
    this.isVerified = false,
  });

  @override
  State<ExpertHomeSliver> createState() => _ExpertHomeSliverState();
}

class _ExpertHomeSliverState extends State<ExpertHomeSliver> {
  ExpertProfile? _profile;
  List<ConsultationPost> _posts = [];
  bool _isLoadingProfile = true;
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _isLoadingProfile = false;
        _isLoadingPosts = false;
      });
      return;
    }

    await Future.wait([
      _loadProfile(authState.user.id),
      _loadConsultationPosts(authState.user.id),
    ]);
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final profile = await ExpertProfileRepositoryImpl()
          .getProfileByUserId(userId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      debugPrint('❌ ExpertHomeSliver._loadProfile error: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _loadConsultationPosts(String userId) async {
    try {
      final expertAccountRepository = ExpertAccountRepositoryImpl(
        ExpertAccountRemoteDataSource(),
      );
      final expertAccount = await expertAccountRepository.getExpertAccountByUserId(userId);

      if (expertAccount == null) {
        if (mounted) {
          setState(() {
            _isLoadingPosts = false;
          });
        }
        return;
      }

      final consultationPostRepository = ConsultationPostRepositoryImpl(
        ConsultationPostRemoteDataSource(),
      );
      final posts = await consultationPostRepository.getConsultationPostsByExpertAccountId(
        expertAccount.id,
      );

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      debugPrint('❌ ExpertHomeSliver._loadConsultationPosts error: $e');
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  Widget _buildProfileCard() {
    return ExpertProfileCard(
      name: widget.name,
      isVerified: widget.isVerified,
      profile: _isLoadingProfile ? null : _profile,
    );
  }

  /// 섹션 헤더 위젯 (제목 + 더보기)
  Widget _buildSectionHeader(String title, {VoidCallback? onMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppSizes.fontXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: Text(
              '더보기 >',
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: Colors.grey[500],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        // 상단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingM),
        ),

        // 프로필 카드
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: SliverToBoxAdapter(
            child: _buildProfileCard(),
          ),
        ),

        // 프로필 카드 후 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingL),
        ),

        // 퀵 메뉴
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: const SliverToBoxAdapter(
            child: ExpertQuickMenu(),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingL),
        ),

        // 상담글 섹션 헤더
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: const SliverToBoxAdapter(
            child: ConsultationSectionHeader(),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingS),
        ),

        // 상담 글 섹션 - Peek Carousel
        if (_isLoadingPosts)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: SliverToBoxAdapter(
              child: _buildLoadingConsultation(),
            ),
          )
        else if (_posts.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: SliverToBoxAdapter(
              child: _buildEmptyConsultation(),
            ),
          )
        else
          SliverToBoxAdapter(
            child: _buildConsultationCarousel(),
          ),

        // 상담 글 후 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingL),
        ),

        // 전문가 인증 섹션 (미인증 시)
        if (!widget.isVerified) ...[
          // 섹션 헤더
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader('전문가 인증'),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.paddingM),
          ),
          // 인증 카드
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: const SliverToBoxAdapter(
              child: ExpertVerificationCard(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.paddingL),
          ),
        ],

        // 추천 카드
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: const SliverToBoxAdapter(
            child: RecommendationCard(),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingL),
        ),

        // 공지사항 섹션 헤더
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: SliverToBoxAdapter(
            child: _buildSectionHeader(
              '공지사항',
              onMore: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공지사항 목록은 준비 중입니다')),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingM),
        ),

        // 공지사항 카드
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: const SliverToBoxAdapter(
            child: NoticeCard(),
          ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingXL),
        ),
      ],
    );
  }

  Widget _buildLoadingConsultation() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyConsultation() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '예약된 상담이 없습니다.',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Peek Carousel 형태의 상담글 섹션
  Widget _buildConsultationCarousel() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (AppSizes.paddingM * 3.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];

              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(
                  right: index < _posts.length - 1 ? AppSizes.paddingS : 0,
                ),
                child: ConsultationCard(
                  category: post.category ?? '기타',
                  categoryColor: _getCategoryColor(post.category),
                  time: _formatTimeAgo(post.createdAt),
                  title: post.title,
                  views: post.views,
                  comments: post.comments,
                ),
              );
            },
          ),
        ),
        if (_posts.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.paddingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _posts.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '민사':
        return Colors.red;
      case '가족':
        return Colors.purple;
      case '형사':
        return Colors.blue;
      case '노동':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }
}

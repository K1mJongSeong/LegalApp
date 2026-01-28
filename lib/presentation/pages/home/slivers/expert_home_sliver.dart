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
///
/// SliverMainAxisGroup으로 각 섹션을 개별 Sliver로 구성
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
    // 로딩 중이든 아니든 항상 동일한 위젯 구조 유지 (높이 일관성)
    return ExpertProfileCard(
      name: widget.name,
      isVerified: widget.isVerified,
      profile: _isLoadingProfile ? null : _profile,
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

        // 상담글 섹션 헤더
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: const SliverToBoxAdapter(
            child: ConsultationSectionHeader(),
          ),
        ),

        // 섹션 헤더 후 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingS),
        ),

        // 상담 글 섹션
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = _posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
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
                childCount: _posts.length,
              ),
            ),
          ),

        // 상담 글 후 여백
        if (_posts.isNotEmpty)
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.paddingM),
          ),

        // 추천 카드
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: const SliverToBoxAdapter(
            child: RecommendationCard(),
          ),
        ),

        // 추천 카드 후 여백
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

        // 공지사항 카드 후 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingM),
        ),

        // 전문가 인증 카드 (미인증 시)
        if (!widget.isVerified)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: const SliverToBoxAdapter(
              child: ExpertVerificationCard(),
            ),
          ),

        if (!widget.isVerified)
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.paddingL),
          ),

        // 하단 퀵 메뉴
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          sliver: const SliverToBoxAdapter(
            child: ExpertQuickMenu(),
          ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSizes.paddingL),
        ),
      ],
    );
  }

  Widget _buildLoadingConsultation() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
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
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/entities/expert_profile.dart';
import '../../../../domain/entities/consultation_post.dart';
import '../../../../domain/repositories/expert_profile_repository.dart';
import '../../../../domain/repositories/expert_account_repository.dart';
import '../../../../domain/repositories/consultation_post_repository.dart';
import '../../../../data/repositories/expert_profile_repository_impl.dart';
import '../../../../data/repositories/expert_account_repository_impl.dart';
import '../../../../data/repositories/consultation_post_repository_impl.dart';
import '../../../../data/datasources/expert_account_remote_datasource.dart';
import '../../../../data/datasources/consultation_post_remote_datasource.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../widgets/home/expert/expert_home_header.dart';
import '../../../widgets/home/expert/expert_profile_card.dart';
import '../../../widgets/home/expert/profile_tip_card.dart';
import '../../../widgets/home/expert/consultation_section_header.dart';
import '../../../widgets/home/expert/consultation_card.dart';
import '../../../widgets/home/expert/recommendation_card.dart';
import '../../../widgets/home/expert/notice_card.dart';
import '../../../widgets/home/expert/expert_verification_card.dart';
import '../../../widgets/home/expert/expert_quick_menu.dart';

/// 전문가 홈 Sliver 위젯
/// 
/// SliverList + SliverChildListDelegate로 구성
/// Column, Expanded, Spacer 사용하지 않음
class ExpertHomeSliver extends StatelessWidget {
  final String name;
  final bool isVerified;

  const ExpertHomeSliver({
    super.key,
    required this.name,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // 헤더
          // const ExpertHomeHeader(),
          const SizedBox(height: AppSizes.paddingM),

          // 프로필 카드
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return ExpertProfileCard(
                  name: name,
                  isVerified: isVerified,
                );
              }

              return FutureBuilder<ExpertProfile?>(
                future: ExpertProfileRepositoryImpl()
                    .getProfileByUserId(authState.user.id),
                builder: (context, snapshot) {
                  return ExpertProfileCard(
                    name: name,
                    isVerified: isVerified,
                    profile: snapshot.data,
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSizes.paddingM),

          // 프로필 완성 팁 카드
          const ProfileTipCard(),
          const SizedBox(height: AppSizes.paddingL),

          // 관심있는 상담글 섹션 헤더
          const ConsultationSectionHeader(),
          const SizedBox(height: AppSizes.paddingS),

          // 예약된 상담 글 목록
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return _buildEmptyConsultation();
              }

              return FutureBuilder<List<ConsultationPost>>(
                future: _loadConsultationPosts(authState.user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.paddingL),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildEmptyConsultation();
                  }

                  final posts = snapshot.data ?? [];
                  if (posts.isEmpty) {
                    return _buildEmptyConsultation();
                  }

                  return Column(
                    children: [
                      ...posts.map((post) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                            child: ConsultationCard(
                              category: post.category ?? '기타',
                              categoryColor: _getCategoryColor(post.category),
                              time: _formatTimeAgo(post.createdAt),
                              title: post.title,
                              views: post.views,
                              comments: post.comments,
                            ),
                          )),
                      const SizedBox(height: AppSizes.paddingM),
                    ],
                  );
                },
              );
            },
          ),

          // 추천 카드
          const RecommendationCard(),
          const SizedBox(height: AppSizes.paddingM),

          // 공지사항 카드
          const NoticeCard(),
          const SizedBox(height: AppSizes.paddingM),

          // 전문가 인증 카드 (미인증 시)
          if (!isVerified) const ExpertVerificationCard(),
          if (!isVerified) const SizedBox(height: AppSizes.paddingL),

          // 하단 퀵 메뉴
          const ExpertQuickMenu(),
          const SizedBox(height: AppSizes.paddingL),
        ]),
      ),
    );
  }

  /// 전문가 계정 ID로 예약된 상담 글 목록 로드
  Future<List<ConsultationPost>> _loadConsultationPosts(String userId) async {
    try {
      // userId로 expertAccountId 조회
      final expertAccountRepository = ExpertAccountRepositoryImpl(
        ExpertAccountRemoteDataSource(),
      );
      final expertAccount = await expertAccountRepository.getExpertAccountByUserId(userId);

      if (expertAccount == null) {
        return [];
      }

      // 예약된 상담 글 목록 조회
      final consultationPostRepository = ConsultationPostRepositoryImpl(
        ConsultationPostRemoteDataSource(),
      );
      return await consultationPostRepository.getConsultationPostsByExpertAccountId(
        expertAccount.id,
      );
    } catch (e) {
      debugPrint('❌ ExpertHomeSliver._loadConsultationPosts error: $e');
      return [];
    }
  }

  /// 빈 상담 글 위젯
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

  /// 카테고리 색상 반환
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

  /// 시간 포맷 (예: "5분 전")
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
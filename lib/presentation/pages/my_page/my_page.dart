import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/review/review_bloc.dart';
import '../../blocs/review/review_event.dart';
import '../../blocs/review/review_state.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';

/// 마이페이지 화면
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ReviewBloc>().add(ReviewUserListRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else if (state is AuthAccountDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원탈퇴가 완료되었습니다'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('마이페이지'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('설정 기능은 준비 중입니다')),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const LoadingWidget();
                  }

                  if (state is! AuthAuthenticated) {
                    return EmptyStateWidget(
                      icon: Icons.person_off_outlined,
                      title: '로그인이 필요합니다',
                      subtitle: '로그인하고 더 많은 서비스를 이용해보세요',
                      buttonText: '로그인',
                      onButtonPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                    );
                  }

                  final user = state.user;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: Column(
                      children: [
                        // 프로필 카드
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingL),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
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
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                backgroundImage: user.profileImage != null
                                    ? NetworkImage(user.profileImage!)
                                    : null,
                                child: user.profileImage == null
                                    ? Text(
                                        user.name.isNotEmpty ? user.name[0] : '?',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppSizes.paddingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: AppSizes.fontXL,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: AppSizes.fontM,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('프로필 수정 기능은 준비 중입니다')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingL),
                        // 메뉴 섹션
                        _buildMenuSection(
                          title: '나의 활동',
                          items: [
                            _MenuItem(
                              icon: Icons.folder_outlined,
                              title: '내 사건',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.myCase);
                              },
                            ),
                            _MenuItem(
                              icon: Icons.history,
                              title: '상담 내역',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('상담 내역 기능은 준비 중입니다')),
                                );
                              },
                            ),
                            _MenuItem(
                              icon: Icons.star_outline,
                              title: '리뷰 관리',
                              onTap: () => _showReviewsSheet(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        _buildMenuSection(
                          title: '고객 지원',
                          items: [
                            _MenuItem(
                              icon: Icons.help_outline,
                              title: '자주 묻는 질문',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('FAQ는 준비 중입니다')),
                                );
                              },
                            ),
                            _MenuItem(
                              icon: Icons.headset_mic_outlined,
                              title: '고객센터',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('고객센터 연결은 준비 중입니다')),
                                );
                              },
                            ),
                            _MenuItem(
                              icon: Icons.description_outlined,
                              title: '이용약관',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.termsOfService);
                              },
                            ),
                            _MenuItem(
                              icon: Icons.privacy_tip_outlined,
                              title: '개인정보처리방침',
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.privacyPolicy);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        _buildMenuSection(
                          title: '계정',
                          items: [
                            _MenuItem(
                              icon: Icons.logout,
                              title: '로그아웃',
                              onTap: () => _handleLogout(context),
                            ),
                            _MenuItem(
                              icon: Icons.person_remove_outlined,
                              title: '회원탈퇴',
                              onTap: () => _handleDeleteAccount(context, user),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      ),
    );
  }

  void _showReviewsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return BlocBuilder<ReviewBloc, ReviewState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '내 리뷰',
                            style: TextStyle(
                              fontSize: AppSizes.fontXL,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: state is ReviewLoading
                          ? const LoadingWidget()
                          : state is ReviewEmpty
                              ? const EmptyStateWidget(
                                  icon: Icons.rate_review_outlined,
                                  title: '작성한 리뷰가 없습니다',
                                  subtitle: '상담 완료 후 리뷰를 작성해보세요',
                                )
                              : state is ReviewListLoaded
                                  ? ListView.separated(
                                      controller: scrollController,
                                      padding: const EdgeInsets.all(AppSizes.paddingM),
                                      itemCount: state.reviews.length,
                                      separatorBuilder: (_, __) => const Divider(),
                                      itemBuilder: (context, index) {
                                        final review = state.reviews[index];
                                        return ListTile(
                                          title: Row(
                                            children: List.generate(
                                              5,
                                              (i) => Icon(
                                                i < review.rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Text(review.content),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${review.createdAt.year}.${review.createdAt.month}.${review.createdAt.day}',
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: AppSizes.fontXS,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () async {
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (dialogContext) => AlertDialog(
                                                  title: const Text('리뷰 삭제'),
                                                  content: const Text('이 리뷰를 삭제하시겠습니까?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(dialogContext, false),
                                                      child: const Text('취소'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(dialogContext, true),
                                                      child: const Text('삭제'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirmed == true) {
                                                context.read<ReviewBloc>().add(
                                                  ReviewDeleteRequested(review.id),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    )
                                  : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, user) async {
    final loginProvider = user.loginProvider;
    final isEmailLogin = loginProvider == null || loginProvider == 'email';

    // 1단계: 경고 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말 탈퇴하시겠습니까?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSizes.paddingM),
            Text(
              '탈퇴 시 다음 데이터가 영구 삭제됩니다:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSizes.paddingS),
            Text('• 계정 정보'),
            Text('• 등록한 사건 내역'),
            Text('• 작성한 리뷰'),
            Text('• 상담 신청 내역'),
            SizedBox(height: AppSizes.paddingM),
            Text(
              '이 작업은 되돌릴 수 없습니다.',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // 2단계: 이메일 로그인인 경우 비밀번호 확인
    String? password;
    if (isEmailLogin) {
      password = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          final passwordController = TextEditingController();
          return AlertDialog(
            title: const Text('비밀번호 확인'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('본인 확인을 위해 비밀번호를 입력해주세요.'),
                const SizedBox(height: AppSizes.paddingM),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '비밀번호',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, null),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, passwordController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );

      if (password == null || password.isEmpty || !mounted) return;
    }

    // 3단계: 탈퇴 처리
    context.read<AuthBloc>().add(
      AuthDeleteAccountRequested(
        password: password,
        loginProvider: loginProvider,
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingS,
            bottom: AppSizes.paddingS,
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontS,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.primary),
                    title: Text(item.title),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'signup_page.dart';

/// 로그인 화면
class SignupPromptPage extends StatefulWidget {
  final String? category;
  final String? urgency;

  const SignupPromptPage({
    super.key,
    this.category,
    this.urgency,
  });

  @override
  State<SignupPromptPage> createState() => _SignupPromptPageState();
}

class _SignupPromptPageState extends State<SignupPromptPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpertTab = false;
  bool _showLoginForm = false;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _keepLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isExpertTab = _tabController.index == 1;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // 로그인 성공 시 팝업을 닫고 이전 페이지로 돌아감
          Navigator.pop(context);
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
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
              child: Container(
                margin: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: _showLoginForm
                    ? _buildLoginForm()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 헤더
                          _buildHeader(context),
                          // 탭
                          _buildTabs(),
                          const SizedBox(height: AppSizes.paddingXL),
                          // 프로모션
                          _buildPromotion(),
                          const SizedBox(height: AppSizes.paddingXL),
                          // 구분선
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingL,
                            ),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingM,
                                  ),
                                  child: Text(
                                    '또는',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: AppSizes.fontS,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          // 이메일 로그인 버튼
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingL,
                            ),
                            child: _buildEmailLoginButton(context),
                          ),
                          const SizedBox(height: AppSizes.paddingL),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingM,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Expanded(
            child: Text(
              '로그인',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontL,
                fontWeight: FontWeight.bold,
              ),
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
    );
  }

  Widget _buildTabs() {
    final isLoginSelected = _tabController.index == 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 로그인 탭 (왼쪽)
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: isLoginSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: isLoginSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '로그인',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: isLoginSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          // 전문가로 로그인 탭 (오른쪽)
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: !isLoginSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: !isLoginSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '전문가로 로그인',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: !isLoginSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotion() {
    return Column(
      children: [
        // 100 이모지 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Center(
            child: Text(
              '💯',
              style: TextStyle(
                fontSize: 50,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        const Text(
          '지금 가입시, 첫 전화상담 100% 지원!',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailLoginButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _showLoginForm = true;
        });
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        '이메일 계정으로 로그인',
        style: TextStyle(
          fontSize: AppSizes.fontM,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              _buildHeader(context),
              const SizedBox(height: AppSizes.paddingXL),
              // 아이디 입력
              const Text(
                '아이디',
                style: TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '아이디를 입력해주세요',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingM,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력해주세요';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return '올바른 이메일 형식이 아닙니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
              // 비밀번호 입력
              const Text(
                '비밀번호',
                style: TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력해주세요',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingM,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              // 로그인 상태 유지 / 아이디/비밀번호 찾기
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _keepLoggedIn,
                        onChanged: (value) {
                          setState(() {
                            _keepLoggedIn = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Text(
                        '로그인 상태 유지',
                        style: TextStyle(
                          fontSize: AppSizes.fontS,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text(
                      '아이디/비밀번호 찾기',
                      style: TextStyle(
                        fontSize: AppSizes.fontS,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXL),
              // 로그인 버튼
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: AppSizes.fontM,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
              // 회원가입 링크
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: '아직 로디코드 회원이 아니신가요? '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignupPage(isExpert: _isExpertTab),
                              ),
                            );
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: AppSizes.fontS,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final emailController = TextEditingController(text: _emailController.text);
        return AlertDialog(
          title: const Text('비밀번호 재설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('가입한 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.'),
              const SizedBox(height: AppSizes.paddingM),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: '이메일',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  AuthPasswordResetRequested(email: emailController.text.trim()),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호 재설정 이메일을 발송했습니다')),
                );
              },
              child: const Text('보내기'),
            ),
          ],
        );
      },
    );
  }
}

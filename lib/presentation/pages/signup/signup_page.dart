import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/primary_button.dart';

/// 회원가입 화면
class SignupPage extends StatefulWidget {
  final bool isExpert;

  const SignupPage({super.key, this.isExpert = false});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
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
          title: Text(widget.isExpert ? AppStrings.expertSignup : AppStrings.userSignup),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이메일
                      const Text('이메일 *', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.paddingS),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: '이메일을 입력해주세요',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해주세요';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return '올바른 이메일 형식이 아닙니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingL),
                      // 비밀번호
                      const Text('비밀번호 *', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.paddingS),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력해주세요',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          if (value.length < 8) {
                            return '비밀번호는 8자 이상이어야 합니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 다시 입력해주세요',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingL),
                      // 이름
                      const Text('이름 *', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.paddingS),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '이름을 입력해주세요',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingL),
                      // 전화번호
                      const Text('전화번호', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.paddingS),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '010-0000-0000',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingL),
                      // 약관 동의
                      CheckboxListTile(
                        value: _agreeTerms,
                        onChanged: (value) => setState(() => _agreeTerms = value ?? false),
                        title: const Text(
                          '이용약관 및 개인정보처리방침에 동의합니다 (필수)',
                          style: TextStyle(fontSize: AppSizes.fontS),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(height: AppSizes.paddingXL),
                      // 회원가입 버튼
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            text: '회원가입',
                            isLoading: state is AuthLoading,
                            onPressed: _agreeTerms ? _handleSignup : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignup() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        isExpert: widget.isExpert,
      ),
    );
  }
}

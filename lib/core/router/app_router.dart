import 'package:flutter/material.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/login/login_page.dart';
import '../../presentation/pages/signup/signup_prompt_page.dart';
import '../../presentation/pages/signup/signup_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/my_page/my_page.dart';
import '../../presentation/pages/case_input/case_input_page.dart';
import '../../presentation/pages/experts/experts_page.dart';
import '../../presentation/pages/confirm/confirm_page.dart';
import '../../presentation/pages/my_case/my_case_page.dart';
import '../../presentation/pages/summary/summary_page.dart';

/// 앱 라우트 이름 상수
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupPrompt = '/signup-prompt';
  static const String home = '/home';
  static const String myPage = '/my-page';
  static const String caseInput = '/case-input';
  static const String experts = '/experts';
  static const String confirm = '/confirm';
  static const String myCase = '/my-case';
  static const String summary = '/summary';
}

/// 앱 라우터 설정
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // 쿼리 파라미터 파싱
    final uri = Uri.parse(settings.name ?? '');
    final queryParams = uri.queryParameters;

    switch (uri.path) {
      case AppRoutes.splash:
        return _buildRoute(const SplashPage(), settings);

      case AppRoutes.login:
        return _buildRoute(const LoginPage(), settings);

      case AppRoutes.signup:
        final isExpert = queryParams['expert'] == 'true';
        return _buildRoute(SignupPage(isExpert: isExpert), settings);

      case AppRoutes.signupPrompt:
        return _buildRoute(
          SignupPromptPage(
            category: queryParams['category'],
            urgency: queryParams['urgency'],
          ),
          settings,
        );

      case AppRoutes.home:
        return _buildRoute(const HomePage(), settings);

      case AppRoutes.myPage:
        return _buildRoute(const MyPage(), settings);

      case AppRoutes.caseInput:
        return _buildRoute(
          CaseInputPage(category: queryParams['category']),
          settings,
        );

      case AppRoutes.experts:
        return _buildRoute(
          ExpertsPage(
            urgency: queryParams['urgency'],
            category: queryParams['category'],
          ),
          settings,
        );

      case AppRoutes.confirm:
        final expertId = int.tryParse(queryParams['expertId'] ?? '');
        return _buildRoute(
          ConfirmPage(expertId: expertId),
          settings,
        );

      case AppRoutes.myCase:
        return _buildRoute(const MyCasePage(), settings);

      case AppRoutes.summary:
        return _buildRoute(
          SummaryPage(caseId: queryParams['id']),
          settings,
        );

      default:
        return _buildRoute(const SplashPage(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

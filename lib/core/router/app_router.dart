import 'package:flutter/material.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/entry/entry_page.dart';
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
import '../../presentation/pages/case_flow/category_select_page.dart';
import '../../presentation/pages/case_flow/case_progress_page.dart';
import '../../presentation/pages/case_flow/case_detail_input_page.dart';
import '../../presentation/pages/case_flow/consultation_goal_page.dart';
import '../../presentation/pages/case_flow/consultation_condition_page.dart';
import '../../presentation/pages/case_flow/urgency_select_page.dart';
import '../../presentation/pages/case_flow/case_summary_result_page.dart';
import '../../presentation/pages/case_flow/case_submission_page.dart';
import '../../presentation/pages/case_flow/case_submission_complete_page.dart';
import '../../presentation/pages/expert/expert_dashboard_page.dart';
import '../../presentation/pages/expert/expert_certification_page.dart';
import '../../presentation/pages/expert/profile/expert_profile_manage_page.dart';
import '../../presentation/pages/expert/intro/expert_intro_page.dart';
import '../../presentation/pages/expert/consult/expert_consult_page.dart';
import '../../presentation/pages/expert/ad/expert_ad_page.dart';
import '../../presentation/pages/expert/post/expert_post_page.dart';
import '../../presentation/pages/expert/video/expert_video_page.dart';
import '../../presentation/pages/expert/notice/expert_notice_page.dart';

/// 앱 라우트 이름 상수
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String entry = '/entry';
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
  // 새 사건 등록 플로우
  static const String categorySelect = '/category-select';
  static const String caseProgress = '/case-progress';
  static const String caseDetailInput = '/case-detail-input';
  static const String consultationGoal = '/consultation-goal';
  static const String consultationCondition = '/consultation-condition';
  static const String urgencySelect = '/urgency-select';
  static const String caseSummaryResult = '/case-summary-result';
  static const String caseSubmission = '/case-submission';
  static const String caseSubmissionComplete = '/case-submission-complete';
  // 전문가 관련
  static const String expertDashboard = '/expert-dashboard';
  static const String expertCertification = '/expert-certification';
  static const String expertProfileManage = '/expert-profile-manage';
  // 전문가 메뉴 페이지
  static const String expertIntro = '/expert-intro';
  static const String expertConsult = '/expert-consult';
  static const String expertAd = '/expert-ad';
  static const String expertPost = '/expert-post';
  static const String expertVideo = '/expert-video';
  static const String expertNotice = '/expert-notice';
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

      case AppRoutes.entry:
        return _buildRoute(const EntryPage(), settings);

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
        final userId = queryParams['userId'];
        return _buildRoute(
          ConfirmPage(expertId: expertId, userId: userId),
          settings,
        );

      case AppRoutes.myCase:
        return _buildRoute(const MyCasePage(), settings);

      case AppRoutes.summary:
        return _buildRoute(
          SummaryPage(caseId: queryParams['id']),
          settings,
        );

      case AppRoutes.categorySelect:
        return _buildRoute(const CategorySelectPage(), settings);

      case AppRoutes.caseProgress:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          CaseProgressPage(
            category: args?['category'] ?? '',
            categoryName: args?['categoryName'] ?? '',
          ),
          settings,
        );

      case AppRoutes.caseDetailInput:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          CaseDetailInputPage(
            category: args?['category'] ?? '',
            categoryName: args?['categoryName'] ?? '',
            progressItems: (args?['progressItems'] as List<String>?) ?? [],
          ),
          settings,
        );

      case AppRoutes.consultationGoal:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ConsultationGoalPage(
            category: args?['category'] ?? '',
            categoryName: args?['categoryName'] ?? '',
            progressItems: (args?['progressItems'] as List<String>?) ?? [],
            description: args?['description'] ?? '',
          ),
          settings,
        );

      case AppRoutes.consultationCondition:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ConsultationConditionPage(
            category: args?['category'] ?? '',
            categoryName: args?['categoryName'] ?? '',
            progressItems: (args?['progressItems'] as List<String>?) ?? [],
            description: args?['description'] ?? '',
            goal: args?['goal'] ?? '',
          ),
          settings,
        );

      case AppRoutes.urgencySelect:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          UrgencySelectPage(
            category: args?['category'] ?? '',
            categoryName: args?['categoryName'] ?? '',
            description: args?['description'] ?? '',
            progressItems: (args?['progressItems'] as List<String>?) ?? [],
            goal: args?['goal'] ?? '',
            consultationMethod: args?['consultationMethod'] as List<String>?,
            preferredRegion: args?['preferredRegion'] as String?,
            expertExperience: args?['expertExperience'] as String?,
            consultationFee: args?['consultationFee'] as String?,
            freeConsultation: args?['freeConsultation'] as bool? ?? false,
            availableTime: args?['availableTime'] as String?,
          ),
          settings,
        );

      case AppRoutes.caseSummaryResult:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          CaseSummaryResultPage(
            category: args?['category'] ?? '',
            categoryName: args?['categoryName'] ?? '',
            description: args?['description'] ?? '',
            urgency: args?['urgency'] ?? 'normal',
            progressItems: (args?['progressItems'] as List<String>?) ?? [],
            goal: args?['goal'] ?? '',
            consultationMethod: args?['consultationMethod'] as List<String>?,
            preferredRegion: args?['preferredRegion'] as String?,
            expertExperience: args?['expertExperience'] as String?,
            consultationFee: args?['consultationFee'] as String?,
            freeConsultation: args?['freeConsultation'] as bool? ?? false,
            availableTime: args?['availableTime'] as String?,
          ),
          settings,
        );

      case AppRoutes.caseSubmission:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          CaseSubmissionPage(
            consultationPostId: args?['consultationPostId'] ?? '',
            expertUserId: args?['expertUserId'] ?? '',
            expertId: args?['expertId'] as String?,
          ),
          settings,
        );

      case AppRoutes.caseSubmissionComplete:
        return _buildRoute(const CaseSubmissionCompletePage(), settings);

      case AppRoutes.expertDashboard:
        return _buildRoute(const ExpertDashboardPage(), settings);

      case AppRoutes.expertCertification:
        return _buildRoute(const ExpertCertificationPage(), settings);

      case AppRoutes.expertProfileManage:
        return _buildRoute(const ExpertProfileManagePage(), settings);

      // 전문가 메뉴 페이지
      case AppRoutes.expertIntro:
        return _buildRoute(const ExpertIntroPage(), settings);

      case AppRoutes.expertConsult:
        return _buildRoute(const ExpertConsultPage(), settings);

      case AppRoutes.expertAd:
        return _buildRoute(const ExpertAdPage(), settings);

      case AppRoutes.expertPost:
        return _buildRoute(const ExpertPostPage(), settings);

      case AppRoutes.expertVideo:
        return _buildRoute(const ExpertVideoPage(), settings);

      case AppRoutes.expertNotice:
        return _buildRoute(const ExpertNoticePage(), settings);

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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'firebase_options.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/case/case_bloc.dart';
import 'presentation/blocs/expert/expert_bloc.dart';
import 'presentation/blocs/review/review_bloc.dart';
import 'presentation/blocs/expert_dashboard/expert_dashboard_bloc.dart';
import 'presentation/blocs/expert_certification/expert_certification_bloc.dart';
// Data Sources
import 'data/datasources/expert_account_remote_datasource.dart';
import 'data/datasources/expert_certification_remote_datasource.dart';
import 'data/datasources/consultation_request_remote_datasource.dart';
// Repositories
import 'data/repositories/expert_account_repository_impl.dart';
import 'data/repositories/expert_certification_repository_impl.dart';
import 'data/repositories/consultation_request_repository_impl.dart';
import 'data/repositories/expert_repository_impl.dart';
// Use Cases
import 'domain/usecases/get_expert_account_usecase.dart';
import 'domain/usecases/create_expert_account_usecase.dart';
import 'domain/usecases/submit_document_certification_usecase.dart';
import 'domain/usecases/submit_instant_certification_usecase.dart';
import 'domain/usecases/get_consultation_requests_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드 (모바일 전용)
  // 웹에서는 .env를 사용하지 않고 서버/프록시(Supabase 등)를 통해 GPT를 호출
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: '.env');
      final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      debugPrint('✅ .env loaded successfully');
      debugPrint(
          '✅ API Key loaded: ${apiKey.isNotEmpty ? "Yes (${apiKey.substring(0, 15)}...)" : "NO - EMPTY!"}');
    } catch (e) {
      debugPrint('❌ .env load error: $e');
    }
  } else {
    debugPrint('ℹ️ Web 환경: .env는 로드하지 않고 서버/프록시를 통해 GPT를 호출합니다.');
  }
  
  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const LegalApp());
}

class LegalApp extends StatelessWidget {
  const LegalApp({super.key});

  @override
  Widget build(BuildContext context) {
    // DataSources
    final expertAccountDataSource = ExpertAccountRemoteDataSource();
    final expertCertificationDataSource = ExpertCertificationRemoteDataSource();
    final consultationRequestDataSource = ConsultationRequestRemoteDataSource();

    // Repositories
    final expertAccountRepository = ExpertAccountRepositoryImpl(expertAccountDataSource);
    final expertCertificationRepository = ExpertCertificationRepositoryImpl(expertCertificationDataSource);
    final consultationRequestRepository = ConsultationRequestRepositoryImpl(consultationRequestDataSource);
    final expertRepository = ExpertRepositoryImpl();

    // Use Cases
    final getExpertAccountUseCase = GetExpertAccountUseCase(expertAccountRepository);
    final createExpertAccountUseCase = CreateExpertAccountUseCase(expertAccountRepository);
    final submitDocumentCertificationUseCase = SubmitDocumentCertificationUseCase(expertCertificationRepository);
    final submitInstantCertificationUseCase = SubmitInstantCertificationUseCase(expertCertificationRepository);
    final getConsultationRequestsUseCase = GetConsultationRequestsUseCase(consultationRequestRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(AuthCheckRequested()),
        ),
        BlocProvider<CaseBloc>(
          create: (_) => CaseBloc(),
        ),
        BlocProvider<ExpertBloc>(
          create: (_) => ExpertBloc(),
        ),
        BlocProvider<ReviewBloc>(
          create: (_) => ReviewBloc(),
        ),
        BlocProvider<ExpertDashboardBloc>(
          create: (_) => ExpertDashboardBloc(
            getExpertAccountUseCase: getExpertAccountUseCase,
            getConsultationRequestsUseCase: getConsultationRequestsUseCase,
            expertRepository: expertRepository,
          ),
        ),
        BlocProvider<ExpertCertificationBloc>(
          create: (_) => ExpertCertificationBloc(
            submitDocumentCertificationUseCase: submitDocumentCertificationUseCase,
            submitInstantCertificationUseCase: submitInstantCertificationUseCase,
            createExpertAccountUseCase: createExpertAccountUseCase,
            getExpertAccountUseCase: getExpertAccountUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ko', 'KR'),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}

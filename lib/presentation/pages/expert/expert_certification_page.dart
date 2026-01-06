import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:law_decode/presentation/blocs/auth/auth_bloc.dart';
import 'package:law_decode/presentation/blocs/auth/auth_state.dart';
import 'package:law_decode/presentation/blocs/expert_certification/expert_certification_bloc.dart';
import 'package:law_decode/presentation/blocs/expert_certification/expert_certification_state.dart';
import 'package:law_decode/presentation/widgets/expert/document_certification_tab.dart';
import 'package:law_decode/presentation/widgets/expert/instant_certification_tab.dart';
import 'package:law_decode/core/constants/app_colors.dart';
import 'package:law_decode/core/constants/app_sizes.dart';
import 'package:law_decode/core/router/app_router.dart';

import '../../blocs/expert_certification/expert_certification_event.dart';

/// 전문가 인증 페이지
class ExpertCertificationPage extends StatefulWidget {
  const ExpertCertificationPage({super.key});

  @override
  State<ExpertCertificationPage> createState() =>
      _ExpertCertificationPageState();
}

class _ExpertCertificationPageState extends State<ExpertCertificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('전문가 인증'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '신분증 정보로 즉시 인증'),
            Tab(text: '증빙서류 제출'),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
            child: BlocListener<ExpertCertificationBloc,
                ExpertCertificationState>(
              listener: (context, state) {
                if (state is CertificationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ 인증 신청이 완료되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // 대시보드로 이동
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.expertDashboard,
                    (route) => false,
                  );
                } else if (state is CertificationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ 인증 신청 실패: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  InstantCertificationTab(
                    onSubmit: (registrationNumber, idNumber) {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<ExpertCertificationBloc>().add(
                              SubmitInstantCertification(
                                userId: authState.user.id,
                                registrationNumber: registrationNumber,
                                idNumber: idNumber,
                              ),
                            );
                      }
                    },
                  ),
                  DocumentCertificationTab(
                    onSubmit: (idCardFile, licenseFile) {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<ExpertCertificationBloc>().add(
                              SubmitDocumentCertification(
                                userId: authState.user.id,
                                idCardFile: idCardFile,
                                licenseFile: licenseFile,
                              ),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


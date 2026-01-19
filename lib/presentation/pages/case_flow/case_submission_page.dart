import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/consultation_post.dart';
import '../../../domain/entities/expert.dart';
import '../../../domain/entities/expert_profile.dart';
import '../../../domain/repositories/consultation_post_repository.dart';
import '../../../domain/repositories/expert_profile_repository.dart';
import '../../../data/repositories/consultation_post_repository_impl.dart';
import '../../../data/repositories/expert_profile_repository_impl.dart';
import '../../../data/datasources/consultation_post_remote_datasource.dart';
import '../../../data/datasources/expert_profile_remote_datasource.dart';
import '../../../data/datasources/case_submission_remote_datasource.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/consultation_cases_bottom_sheet.dart';

/// 사건 전송 확인 페이지
class CaseSubmissionPage extends StatefulWidget {
  final String consultationPostId;
  final String expertUserId;
  final String? expertId;

  const CaseSubmissionPage({
    super.key,
    required this.consultationPostId,
    required this.expertUserId,
    this.expertId,
  });

  @override
  State<CaseSubmissionPage> createState() => _CaseSubmissionPageState();
}

class _CaseSubmissionPageState extends State<CaseSubmissionPage> {
  ConsultationPost? _consultationPost;
  ExpertProfile? _expertProfile;
  Expert? _expert;
  bool _isLoading = true;
  bool _isAgreed = false;
  bool _isSubmitting = false;
  bool _showFullSummary = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 상담 글 조회
      final consultationPostRepository = ConsultationPostRepositoryImpl(
        ConsultationPostRemoteDataSource(),
      );
      final post = await consultationPostRepository.getConsultationPostById(
        widget.consultationPostId,
      );

      // 전문가 프로필 조회
      final expertProfileRepository = ExpertProfileRepositoryImpl(
        remoteDataSource: ExpertProfileRemoteDataSource(),
      );
      final profile = await expertProfileRepository.getProfileByUserId(
        widget.expertUserId,
      );

      // Expert 정보 조회 (필요시) - ExpertRepositoryImpl은 다른 방식으로 생성됨
      Expert? expert;
      // Expert 정보는 expertProfile에서 충분하므로 생략 가능

      setState(() {
        _consultationPost = post;
        _expertProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('사건 전송'),
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_consultationPost == null || _expertProfile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('사건 전송'),
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('데이터를 불러올 수 없습니다'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('사건 전송'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 첫 번째 화면: 전문가에게 사건을 보낼까요?
              _buildFirstScreen(),
              const SizedBox(height: AppSizes.paddingL),
              // 두 번째 화면: 전달될 사건 요약, 알아두세요, 동의
              _buildSecondScreen(),
              const SizedBox(height: AppSizes.paddingL),
              // 상담 사례 보기 버튼
              _buildViewCasesButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewCasesButton() {
    return TextButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
          ),
          builder: (context) => const ConsultationCasesBottomSheet(),
        );
      },
      icon: const Icon(Icons.description_outlined),
      label: const Text('상담 사례 보기'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
      ),
    );
  }

  Widget _buildFirstScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        const Text(
          '전문가에게 사건을 보낼까요?',
          style: TextStyle(
            fontSize: AppSizes.fontXXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        const Text(
          '선택하신 전문가에게 사건 요약이 전달됩니다',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXL),
        // 사건 상세
        _buildCaseDetailSection(),
        const SizedBox(height: AppSizes.paddingL),
        // 선택한 전문가
        _buildSelectedExpertSection(),
      ],
    );
  }

  Widget _buildCaseDetailSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                '사건 상세',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            _consultationPost!.content,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedExpertSection() {
    // 전문 분야
    String specialization = _expertProfile!.mainFields.isNotEmpty
        ? _expertProfile!.mainFields.join(', ')
        : '법률 전문가';

    // 예상 응답 시간 (기본값)
    String responseTime = '평균 2시간';

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                '선택한 전문가',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildExpertInfoRow('이름', _expertProfile!.name ?? ''),
          const SizedBox(height: AppSizes.paddingS),
          _buildExpertInfoRow('전문 분야', specialization),
          const SizedBox(height: AppSizes.paddingS),
          _buildExpertInfoRow('예상 응답 시간', responseTime),
        ],
      ),
    );
  }

  Widget _buildExpertInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전달될 사건 요약
        _buildCaseSummarySection(),
        const SizedBox(height: AppSizes.paddingL),
        // 알아두세요
        _buildNoticeSection(),
        const SizedBox(height: AppSizes.paddingL),
        // 개인정보 이용 및 제공 동의
        _buildConsentSection(),
        const SizedBox(height: AppSizes.paddingXL),
        // 사건 전송하기 버튼
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildCaseSummarySection() {
    final summary = _consultationPost!.content;
    final displaySummary = _showFullSummary
        ? summary
        : (summary.length > 100 ? '${summary.substring(0, 100)}...' : summary);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                '전달될 사건 요약',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            displaySummary,
            style: const TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          if (summary.length > 100)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showFullSummary = !_showFullSummary;
                  });
                },
                child: Text(
                  _showFullSummary ? '접기' : '전체 보기',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: AppSizes.fontM,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoticeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '①',
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                '알아두세요',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildNoticeItem('전문가 검토 후 상담 방식과 일정을 안내합니다'),
          _buildNoticeItem('평균 검토 시간: 2-4시간'),
          _buildNoticeItem('답변은 알림과 이메일로 받으실 수 있습니다'),
          _buildNoticeItem('사건 전송 후에도 수정 요청이 가능합니다'),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppSizes.fontM,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildConsentSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                '개인정보 이용 및 제공 동의',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          const Text(
            '귀하의 사건 정보와 연락처가 선택한 전문가에게 안전하게 전달됩니다. 정보는 상담 목적으로만 사용되며, 제3자에게 제공되지 않습니다.',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Checkbox(
                value: _isAgreed,
                onChanged: (value) {
                  setState(() {
                    _isAgreed = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAgreed = !_isAgreed;
                    });
                  },
                  child: const Text(
                    '개인정보 이용 및 제공에 동의합니다',
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAgreed && !_isSubmitting ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isAgreed
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '사건 전송하기',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final dataSource = CaseSubmissionRemoteDataSource();
      
      // 사건 전송 정보 저장
      await dataSource.createCaseSubmission(
        userId: authState.user.id,
        consultationPostId: widget.consultationPostId,
        expertUserId: widget.expertUserId,
        expertId: widget.expertId,
      );

      // 통계 집계
      await dataSource.incrementSubmissionCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사건이 성공적으로 전송되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
        // 홈으로 이동
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사건 전송 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}


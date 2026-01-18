import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/expert_profile.dart';
import '../../../domain/entities/consultation_request.dart';
import '../../../domain/repositories/expert_profile_repository.dart';
import '../../../domain/repositories/expert_account_repository.dart';
import '../../../domain/repositories/consultation_request_repository.dart';
import '../../../data/repositories/expert_profile_repository_impl.dart';
import '../../../data/repositories/expert_account_repository_impl.dart';
import '../../../data/repositories/consultation_request_repository_impl.dart';
import '../../../data/datasources/expert_profile_remote_datasource.dart';
import '../../../data/datasources/expert_account_remote_datasource.dart';
import '../../../data/datasources/consultation_request_remote_datasource.dart';
import '../../blocs/expert/expert_bloc.dart';
import '../../blocs/expert/expert_event.dart';
import '../../blocs/expert/expert_state.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

/// 전문가 선택 확인 화면
class ConfirmPage extends StatefulWidget {
  final int? expertId;
  final String? userId;

  const ConfirmPage({super.key, this.expertId, this.userId});

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  ExpertProfile? _profile;
  bool _isLoadingProfile = true;
  String? _availabilityText;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    if (widget.userId != null) {
      context.read<ExpertBloc>().add(ExpertDetailByUserIdRequested(widget.userId!));
    } else if (widget.expertId != null) {
      context.read<ExpertBloc>().add(ExpertDetailRequested(widget.expertId!));
    }
  }

  Future<void> _loadProfile() async {
    if (widget.userId != null) {
      try {
        final repository = ExpertProfileRepositoryImpl(
          remoteDataSource: ExpertProfileRemoteDataSource(),
        );
        final profile = await repository.getProfileByUserId(widget.userId!);
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
        // 상담 가능 시간 계산
        if (profile != null) {
          _calculateAvailability(profile);
        }
      } catch (e) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } else {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  /// 상담 가능 시간 계산
  Future<void> _calculateAvailability(ExpertProfile profile) async {
    try {

      final expertAccountRepository = ExpertAccountRepositoryImpl(
        ExpertAccountRemoteDataSource(),
      );
      final expertAccount = await expertAccountRepository.getExpertAccountByUserId(profile.userId);

      if (expertAccount == null) {
        setState(() {
          _availabilityText = '정보 없음';
        });
        return;
      }
      
      final consultationRequestRepository = ConsultationRequestRepositoryImpl(
        ConsultationRequestRemoteDataSource(),
      );
      final requests = await consultationRequestRepository.getConsultationRequestsByExpertAccountId(
        expertAccount.id,
      );
      
      final now = DateTime.now();

      final scheduledTimes = requests
          .where((r) => r.scheduledAt != null && r.scheduledAt!.isAfter(now))
          .map((r) => r.scheduledAt!)
          .toList()
        ..sort();

      DateTime nextAvailableTime;
      

      nextAvailableTime = now.add(const Duration(hours: 1));
      

      if (profile.operatingStartTime != null && profile.operatingEndTime != null) {

        final startParts = profile.operatingStartTime!.split(':');
        final endParts = profile.operatingEndTime!.split(':');
        
        if (startParts.length == 2 && endParts.length == 2) {
          int startHour = int.tryParse(startParts[0]) ?? 9;
          int startMinute = int.tryParse(startParts[1]) ?? 0;
          int endHour = int.tryParse(endParts[0]) ?? 18;
          int endMinute = int.tryParse(endParts[1]) ?? 0;

          final todayStart = DateTime(now.year, now.month, now.day, startHour, startMinute);
          final todayEnd = DateTime(now.year, now.month, now.day, endHour, endMinute);
          

          if (now.isBefore(todayStart)) {
            nextAvailableTime = todayStart;
          }

          else if (now.isBefore(todayEnd)) {

            final minutes = now.minute;
            final roundedMinutes = ((minutes / 30).ceil() * 30) % 60;
            final roundedHours = now.hour + ((minutes / 30).ceil() * 30 ~/ 60);
            
            nextAvailableTime = DateTime(now.year, now.month, now.day, roundedHours, roundedMinutes);
            
            if (nextAvailableTime.difference(now).inHours < 1) {
              nextAvailableTime = now.add(const Duration(hours: 1));
            }
            
            if (nextAvailableTime.isAfter(todayEnd)) {

              nextAvailableTime = todayStart.add(const Duration(days: 1));
            }
          }
          else {
            nextAvailableTime = todayStart.add(const Duration(days: 1));
          }
        }
      }
      
      for (final scheduledTime in scheduledTimes) {
        if (nextAvailableTime.isBefore(scheduledTime.add(const Duration(minutes: 30)))) {
          final candidate = scheduledTime.add(const Duration(minutes: 30));
          if (candidate.isAfter(now)) {
            nextAvailableTime = candidate;
          }
        }
      }
      
      final difference = nextAvailableTime.difference(now);
      
      String availabilityText;
      if (difference.inMinutes < 60) {
        availabilityText = '${difference.inMinutes}분 후';
      } else if (difference.inHours < 24) {
        availabilityText = '${difference.inHours}시간 후';
      } else {
        availabilityText = '${difference.inDays}일 후';
      }

      setState(() {
        _availabilityText = availabilityText;
      });
    } catch (e) {
      setState(() {
        _availabilityText = '지금';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(child: LoadingWidget(message: '전문가 정보를 불러오는 중...')),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.person_off_outlined,
            title: '전문가를 찾을 수 없습니다',
            subtitle: '요청하신 전문가 정보가 없습니다',
          ),
        ),
      );
    }

    final profile = _profile!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('전문가 상세'),
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
              // 프로필 섹션
              _buildProfileSection(profile),
              const SizedBox(height: AppSizes.paddingL),
              
              // 상담 정보 섹션
              _buildConsultationInfoSection(profile),
              const SizedBox(height: AppSizes.paddingL),
              
              // 전문 분야 섹션
              _buildMainFieldsSection(profile),
              const SizedBox(height: AppSizes.paddingL),
              
              // 상세 정보 섹션
              _buildDetailInfoSection(profile),
              const SizedBox(height: AppSizes.paddingXL),
              
              // 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showConfirmDialog(profile.name ?? '전문가', 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  child: const Text(
                    '사건 요약 전송 및 상담 신청',
                    style: TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 프로필 섹션
  Widget _buildProfileSection(ExpertProfile profile) {
    // 직업 타입 결정
    String profession = '변호사';
    if (profile.examType != null) {
      if (profile.examType!.contains('노무사')) {
        profession = '노무사';
      } else if (profile.examType!.contains('변호사')) {
        profession = '변호사';
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: profile.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      profile.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(profile.name ?? '?');
                      },
                    ),
                  )
                : _buildDefaultAvatar(profile.name ?? '?'),
          ),
          const SizedBox(width: AppSizes.paddingM),
          // 이름, 직업, 소속, 소개
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름 + 직업 태그
                Row(
                  children: [
                    Text(
                      profile.name ?? '이름 없음',
                      style: const TextStyle(
                        fontSize: AppSizes.fontL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profession,
                        style: const TextStyle(
                          fontSize: AppSizes.fontXS,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // 소속
                if (profile.officeName != null && profile.officeName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.officeName!,
                    style: TextStyle(
                      fontSize: AppSizes.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                // 한 줄 소개
                if (profile.oneLineIntro != null && profile.oneLineIntro!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.oneLineIntro!,
                    style: const TextStyle(
                      fontSize: AppSizes.fontM,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 상담 정보 섹션
  Widget _buildConsultationInfoSection(ExpertProfile profile) {
    // 상담 시간 텍스트
    String consultationTime = '15분 전화상담, 30분 방문상담';

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상담 정보',
            style: TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 상담 가능
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '상담 가능',
                style: TextStyle(fontSize: AppSizes.fontM),
              ),
              Text(
                _availabilityText ?? '지금',
                style: const TextStyle(fontSize: AppSizes.fontM),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 상담 시간
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '상담 시간',
                style: TextStyle(fontSize: AppSizes.fontM),
              ),
              Text(
                consultationTime,
                style: const TextStyle(fontSize: AppSizes.fontM),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // 연락처 아이콘
          Row(
            children: [
              if (profile.isPhoneInquiryEnabled == true)
                Icon(Icons.phone, color: Colors.red[700], size: 24),
              if (profile.isKakaoTalkInquiryEnabled == true) ...[
                const SizedBox(width: AppSizes.paddingM),
                Icon(Icons.chat_bubble_outline, color: Colors.black87, size: 24),
              ],
              if (profile.isEmailInquiryEnabled == true) ...[
                const SizedBox(width: AppSizes.paddingM),
                Icon(Icons.email_outlined, color: Colors.black87, size: 24),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 전문 분야 섹션
  Widget _buildMainFieldsSection(ExpertProfile profile) {
    if (profile.mainFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSizes.paddingS,
      runSpacing: AppSizes.paddingS,
      children: profile.mainFields.map((field) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            field,
            style: const TextStyle(fontSize: AppSizes.fontS),
          ),
        );
      }).toList(),
    );
  }

  /// 상세 정보 섹션
  Widget _buildDetailInfoSection(ExpertProfile profile) {
    // 지역
    String region = '${profile.officeRegion1 ?? ''} ${profile.officeRegion2 ?? ''}'.trim();
    if (region.isEmpty) region = '지역 정보 없음';

    // 경력 계산 (passYear 기반)
    int? experienceYears;
    if (profile.passYear != null) {
      final now = DateTime.now();
      experienceYears = now.year - profile.passYear!;
    }

    // 성별
    String genderText = '상관없음';
    if (profile.gender == 'male') {
      genderText = '남';
    } else if (profile.gender == 'female') {
      genderText = '여';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상세 정보',
            style: TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildDetailRow('지역', region),
          _buildDetailRow('경력', experienceYears != null ? '${experienceYears}년' : '정보 없음'),
          _buildDetailRow('성별', genderText),
          _buildDetailRow(
            '전문 등록',
            profile.isKbaSpecializationRegistered ? '등록됨' : '등록 안됨',
          ),
          // 특수 자격
          if (profile.specialQualifications.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: const Text(
                    '특수 자격',
                    style: TextStyle(fontSize: AppSizes.fontM),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: AppSizes.paddingS,
                    runSpacing: AppSizes.paddingS,
                    children: profile.specialQualifications.map((qual) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          qual,
                          style: const TextStyle(fontSize: AppSizes.fontS),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
          // 경험
          if (profile.experiences.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: const Text(
                    '경험',
                    style: TextStyle(fontSize: AppSizes.fontM),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: AppSizes.paddingS,
                    runSpacing: AppSizes.paddingS,
                    children: profile.experiences.map((exp) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          exp,
                          style: const TextStyle(fontSize: AppSizes.fontS),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
          // 외국어
          if (profile.languages.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: const Text(
                    '외국어',
                    style: TextStyle(fontSize: AppSizes.fontM),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: AppSizes.paddingS,
                    runSpacing: AppSizes.paddingS,
                    children: profile.languages.map((lang) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lang,
                          style: const TextStyle(fontSize: AppSizes.fontS),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: AppSizes.fontM),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0] : '?',
        style: const TextStyle(
          fontSize: AppSizes.fontXXL,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showConfirmDialog(String expertName, int expertId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('상담 신청'),
        content: Text('$expertName님에게 상담을 신청하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('상담이 신청되었습니다')),
              );
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

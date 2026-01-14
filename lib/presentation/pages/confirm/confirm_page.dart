import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
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
  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      context.read<ExpertBloc>().add(ExpertDetailByUserIdRequested(widget.userId!));
    } else if (widget.expertId != null) {
      context.read<ExpertBloc>().add(ExpertDetailRequested(widget.expertId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('전문가 확인'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
            child: BlocBuilder<ExpertBloc, ExpertState>(
              builder: (context, state) {
                if (state is ExpertLoading) {
                  return const LoadingWidget(message: '전문가 정보를 불러오는 중...');
                }

                if (state is ExpertError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () {
                      if (widget.userId != null) {
                        context.read<ExpertBloc>().add(ExpertDetailByUserIdRequested(widget.userId!));
                      } else if (widget.expertId != null) {
                        context.read<ExpertBloc>().add(ExpertDetailRequested(widget.expertId!));
                      }
                    },
                  );
                }

                if (state is ExpertDetailLoaded) {
                  final expert = state.expert;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Column(
                      children: [
                        // 전문가 상세 카드
                        Container(
                          width: double.infinity,
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
                          child: Column(
                            children: [
                              // 프로필
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                backgroundImage: expert.profileImage != null
                                    ? NetworkImage(expert.profileImage!)
                                    : null,
                                child: expert.profileImage == null
                                    ? Text(
                                        expert.name[0],
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: AppSizes.fontXXL,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: AppSizes.paddingM),
                              Text(
                                expert.name,
                                style: const TextStyle(
                                  fontSize: AppSizes.fontXXL,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingS),
                              Text(
                                expert.specialty,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppSizes.fontL,
                                ),
                              ),
                              if (expert.lawFirm != null) ...[
                                const SizedBox(height: AppSizes.paddingS),
                                Text(
                                  expert.lawFirm!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: AppSizes.fontM,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSizes.paddingL),
                              const Divider(),
                              const SizedBox(height: AppSizes.paddingL),
                              // 정보
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildInfoItem('평점', '${expert.rating}'),
                                  _buildInfoItem('리뷰', '${expert.reviewCount}건'),
                                  _buildInfoItem('경력', '${expert.experienceYears}년'),
                                  _buildInfoItem('상담', '${expert.consultationCount}건'),
                                ],
                              ),
                              if (expert.introduction != null) ...[
                                const SizedBox(height: AppSizes.paddingL),
                                const Divider(),
                                const SizedBox(height: AppSizes.paddingL),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '자기소개',
                                    style: TextStyle(
                                      fontSize: AppSizes.fontL,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.paddingS),
                                Text(
                                  expert.introduction!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: AppSizes.fontM,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                              if (expert.certifications != null &&
                                  expert.certifications!.isNotEmpty) ...[
                                const SizedBox(height: AppSizes.paddingL),
                                const Divider(),
                                const SizedBox(height: AppSizes.paddingL),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '자격증',
                                    style: TextStyle(
                                      fontSize: AppSizes.fontL,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.paddingS),
                                Wrap(
                                  spacing: AppSizes.paddingS,
                                  runSpacing: AppSizes.paddingS,
                                  children: expert.certifications!.map((cert) {
                                    return Chip(
                                      label: Text(cert),
                                      backgroundColor: AppColors.surfaceVariant,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXL),
                        // 버튼
                        PrimaryButton(
                          text: '이 전문가와 상담하기',
                          onPressed: () => _showConfirmDialog(expert.name, expert.id),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        PrimaryButton(
                          text: '다른 전문가 보기',
                          isOutlined: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                }

                return const EmptyStateWidget(
                  icon: Icons.person_off_outlined,
                  title: '전문가를 찾을 수 없습니다',
                  subtitle: '요청하신 전문가 정보가 없습니다',
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontS,
          ),
        ),
      ],
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

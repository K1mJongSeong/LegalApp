import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/legal_case.dart';
import '../../blocs/case/case_bloc.dart';
import '../../blocs/case/case_event.dart';
import '../../blocs/case/case_state.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

/// 사건 요약 화면
class SummaryPage extends StatefulWidget {
  final String? caseId;

  const SummaryPage({super.key, this.caseId});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  void initState() {
    super.initState();
    if (widget.caseId != null) {
      context.read<CaseBloc>().add(CaseDetailRequested(widget.caseId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CaseBloc, CaseState>(
      listener: (context, state) {
        if (state is CaseDeleted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사건이 삭제되었습니다')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('사건 요약'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptions(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
              child: widget.caseId == null
                  ? _buildDemoContent()
                  : BlocBuilder<CaseBloc, CaseState>(
                      builder: (context, state) {
                        if (state is CaseLoading) {
                          return const LoadingWidget(message: '사건 정보를 불러오는 중...');
                        }

                        if (state is CaseError) {
                          return ErrorStateWidget(
                            message: state.message,
                            onRetry: () {
                              if (widget.caseId != null) {
                                context.read<CaseBloc>().add(CaseDetailRequested(widget.caseId!));
                              }
                            },
                          );
                        }

                        if (state is CaseDetailLoaded) {
                          return _buildCaseContent(state.legalCase);
                        }

                        return const EmptyStateWidget(
                          icon: Icons.folder_off_outlined,
                          title: '사건을 찾을 수 없습니다',
                          subtitle: '요청하신 사건 정보가 없습니다',
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: Text(
                    '이 화면은 사건 상세 정보를 표시합니다.\n사건을 등록하면 여기서 진행 상황을 확인할 수 있습니다.',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: AppSizes.fontS,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.white),
                    SizedBox(width: AppSizes.paddingS),
                    Text(
                      '사건 없음',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.fontL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.paddingS),
                Text(
                  '아직 등록된 사건이 없습니다',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: AppSizes.fontM,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseContent(LegalCase caseItem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상태 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(caseItem.status),
                  _getStatusColor(caseItem.status).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getStatusIcon(caseItem.status), color: Colors.white),
                    const SizedBox(width: AppSizes.paddingS),
                    Text(
                      caseItem.status.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.fontL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  _getStatusDescription(caseItem.status),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: AppSizes.fontM,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 사건 정보
          _buildSection(
            title: '사건 정보',
            children: [
              _buildInfoRow('제목', caseItem.title),
              _buildInfoRow('카테고리', _getCategoryLabel(caseItem.category)),
              _buildInfoRow('긴급도', _getUrgencyLabel(caseItem.urgency)),
              _buildInfoRow('등록일', _formatDate(caseItem.createdAt)),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 담당 전문가
          if (caseItem.assignedExpert != null) ...[
            _buildSection(
              title: '담당 전문가',
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          caseItem.assignedExpert!.name[0],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caseItem.assignedExpert!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.fontL,
                              ),
                            ),
                            Text(
                              caseItem.assignedExpert!.specialty,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AppSizes.fontS,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_outlined),
                        color: AppColors.primary,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('메시지 기능은 준비 중입니다')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildSection(
              title: '담당 전문가',
              children: const [
                EmptyStateWidget(
                  icon: Icons.person_search_outlined,
                  title: '아직 전문가가 배정되지 않았습니다',
                  subtitle: '곧 적합한 전문가가 배정될 예정입니다',
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSizes.paddingL),
          // 상세 내용
          _buildSection(
            title: '상세 내용',
            children: [
              Text(
                caseItem.description,
                style: const TextStyle(
                  fontSize: AppSizes.fontM,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingXL),
          if (caseItem.assignedExpert != null)
            PrimaryButton(
              text: '전문가에게 메시지 보내기',
              icon: Icons.chat,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메시지 기능은 준비 중입니다')),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontM,
              ),
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

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('사건 수정'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('사건 수정 기능은 준비 중입니다')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('사건 삭제', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (widget.caseId != null) {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('사건 삭제'),
                        content: const Text('이 사건을 삭제하시겠습니까?\n삭제된 사건은 복구할 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('취소'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && mounted) {
                      context.read<CaseBloc>().add(CaseDeleteRequested(widget.caseId!));
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return AppColors.warning;
      case CaseStatus.inProgress:
        return AppColors.primary;
      case CaseStatus.completed:
        return AppColors.success;
      case CaseStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Icons.hourglass_empty;
      case CaseStatus.inProgress:
        return Icons.hourglass_top;
      case CaseStatus.completed:
        return Icons.check_circle;
      case CaseStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return '전문가 배정을 기다리고 있습니다';
      case CaseStatus.inProgress:
        return '전문가가 사건을 검토 중입니다';
      case CaseStatus.completed:
        return '상담이 완료되었습니다';
      case CaseStatus.cancelled:
        return '상담이 취소되었습니다';
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'labor':
        return '노동/근로';
      case 'tax':
        return '세금/조세';
      case 'criminal':
        return '형사';
      case 'family':
        return '가사/이혼';
      case 'real':
        return '부동산';
      default:
        return category;
    }
  }

  String _getUrgencyLabel(String urgency) {
    switch (urgency) {
      case 'simple':
        return '간단 상담';
      case 'normal':
        return '일반';
      case 'urgent':
        return '긴급';
      default:
        return urgency;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}

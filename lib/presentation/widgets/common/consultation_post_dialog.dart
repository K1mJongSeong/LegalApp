import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';

/// 상담 글 작성 팝업
class ConsultationPostDialog extends StatefulWidget {
  final String initialSummary;
  final String category;

  const ConsultationPostDialog({
    super.key,
    required this.initialSummary,
    required this.category,
  });

  @override
  State<ConsultationPostDialog> createState() => _ConsultationPostDialogState();
}

class _ConsultationPostDialogState extends State<ConsultationPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final int _titleMinLength = 10;
  final int _titleMaxLength = 50;
  final int _contentMinLength = 50;
  DateTime? _incidentDate;
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialSummary;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 입력 유효성 검증
  bool get _isValid {
    final titleLength = _titleController.text.trim().length;
    final contentLength = _contentController.text.trim().length;
    return titleLength >= _titleMinLength &&
        titleLength <= _titleMaxLength &&
        contentLength >= _contentMinLength &&
        _incidentDate != null &&
        _isAgreed;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '상담 글 작성',
                    style: TextStyle(
                      fontSize: AppSizes.fontXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // 내용
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    _buildTitleField(),
                    const SizedBox(height: AppSizes.paddingL),
                    // 최초 사건 발생 일자
                    _buildIncidentDateField(),
                    const SizedBox(height: AppSizes.paddingL),
                    // 내용
                    _buildContentField(),
                    const SizedBox(height: AppSizes.paddingL),
                    // 작성 TIP
                    _buildWritingTip(),
                    const SizedBox(height: AppSizes.paddingL),
                    // 필수 안내사항
                    _buildRequiredInfo(),
                  ],
                ),
              ),
            ),
            // 하단 버튼 영역
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                children: [
                  // 동의 체크박스
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
                            '안내 사항을 모두 확인했으며, 동의합니다.',
                            style: TextStyle(
                              fontSize: AppSizes.fontS,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  // 등록 완료 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValid
                          ? () {
                              // 전문가 목록으로 이동
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.experts,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                      child: const Text(
                        '등록 완료 및 전문가 목록 보기',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  // 취소 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    final titleLength = _titleController.text.trim().length;
    final isValid = titleLength >= _titleMinLength && titleLength <= _titleMaxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              '제목',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextField(
          controller: _titleController,
          maxLength: _titleMaxLength,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '제목을 구체적으로 입력해주세요.',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: titleLength > 0 && !isValid
                    ? AppColors.warning
                    : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (titleLength < _titleMinLength && titleLength > 0)
              Text(
                '최소 $_titleMinLength자 이상 입력해주세요.',
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  color: AppColors.warning,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              '$titleLength / $_titleMaxLength자',
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: isValid ? AppColors.textSecondary : AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncidentDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              '최초 사건 발생 일자',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        GestureDetector(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _incidentDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              locale: const Locale('ko', 'KR'),
            );
            if (pickedDate != null) {
              setState(() {
                _incidentDate = pickedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _incidentDate != null
                        ? DateFormat('yyyy. MM. dd.').format(_incidentDate!)
                        : '연도. 월. 일.',
                    style: TextStyle(
                      color: _incidentDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    final contentLength = _contentController.text.trim().length;
    final isValid = contentLength >= _contentMinLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text(
                  '내용',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            Text(
              '$contentLength / 최소 $_contentMinLength자',
              style: TextStyle(
                fontSize: AppSizes.fontS,
                color: isValid ? AppColors.textSecondary : AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          constraints: const BoxConstraints(minHeight: 150),
          child: TextField(
            controller: _contentController,
            maxLines: null,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '사건에 대해 상세히 설명해주세요.',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(
                  color: contentLength > 0 && !isValid
                      ? AppColors.warning
                      : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppSizes.paddingM),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWritingTip() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                '작성 TIP',
                style: TextStyle(
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '1개의 질문을 구체적으로 작성해주세요. 예) 사기로 고소를 당했는데, 어떻게 대응해야 할까요?',
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상담글 등록 시 필수 안내사항',
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildInfoItem('1. 상담글 제목은 담변을 방지에 적합한 내용으로 일목 법정질 수 있습니다.'),
          _buildInfoItem('2. 상담글은 변호사 담변 등록 글 작게가 들기함합니다.'),
          _buildInfoItem('3. 등록된 글은 네이버 지식인, 포털 사이트, 로톡 사이트에 노출됩니다.'),
          _buildInfoItem('4. 아래 사항에 해당할 경우, 서비스 이용이 제한될 수 있습니다.'),
          const SizedBox(height: AppSizes.paddingS),
          _buildInfoItem('• 개인정보(개인/법인 실명, 전화번호, 주민번호, 주소, 아이디 등) 및 외부 링크 포함'),
          _buildInfoItem('• 변호사 선언 및 변호사 선언 비용과 관련된 질문'),
          _buildInfoItem('• 법률 문제 해결을 목적의 상담글이 아닌 경우'),
          _buildInfoItem('• 동일/유사한 내용의 지속적인 반복 게재'),
          _buildInfoItem('• 의미없는 문자의 나열 포함'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppSizes.fontS,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}


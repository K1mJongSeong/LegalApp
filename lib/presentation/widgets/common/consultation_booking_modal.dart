import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

/// 상담 예약 모달
class ConsultationBookingModal extends StatefulWidget {
  final String expertName;
  final String consultationType; // 'phone' or 'visit'
  final int durationMinutes; // 15 or 30
  final Function(DateTime scheduledAt) onConfirm;

  const ConsultationBookingModal({
    super.key,
    required this.expertName,
    required this.consultationType,
    required this.durationMinutes,
    required this.onConfirm,
  });

  @override
  State<ConsultationBookingModal> createState() => _ConsultationBookingModalState();
}

class _ConsultationBookingModalState extends State<ConsultationBookingModal> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 기본값: 오늘 날짜, 현재 시간 + 1시간
    _selectedDate = DateTime.now();
    final now = DateTime.now();
    _selectedTime = TimeOfDay(
      hour: (now.hour + 1) % 24,
      minute: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.expertName}님과의 상담 예약',
                      style: const TextStyle(
                        fontSize: AppSizes.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.durationMinutes}분 ${widget.consultationType == 'phone' ? '전화' : '방문'}상담',
                      style: const TextStyle(
                        fontSize: AppSizes.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 날짜 선택
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '날짜 선택',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate!)
                              : '날짜를 선택하세요',
                          style: TextStyle(
                            fontSize: AppSizes.fontM,
                            color: _selectedDate != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 시간 선택
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingL,
              0,
              AppSizes.paddingL,
              AppSizes.paddingL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '시간 선택',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                InkWell(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : '시간을 선택하세요',
                          style: TextStyle(
                            fontSize: AppSizes.fontM,
                            color: _selectedTime != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Icon(Icons.access_time, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 예약하기 버튼
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  disabledBackgroundColor: AppColors.textSecondary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '예약하기',
                        style: TextStyle(
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 선택
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 30)); // 30일 후까지

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 시간 선택
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// 예약 확인
  Future<void> _handleConfirm() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('날짜와 시간을 모두 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 선택한 날짜와 시간을 합쳐서 DateTime 생성
    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // 과거 시간인지 확인
    if (scheduledAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('과거 시간은 선택할 수 없습니다'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onConfirm(scheduledAt);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('예약이 완료되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예약 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}





import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/retainer_fee.dart';

/// 수임료 정보 섹션
class RetainerFeeSection extends StatefulWidget {
  const RetainerFeeSection({super.key});

  @override
  State<RetainerFeeSection> createState() => _RetainerFeeSectionState();
}

class _RetainerFeeSectionState extends State<RetainerFeeSection> {
  List<RetainerFeeItem> _retainerFeeItems = [RetainerFeeItem()];

  // 요금범위 옵션
  static const List<String> _feeRangeOptions = [
    '고정금액',
    '~부터',
    '범위',
    '협의',
  ];

  // 성공보수 단위 옵션
  static const List<String> _successFeeUnitOptions = [
    '금액',
    '백분율',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '수임료 정보',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  '의뢰인에게는 노출되지 않습니다.',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 수임료 정보 항목들
                ...List.generate(_retainerFeeItems.length, (index) {
                  return _buildRetainerFeeItem(index);
                }),
                const SizedBox(height: AppSizes.paddingL),
                // 항목추가/제거 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addRetainerFeeItem,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: const Text(
                          '항목추가',
                          style: TextStyle(
                            fontSize: AppSizes.fontM,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical: AppSizes.paddingM,
                          ),
                        ),
                      ),
                    ),
                    if (_retainerFeeItems.length > 1) ...[
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _removeRetainerFeeItem,
                          icon: const Icon(
                            Icons.remove,
                            color: AppColors.error,
                            size: 20,
                          ),
                          label: const Text(
                            '항목제거',
                            style: TextStyle(
                              fontSize: AppSizes.fontM,
                              color: AppColors.error,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingM,
                              vertical: AppSizes.paddingM,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // 저장하기 버튼
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: const Text(
                '저장하기',
                style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 수임료 정보 항목 빌더
  Widget _buildRetainerFeeItem(int index) {
    final item = _retainerFeeItems[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          const Divider(height: AppSizes.paddingXL),
          const SizedBox(height: AppSizes.paddingL),
        ],
        // 소송 종류
        _buildTextField(
          label: '소송 종류',
          controller: item.lawsuitTypeController,
          hint: '소송의 종류',
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 착수금 섹션
        const Text(
          '착수금',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(right: AppSizes.paddingS),
                child: Text(
                  '단위: 원',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: item.retainerFeeAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: '금액',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingM,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              flex: 2,
              child: _buildDropdownField(
                value: item.retainerFeeRange,
                hint: '[요금범위]',
                items: _feeRangeOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _retainerFeeItems[index] = item.copyWith(retainerFeeRange: value);
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingL),
        // 성공보수 섹션
        const Text(
          '성공보수',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildDropdownField(
                value: item.successFeeUnit,
                hint: '[단위 선택]',
                items: _successFeeUnitOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _retainerFeeItems[index] = item.copyWith(successFeeUnit: value);
                  });
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              flex: 2,
              child: TextField(
                controller: item.successFeeValueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: item.successFeeUnit == '백분율'
                      ? '백분율'
                      : item.successFeeUnit == '금액'
                          ? '금액'
                          : '금액 또는 백분율',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingM,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              flex: 2,
              child: _buildDropdownField(
                value: item.successFeeRange,
                hint: '[요금범위]',
                items: _feeRangeOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _retainerFeeItems[index] = item.copyWith(successFeeRange: value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 텍스트 필드 빌더
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
        ),
      ],
    );
  }

  /// 드롭다운 필드 빌더
  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS,
            vertical: AppSizes.paddingM,
          ),
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              hint,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ...items,
        ],
        onChanged: onChanged,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 수임료 정보 항목 추가
  void _addRetainerFeeItem() {
    setState(() {
      _retainerFeeItems.add(RetainerFeeItem());
    });
  }

  /// 수임료 정보 항목 제거
  void _removeRetainerFeeItem() {
    if (_retainerFeeItems.length > 1) {
      setState(() {
        final removedItem = _retainerFeeItems.removeLast();
        removedItem.lawsuitTypeController.dispose();
        removedItem.retainerFeeAmountController.dispose();
        removedItem.successFeeValueController.dispose();
      });
    }
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // RetainerFee 엔티티로 변환
    final retainerFees = _retainerFeeItems.map((item) {
      return RetainerFee(
        lawsuitType: item.lawsuitTypeController.text.trim().isEmpty
            ? null
            : item.lawsuitTypeController.text.trim(),
        retainerFeeAmount: item.retainerFeeAmountController.text.trim().isEmpty
            ? null
            : int.tryParse(item.retainerFeeAmountController.text.trim().replaceAll(',', '')),
        retainerFeeRange: item.retainerFeeRange,
        successFeeUnit: item.successFeeUnit,
        successFeeValue: item.successFeeValueController.text.trim().isEmpty
            ? null
            : item.successFeeValueController.text.trim(),
        successFeeRange: item.successFeeRange,
      );
    }).toList();

    // TODO: 데이터 저장 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('저장되었습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    for (var item in _retainerFeeItems) {
      item.lawsuitTypeController.dispose();
      item.retainerFeeAmountController.dispose();
      item.successFeeValueController.dispose();
    }
    super.dispose();
  }
}

/// 수임료 정보 항목 데이터 클래스
class RetainerFeeItem {
  final TextEditingController lawsuitTypeController;
  final TextEditingController retainerFeeAmountController;
  final String? retainerFeeRange;
  final String? successFeeUnit;
  final TextEditingController successFeeValueController;
  final String? successFeeRange;

  RetainerFeeItem({
    TextEditingController? lawsuitTypeController,
    TextEditingController? retainerFeeAmountController,
    this.retainerFeeRange,
    this.successFeeUnit,
    TextEditingController? successFeeValueController,
    this.successFeeRange,
  })  : lawsuitTypeController = lawsuitTypeController ?? TextEditingController(),
        retainerFeeAmountController = retainerFeeAmountController ?? TextEditingController(),
        successFeeValueController = successFeeValueController ?? TextEditingController();

  RetainerFeeItem copyWith({
    TextEditingController? lawsuitTypeController,
    TextEditingController? retainerFeeAmountController,
    String? retainerFeeRange,
    String? successFeeUnit,
    TextEditingController? successFeeValueController,
    String? successFeeRange,
  }) {
    return RetainerFeeItem(
      lawsuitTypeController: lawsuitTypeController ?? this.lawsuitTypeController,
      retainerFeeAmountController: retainerFeeAmountController ?? this.retainerFeeAmountController,
      retainerFeeRange: retainerFeeRange ?? this.retainerFeeRange,
      successFeeUnit: successFeeUnit ?? this.successFeeUnit,
      successFeeValueController: successFeeValueController ?? this.successFeeValueController,
      successFeeRange: successFeeRange ?? this.successFeeRange,
    );
  }
}
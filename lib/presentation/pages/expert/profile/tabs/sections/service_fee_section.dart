import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../domain/entities/service_fee.dart';

/// 서비스 요금 섹션
class ServiceFeeSection extends StatefulWidget {
  const ServiceFeeSection({super.key});

  @override
  State<ServiceFeeSection> createState() => _ServiceFeeSectionState();
}

class _ServiceFeeSectionState extends State<ServiceFeeSection> {
  // 지불방법 선택
  final Set<String> _selectedPaymentMethods = {};

  List<ServiceFeeItem> _serviceFeeItems = [ServiceFeeItem()];

  // 지불방법 옵션
  static const List<String> _paymentMethodOptions = [
    '최초 상담 무료',
    '할부 가능',
    '후불 가능',
    '카드결제 가능',
  ];

  // 서비스 종류 옵션 (예시)
  static const List<String> _serviceTypeOptions = [
    '법률자문',
    '계약서 작성',
    '소송 대리',
    '조정/중재',
    '각종 서류 작성',
    '기타',
  ];

  // 단위 옵션
  static const List<String> _unitOptions = [
    '원',
  ];

  // 요금범위 옵션
  static const List<String> _feeRangeOptions = [
    '고정금액',
    '~부터',
    '범위',
    '협의',
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
                  '서비스 요금',
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
                // 지불정보 섹션
                const Text(
                  '지불정보',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                const Text(
                  '지불방법',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                // 지불방법 체크박스들
                ..._paymentMethodOptions.map((method) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                    child: _buildCheckboxOption(
                      value: method,
                      label: method,
                      isSelected: _selectedPaymentMethods.contains(method),
                      onChanged: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPaymentMethods.add(method);
                          } else {
                            _selectedPaymentMethods.remove(method);
                          }
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: AppSizes.paddingXL),
                // 요금정보 섹션
                const Text(
                  '요금정보',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                // 참고 박스
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: Colors.orange.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[참고]',
                        style: TextStyle(
                          fontSize: AppSizes.fontM,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: Text(
                          '서비스 요금은 VAT를 포함하여 최소 1개 이상 항목을 입력하셔야 합니다!',
                          style: TextStyle(
                            fontSize: AppSizes.fontM,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 서비스 요금 항목들
                ...List.generate(_serviceFeeItems.length, (index) {
                  return _buildServiceFeeItem(index);
                }),
                const SizedBox(height: AppSizes.paddingL),
                // 항목추가 버튼
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _addServiceFeeItem,
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

  /// 서비스 요금 항목 빌더
  Widget _buildServiceFeeItem(int index) {
    final item = _serviceFeeItems[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          const Divider(height: AppSizes.paddingXL),
          const SizedBox(height: AppSizes.paddingL),
        ],
        // 서비스 종류
        _buildServiceTypeField(index),
        const SizedBox(height: AppSizes.paddingL),
        // 서비스 요금
        const Text(
          '서비스 요금',
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
                value: item.unit,
                hint: '[단위 선택]',
                items: _unitOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _serviceFeeItems[index] = item.copyWith(unit: value);
                  });
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              flex: 3,
              child: TextField(
                controller: item.amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: '금액 (단위: 원)',
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
                value: item.feeRange,
                hint: '[요금범위]',
                items: _feeRangeOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _serviceFeeItems[index] = item.copyWith(feeRange: value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 서비스 종류 필드 (드롭다운 또는 직접입력)
  Widget _buildServiceTypeField(int index) {
    final item = _serviceFeeItems[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스 종류',
          style: TextStyle(
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            value: item.serviceType,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: '제공서비스 [직접입력 또는 옵션선택]',
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
                  '제공서비스 [직접입력 또는 옵션선택]',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ..._serviceTypeOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _serviceFeeItems[index] = item.copyWith(serviceType: value);
                // 옵션 선택 시 텍스트 필드 비활성화, 직접입력 시 활성화
                if (value != null && value != '기타') {
                  item.serviceTypeController.clear();
                }
              });
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // 직접입력 필드 (기타 선택 시 또는 옵션 미선택 시)
        if (item.serviceType == null || item.serviceType == '기타') ...[
          const SizedBox(height: AppSizes.paddingS),
          TextField(
            controller: item.serviceTypeController,
            enabled: item.serviceType == '기타' || item.serviceType == null,
            decoration: InputDecoration(
              hintText: '서비스 종류를 직접 입력하세요',
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
      ],
    );
  }

  /// 체크박스 옵션 빌더
  Widget _buildCheckboxOption({
    required String value,
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!isSelected),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              color: Colors.white,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontM,
            color: AppColors.textPrimary,
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

  /// 서비스 요금 항목 추가
  void _addServiceFeeItem() {
    setState(() {
      _serviceFeeItems.add(ServiceFeeItem());
    });
  }

  /// 저장하기 핸들러
  void _handleSave() {
    // 최소 1개 이상 항목 검증
    if (_serviceFeeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1개 이상의 서비스 요금 항목을 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // ServiceFee 엔티티로 변환
    final serviceFees = _serviceFeeItems.map((item) {
      final serviceType = item.serviceType ?? item.serviceTypeController.text.trim();
      return ServiceFee(
        serviceType: serviceType.isEmpty ? null : serviceType,
        unit: item.unit,
        amount: item.amountController.text.trim().isEmpty
            ? null
            : int.tryParse(item.amountController.text.trim().replaceAll(',', '')),
        feeRange: item.feeRange,
      );
    }).where((fee) => fee.serviceType != null).toList();

    // 최소 1개 이상 검증
    if (serviceFees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1개 이상의 서비스 요금 항목을 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 지불방법 매핑
    final paymentMethods = _selectedPaymentMethods.map((method) {
      switch (method) {
        case '최초 상담 무료':
          return 'freeConsultation';
        case '할부 가능':
          return 'installment';
        case '후불 가능':
          return 'postPayment';
        case '카드결제 가능':
          return 'cardPayment';
        default:
          return method;
      }
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
    for (var item in _serviceFeeItems) {
      item.serviceTypeController.dispose();
      item.amountController.dispose();
    }
    super.dispose();
  }
}

/// 서비스 요금 항목 데이터 클래스
class ServiceFeeItem {
  final String? serviceType;
  final TextEditingController serviceTypeController;
  final String? unit;
  final TextEditingController amountController;
  final String? feeRange;

  ServiceFeeItem({
    this.serviceType,
    TextEditingController? serviceTypeController,
    this.unit,
    TextEditingController? amountController,
    this.feeRange,
  })  : serviceTypeController = serviceTypeController ?? TextEditingController(),
        amountController = amountController ?? TextEditingController();

  ServiceFeeItem copyWith({
    String? serviceType,
    TextEditingController? serviceTypeController,
    String? unit,
    TextEditingController? amountController,
    String? feeRange,
  }) {
    return ServiceFeeItem(
      serviceType: serviceType ?? this.serviceType,
      serviceTypeController: serviceTypeController ?? this.serviceTypeController,
      unit: unit ?? this.unit,
      amountController: amountController ?? this.amountController,
      feeRange: feeRange ?? this.feeRange,
    );
  }
}


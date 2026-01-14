import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';

/// 세금계산서 정보 섹션
class TaxInvoiceInfoSection extends StatefulWidget {
  const TaxInvoiceInfoSection({super.key});

  @override
  State<TaxInvoiceInfoSection> createState() => _TaxInvoiceInfoSectionState();
}

class _TaxInvoiceInfoSectionState extends State<TaxInvoiceInfoSection> {
  String _selectedType = 'taxInvoice'; // 'taxInvoice' or 'cashReceipt'
  final TextEditingController _businessRegistrationNumberController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _representativeNameController = TextEditingController();
  final TextEditingController _taxInvoiceEmailController = TextEditingController();
  final TextEditingController _additionalTaxInvoiceEmailController = TextEditingController();

  @override
  void dispose() {
    _businessRegistrationNumberController.dispose();
    _companyNameController.dispose();
    _representativeNameController.dispose();
    _taxInvoiceEmailController.dispose();
    _additionalTaxInvoiceEmailController.dispose();
    super.dispose();
  }

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
                  '세금계산서 정보',
                  style: TextStyle(
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  '세금계산서(또는 현금영수증) 발급 정보 (선택)',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  '아래 정보를 미리 입력하면 간편하게 발급 받을 수 있어요.',
                  style: TextStyle(
                    fontSize: AppSizes.fontM,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 세금계산서/현금영수증 탭
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeTab('taxInvoice', '세금계산서'),
                    ),
                    const SizedBox(width: AppSizes.paddingS),
                    Expanded(
                      child: _buildTypeTab('cashReceipt', '현금영수증'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXL),
                // 입력 필드들
                _buildTextField(
                  label: '사업자 등록번호',
                  controller: _businessRegistrationNumberController,
                  hint: '\'-\' 없이 숫자만 입력해 주세요',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: AppSizes.paddingL),
                _buildTextField(
                  label: '상호명',
                  controller: _companyNameController,
                  hint: '상호명을 입력해 주세요',
                ),
                const SizedBox(height: AppSizes.paddingL),
                _buildTextField(
                  label: '대표자명',
                  controller: _representativeNameController,
                  hint: '대표자명을 입력해 주세요',
                ),
                const SizedBox(height: AppSizes.paddingL),
                _buildTextField(
                  label: '기본 이메일 (필수)',
                  controller: _taxInvoiceEmailController,
                  hint: '이메일 주소를 입력해 주세요',
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                  helperText: '입력한 이메일로 세금계산서를 보내드립니다.',
                ),
                const SizedBox(height: AppSizes.paddingL),
                _buildTextField(
                  label: '추가 이메일 (선택)',
                  controller: _additionalTaxInvoiceEmailController,
                  hint: '이메일 주소를 입력해 주세요',
                  keyboardType: TextInputType.emailAddress,
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

  /// 타입 탭 빌더
  Widget _buildTypeTab(String type, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSizes.paddingXS),
              Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 텍스트 필드 빌더
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: AppSizes.paddingXS),
              const Text(
                '(필수)',
                style: TextStyle(
                  fontSize: AppSizes.fontS,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            helperText,
            style: TextStyle(
              fontSize: AppSizes.fontS,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.paddingS),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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

  /// 저장하기 핸들러
  void _handleSave() {
    // 기본 이메일 필수 검증
    if (_taxInvoiceEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('기본 이메일을 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 이메일 형식 검증
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_taxInvoiceEmailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 이메일 형식을 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 추가 이메일이 입력된 경우 형식 검증
    if (_additionalTaxInvoiceEmailController.text.trim().isNotEmpty) {
      if (!emailRegex.hasMatch(_additionalTaxInvoiceEmailController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('올바른 추가 이메일 형식을 입력해주세요'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    // TODO: 데이터 저장 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('저장되었습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}


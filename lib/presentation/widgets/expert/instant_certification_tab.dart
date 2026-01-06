import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:law_decode/presentation/blocs/expert_certification/expert_certification_bloc.dart';
import 'package:law_decode/presentation/blocs/expert_certification/expert_certification_state.dart';
import 'package:law_decode/core/constants/app_colors.dart';
import 'package:law_decode/core/constants/app_sizes.dart';

/// 즉시 인증 탭
class InstantCertificationTab extends StatefulWidget {
  final Function(String registrationNumber, String idNumber) onSubmit;

  const InstantCertificationTab({
    super.key,
    required this.onSubmit,
  });

  @override
  State<InstantCertificationTab> createState() =>
      _InstantCertificationTabState();
}

class _InstantCertificationTabState extends State<InstantCertificationTab> {
  final _formKey = GlobalKey<FormState>();
  final _registrationNumberController = TextEditingController();
  final _idNumberController = TextEditingController();

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _registrationNumberController.text.trim(),
        _idNumberController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpertCertificationBloc, ExpertCertificationState>(
      builder: (context, state) {
        final isSubmitting = state is CertificationSubmitting;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 안내 문구
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '대한변협 신분증의 등록번호와 발급번호를 입력하시면 즉시 인증됩니다.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 전문가 등록 번호
                Text(
                  '대한변협 신분증 등록번호',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _registrationNumberController,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    hintText: '예: 12345',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '등록번호를 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // 신분증 발급 번호
                Text(
                  '신분증 발급번호',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _idNumberController,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    hintText: '예: ABC-1234567',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '발급번호를 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // 제출 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '인증하기',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


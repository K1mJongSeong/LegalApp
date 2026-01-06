import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:law_decode/presentation/blocs/expert_certification/expert_certification_bloc.dart';
import 'package:law_decode/presentation/blocs/expert_certification/expert_certification_state.dart';
import 'package:law_decode/core/constants/app_colors.dart';
import 'package:law_decode/core/constants/app_sizes.dart';

/// 서류 인증 탭
class DocumentCertificationTab extends StatefulWidget {
  final Function(File idCardFile, File licenseFile) onSubmit;

  const DocumentCertificationTab({
    super.key,
    required this.onSubmit,
  });

  @override
  State<DocumentCertificationTab> createState() =>
      _DocumentCertificationTabState();
}

class _DocumentCertificationTabState extends State<DocumentCertificationTab> {
  File? _idCardFile;
  File? _licenseFile;
  final _imagePicker = ImagePicker();

  Future<void> _pickFile(bool isIdCard) async {
    try {
      // 이미지 선택 (갤러리 또는 카메라)
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('이미지 선택'),
          content: const Text('이미지를 선택하세요'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('카메라'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('갤러리'),
            ),
          ],
        ),
      );

      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(source: source);
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        
        // 파일 크기 확인 (8MB)
        const maxSize = 8 * 1024 * 1024;
        final fileSize = await file.length();
        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ 파일 크기는 8MB를 초과할 수 없습니다')),
            );
          }
          return;
        }

        setState(() {
          if (isIdCard) {
            _idCardFile = file;
          } else {
            _licenseFile = file;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 오류: $e')),
        );
      }
    }
  }

  void _submit() {
    if (_idCardFile == null || _licenseFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 서류를 첨부해주세요')),
      );
      return;
    }

    widget.onSubmit(_idCardFile!, _licenseFile!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpertCertificationBloc, ExpertCertificationState>(
      builder: (context, state) {
        final isSubmitting = state is CertificationSubmitting;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '변호사 신분증과 변호사 등록증 각 1장씩 업로드해주세요.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 파일 형식: jpg, jpeg, png\n• 최대 크기: 8MB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 신분증 업로드
              _buildFileUploadSection(
                title: '변호사 신분증',
                file: _idCardFile,
                onTap: () => _pickFile(true),
                isEnabled: !isSubmitting,
              ),

              const SizedBox(height: 24),

              // 등록증 업로드
              _buildFileUploadSection(
                title: '변호사 등록증',
                file: _licenseFile,
                onTap: () => _pickFile(false),
                isEnabled: !isSubmitting,
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
                          '제출하기',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileUploadSection({
    required String title,
    required File? file,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: file != null ? AppColors.primary : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: file == null
                  ? Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '파일 선택',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            file.path.split('/').last,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: isEnabled
                              ? () {
                                  setState(() {
                                    if (title.contains('신분증')) {
                                      _idCardFile = null;
                                    } else {
                                      _licenseFile = null;
                                    }
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}


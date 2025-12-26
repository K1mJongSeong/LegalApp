import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/case/case_bloc.dart';
import '../../blocs/case/case_event.dart';
import '../../blocs/case/case_state.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/category_chip.dart';

/// 사건 입력 화면
class CaseInputPage extends StatefulWidget {
  final String? category;

  const CaseInputPage({super.key, this.category});

  @override
  State<CaseInputPage> createState() => _CaseInputPageState();
}

class _CaseInputPageState extends State<CaseInputPage> {
  String? _selectedCategory;
  String _selectedUrgency = 'simple';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _categories = [
    {'id': 'labor', 'label': AppStrings.categoryLabor, 'color': AppColors.categoryLabor},
    {'id': 'tax', 'label': AppStrings.categoryTax, 'color': AppColors.categoryTax},
    {'id': 'criminal', 'label': AppStrings.categoryCriminal, 'color': AppColors.categoryCriminal},
    {'id': 'family', 'label': AppStrings.categoryFamily, 'color': AppColors.categoryFamily},
    {'id': 'real', 'label': AppStrings.categoryReal, 'color': AppColors.categoryReal},
  ];

  final List<Map<String, String>> _urgencies = [
    {'id': 'simple', 'label': AppStrings.urgencySimple},
    {'id': 'normal', 'label': AppStrings.urgencyNormal},
    {'id': 'urgent', 'label': AppStrings.urgencyUrgent},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CaseBloc, CaseState>(
      listener: (context, state) {
        if (state is CaseCreated) {
          Navigator.pushNamed(
            context,
            '${AppRoutes.experts}?urgency=$_selectedUrgency&category=$_selectedCategory',
          );
        } else if (state is CaseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.caseInput),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.mobileMaxWidth),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 선택
                      // const Text(
                      //   '어떤 분야의 문제인가요? *',
                      //   style: TextStyle(
                      //     fontSize: AppSizes.fontL,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: AppSizes.paddingM),
                      // Wrap(
                      //   spacing: AppSizes.paddingS,
                      //   runSpacing: AppSizes.paddingS,
                      //   children: _categories.map((cat) {
                      //     return CategoryChip(
                      //       label: cat['label'],
                      //       isSelected: _selectedCategory == cat['id'],
                      //       selectedColor: cat['color'],
                      //       onTap: () {
                      //         setState(() {
                      //           _selectedCategory = cat['id'];
                      //         });
                      //       },
                      //     );
                      //   }).toList(),
                      // ),
                      const SizedBox(height: AppSizes.paddingXL),
                      // 긴급도 선택
                      const Text(
                        '얼마나 급하신가요?',
                        style: TextStyle(
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Wrap(
                        spacing: AppSizes.paddingS,
                        runSpacing: AppSizes.paddingS,
                        children: _urgencies.map((urg) {
                          return CategoryChip(
                            label: urg['label']!,
                            isSelected: _selectedUrgency == urg['id'],
                            onTap: () {
                              setState(() {
                                _selectedUrgency = urg['id']!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSizes.paddingXL),
                      // 제목
                      const Text(
                        '제목 *',
                        style: TextStyle(
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: '사건의 제목을 입력해주세요',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingXL),
                      // 상세 내용
                      const Text(
                        '상세 내용 *',
                        style: TextStyle(
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: '문제 상황을 자세히 설명해주세요.\n\n예: 언제, 어디서, 어떤 일이 있었는지 등',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '상세 내용을 입력해주세요';
                          }
                          if (value.length < 10) {
                            return '최소 10자 이상 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingXXL),
                      // 버튼
                      BlocBuilder<CaseBloc, CaseState>(
                        builder: (context, state) {
                          final isLoading = state is CaseLoading;
                          return Column(
                            children: [
                              PrimaryButton(
                                text: '전문가 찾기',
                                isLoading: isLoading,
                                onPressed: _selectedCategory != null ? _handleSubmit : null,
                              ),
                              const SizedBox(height: AppSizes.paddingM),
                              PrimaryButton(
                                text: '저장 후 나중에 진행',
                                isOutlined: true,
                                isLoading: isLoading,
                                onPressed: _selectedCategory != null ? _handleSave : null,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    context.read<CaseBloc>().add(
      CaseCreateRequested(
        userId: authState.user.id,
        category: _selectedCategory!,
        urgency: _selectedUrgency,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    context.read<CaseBloc>().add(
      CaseCreateRequested(
        userId: authState.user.id,
        category: _selectedCategory!,
        urgency: _selectedUrgency,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }
}

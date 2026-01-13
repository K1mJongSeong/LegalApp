import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import 'tabs/required_info_tab.dart';
import 'tabs/highlight_info_tab.dart';

/// 전문가 프로필 관리 페이지
class ExpertProfileManagePage extends StatefulWidget {
  const ExpertProfileManagePage({super.key});

  @override
  State<ExpertProfileManagePage> createState() => _ExpertProfileManagePageState();
}

class _ExpertProfileManagePageState extends State<ExpertProfileManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('프로필 관리'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: [
            Tab(text: '필수정보*'),
            Tab(text: '강조정보'),
            Tab(text: '추가정보'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '간편 문의',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  //   decoration: BoxDecoration(
                  //     color: Colors.orange,
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: const Text(
                  //     'NEW',
                  //     style: TextStyle(
                  //       fontSize: 10,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RequiredInfoTab(),
          HighlightInfoTab(),
          Center(child: Text('추가정보 탭 준비 중')),
          Center(child: Text('간편 문의 탭 준비 중')),
        ],
      ),
    );
  }
}


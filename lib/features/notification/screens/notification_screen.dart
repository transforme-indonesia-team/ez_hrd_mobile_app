import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/data/services/notification_service.dart';
import 'package:hrd_app/features/notification/widgets/notification_category_tab.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _requestCount = 0;
  int _approvalCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCounts() async {
    try {
      final response = await NotificationService().getCountNotification();
      final records = response['original']?['records'] ?? response['records'];

      if (records != null && records is Map<String, dynamic> && mounted) {
        setState(() {
          _requestCount = records['total_request'] as int? ?? 0;
          _approvalCount = records['total_approval'] as int? ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notification counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifikasi', style: AppTextStyles.h3(colors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: colors.primaryBlue,
                unselectedLabelColor: colors.textSecondary,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: colors.primaryBlue, width: 2.5),
                  insets: const EdgeInsets.symmetric(horizontal: 0),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: AppTextStyles.body(Colors.black),
                unselectedLabelStyle: AppTextStyles.body(Colors.black),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Permintaan'),
                        if (_requestCount > 0) ...[
                          SizedBox(width: 6.w),
                          _buildBadge(_requestCount),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Persetujuan'),
                        if (_approvalCount > 0) ...[
                          SizedBox(width: 6.w),
                          _buildBadge(_approvalCount),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Container(height: 1, color: colors.divider),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NotificationCategoryTab(
            notifType: 'REQUEST',
            onCountChanged: (count) {
              if (mounted) setState(() => _requestCount = count);
            },
          ),
          NotificationCategoryTab(
            notifType: 'APPROVAL',
            onCountChanged: (count) {
              if (mounted) setState(() => _approvalCount = count);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8751A),
        borderRadius: BorderRadius.circular(10.r),
      ),
      constraints: BoxConstraints(minWidth: 18.w, minHeight: 16.h),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/notification/widgets/empty_notification_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Text(
          'Notifikasi',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
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
                  insets: EdgeInsets.symmetric(horizontal: 0),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: AppTextStyles.body(Colors.black),
                unselectedLabelStyle: AppTextStyles.body(Colors.black),
                tabs: const [
                  Tab(text: 'Semua'),
                  Tab(text: 'Permintaan'),
                  Tab(text: 'Persetujuan'),
                ],
              ),
              Container(height: 1, color: colors.divider),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          EmptyNotificationState(
            title: 'Kamu tidak mendapat notifikasi apa pun',
            subtitle: 'Jangan khawatir, notifikasi apa pun akan muncul di sini',
          ),
          EmptyNotificationState(
            title: 'Tidak ada Permintaan',
            subtitle: 'Kamu belum mengajukan permintaan apa pun',
          ),
          EmptyNotificationState(
            title: 'Tidak ada Permintaan',
            subtitle: 'Kamu tidak memiliki permintaan yang perlu disetujui',
          ),
        ],
      ),
    );
  }
}

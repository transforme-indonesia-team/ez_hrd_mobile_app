import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class KontakDaruratScreen extends StatefulWidget {
  const KontakDaruratScreen({super.key});

  @override
  State<KontakDaruratScreen> createState() => _KontakDaruratScreenState();
}

class _KontakDaruratScreenState extends State<KontakDaruratScreen> {
  bool _isLoading = true;
  List<dynamic> _kontakDarurat = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await EmployeeService().getRelation(
        relation: 'EMERGENCY',
      );

      final records = response['original']['records'] as Map<String, dynamic>?;
      debugPrint("DEBUG-API-Response: $records");
      final data = records?['employee_emergency'] as List? ?? [];

      if (mounted) {
        setState(() {
          _isLoading = false;
          _kontakDarurat = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
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
        title: Text(
          'Kontak Darurat',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_isLoading) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: _buildSkeletonLoading(colors),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: AppTextStyles.body(colors.textSecondary),
        ),
      );
    }

    if (_kontakDarurat.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada kontak darurat',
        icon: Icons.contacts_outlined,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: _buildContent(colors),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    return Column(
      children: _kontakDarurat.map((kontak) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildKontakCard(colors, kontak),
        );
      }).toList(),
    );
  }

  Widget _buildKontakCard(ThemeColors colors, Map<String, dynamic> kontak) {
    final contactName = kontak['contact_name'] ?? '-';
    final contactPhone = kontak['contact_phone'] ?? '-';
    final relationshipName = kontak['relationship_name'] ?? '-';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: colors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: colors.primaryBlue,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName,
                      style: AppTextStyles.h4(colors.textPrimary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      relationshipName,
                      style: AppTextStyles.caption(colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: colors.divider, height: 1),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 18.sp,
                color: colors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text(
                contactPhone,
                style: AppTextStyles.body(colors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading(ThemeColors colors) {
    return Column(
      children: List.generate(2, (index) => _buildSkeletonCard(colors)),
    );
  }

  Widget _buildSkeletonCard(ThemeColors colors) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider),
      ),
      child: SkeletonContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 44.w, height: 44.w, borderRadius: 8),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120.w, height: 16.h),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 80.w, height: 12.h),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SkeletonBox(width: double.infinity, height: 1),
            SizedBox(height: 16.h),
            SkeletonBox(width: 150.w, height: 14.h),
          ],
        ),
      ),
    );
  }
}

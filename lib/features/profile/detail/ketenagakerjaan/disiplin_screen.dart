import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class DisiplinScreen extends StatefulWidget {
  const DisiplinScreen({super.key});

  @override
  State<DisiplinScreen> createState() => _DisiplinScreenState();
}

class _DisiplinScreenState extends State<DisiplinScreen> {
  bool _isLoading = true;
  List<dynamic> _disciplineList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await EmployeeService().getRelation(
        relation: 'DISCIPLINE',
      );

      final records = response['original']['records'] as Map<String, dynamic>?;
      final data = records?['employee_discipline'] as List? ?? [];

      if (mounted) {
        setState(() {
          _isLoading = false;
          _disciplineList = data;
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

  String _formatDate(String? dateStr) => FormatDate.fromString(dateStr);

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
          'Daftar Disiplin',
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

    if (_disciplineList.isEmpty) {
      return const EmptyStateWidget(
        message: 'Tidak ada data disiplin',
        icon: Icons.warning_amber_outlined,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: _buildContent(colors),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    return Column(
      children: _disciplineList.map((discipline) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildDisciplineCard(colors, discipline),
        );
      }).toList(),
    );
  }

  Widget _buildDisciplineCard(
    ThemeColors colors,
    Map<String, dynamic> discipline,
  ) {
    final typeName = discipline['discipline_type_name'] ?? '-';
    final referenceNumber = discipline['reference_number_discipline'] ?? '-';
    final letterNumber = discipline['discipline_letter_number'] ?? '-';
    final startDate = _formatDate(discipline['start_date_discipline']);
    final endDate = _formatDate(discipline['end_date_discipline']);
    final remark = discipline['remark_discipline'] ?? '-';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.orange,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeName,
                      style: AppTextStyles.bodySemiBold(colors.textPrimary),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '$startDate - $endDate',
                        style: AppTextStyles.xxSmall(Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: colors.divider, height: 1),
          SizedBox(height: 16.h),
          _buildInfoRow(
            colors,
            Icons.tag_outlined,
            'No. Referensi',
            referenceNumber,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            colors,
            Icons.description_outlined,
            'No. Surat',
            letterNumber,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(colors, Icons.note_outlined, 'Keterangan', remark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeColors colors,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: colors.textSecondary),
        SizedBox(width: 8.w),
        Text('$label: ', style: AppTextStyles.small(colors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.smallMedium(colors.textPrimary),
          ),
        ),
      ],
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
                    SkeletonBox(width: 150.w, height: 14.h),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 120.w, height: 20.h, borderRadius: 4),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SkeletonBox(width: double.infinity, height: 1),
            SizedBox(height: 16.h),
            SkeletonBox(width: 220.w, height: 13.h),
            SizedBox(height: 12.h),
            SkeletonBox(width: 200.w, height: 13.h),
            SizedBox(height: 12.h),
            SkeletonBox(width: 180.w, height: 13.h),
          ],
        ),
      ),
    );
  }
}

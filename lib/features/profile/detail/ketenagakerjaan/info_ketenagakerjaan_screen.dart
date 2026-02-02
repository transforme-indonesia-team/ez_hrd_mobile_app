import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/data/services/employee_service.dart';
import 'package:shimmer/shimmer.dart';

class InfoKetenagakerjaanScreen extends StatefulWidget {
  const InfoKetenagakerjaanScreen({super.key});

  @override
  State<InfoKetenagakerjaanScreen> createState() =>
      _InfoKetenagakerjaanScreenState();
}

class _InfoKetenagakerjaanScreenState extends State<InfoKetenagakerjaanScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await EmployeeService().getRelation(
        relation: 'EMPLOYMENT',
      );

      final records = response['original']['records'] as Map<String, dynamic>?;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _data = records;
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
          'Informasi Ketenagakerjaan',
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
        child: _buildSkeletonLoading(),
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: _buildContent(colors),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    final employeeCode = _data?['employee_code'] ?? '-';
    final isActive = _data?['is_active_employee'] == true
        ? 'AKTIF'
        : 'TIDAK AKTIF';
    final jobGrade = _data?['job_grade_name'] ?? '-';
    final hireDate = _formatDate(_data?['hire_date']);
    final terminateDate = _data?['terminate_date'] != null
        ? _formatDate(_data?['terminate_date'])
        : '-';
    final worksiteName = _data?['worksite_name'] ?? '-';
    final spvName = _data?['spv_name'] ?? '-';
    final managerName = _data?['manager_location_name'] ?? '-';

    return Column(
      children: [
        _buildSectionCard(
          colors,
          title: 'Data Ketenagakerjaan',
          subtitle: 'Informasi data Anda terkait dengan perusahaan',
          childrenSpacing: 16.h,
          children: [
            _buildInfoRow(colors, 'No. Karyawan', employeeCode),
            _buildInfoRow(colors, 'Status Karyawan', isActive),
            _buildInfoRow(colors, 'Tingkat Jabatan', jobGrade),
            _buildInfoRow(colors, 'Tanggal Bergabung', hireDate),
            _buildInfoRow(colors, 'Tanggal Akhir Karyawan', terminateDate),
            _buildInfoRow(colors, 'Lokasi Kerja', worksiteName),
            _buildInfoRow(colors, 'Atasan Langsung', spvName),
            _buildInfoRow(colors, 'Manager Langsung', managerName),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildSectionCard(
    ThemeColors colors, {
    required String title,
    required String subtitle,
    required List<Widget> children,
    double? childrenSpacing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodySemiBold(colors.textPrimary)),
          SizedBox(height: 4.h),
          Text(subtitle, style: AppTextStyles.caption(colors.textPrimary)),
          SizedBox(height: 8.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: childrenSpacing ?? 0,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeColors colors,
    String label,
    String? value, {
    String? note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium(colors.textPrimary)),
        SizedBox(height: 4.h),
        Text(value ?? '-', style: AppTextStyles.body(colors.textPrimary)),
        if (note != null) ...[
          SizedBox(height: 4.h),
          Text(note, style: AppTextStyles.caption(colors.textSecondary)),
        ],
      ],
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(children: [_buildSkeletonCard(8)]);
  }

  Widget _buildSkeletonCard(int itemCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.colors.divider),
      ),
      child: Shimmer.fromColors(
        baseColor: context.colors.divider,
        highlightColor: context.colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 250.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 24.h),
            ...List.generate(itemCount, (index) => _buildSkeletonItem()),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}

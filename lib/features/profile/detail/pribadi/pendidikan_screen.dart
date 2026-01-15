import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class PendidikanScreen extends StatefulWidget {
  const PendidikanScreen({super.key});

  @override
  State<PendidikanScreen> createState() => _PendidikanScreenState();
}

class _PendidikanScreenState extends State<PendidikanScreen> {
  bool _isLoading = true;
  List<dynamic> _pendidikan = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await EmployeeService().getRelation(
        relation: 'EDUCATION',
      );

      final records = response['original']['records'] as Map<String, dynamic>?;
      final data = records?['employee_education'] as List? ?? [];

      if (mounted) {
        setState(() {
          _isLoading = false;
          _pendidikan = data;
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
          'Pendidikan',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
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
          style: GoogleFonts.inter(color: colors.textSecondary),
        ),
      );
    }

    if (_pendidikan.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada data pendidikan',
        icon: Icons.school_outlined,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: _buildContent(colors),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    return Column(
      children: _pendidikan.map((edu) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildPendidikanCard(colors, edu),
        );
      }).toList(),
    );
  }

  Widget _buildPendidikanCard(ThemeColors colors, Map<String, dynamic> edu) {
    final institutionName = edu['education_institution_name'] ?? '-';
    final levelName = edu['education_level_name'] ?? '-';
    final majorName = edu['education_major_name'] ?? '-';
    final startYear = edu['start_education']?.toString() ?? '-';
    final endYear = edu['end_education']?.toString() ?? '-';

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
                  color: colors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.school_outlined,
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
                      institutionName,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      levelName,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: colors.primaryBlue,
                        fontWeight: FontWeight.w500,
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
          _buildInfoRow(colors, Icons.book_outlined, 'Jurusan', majorName),
          SizedBox(height: 12.h),
          _buildInfoRow(
            colors,
            Icons.calendar_today_outlined,
            'Periode',
            '$startYear - $endYear',
          ),
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
      children: [
        Icon(icon, size: 16.sp, color: colors.textSecondary),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: colors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
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
                    SkeletonBox(width: 180.w, height: 14.h),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 100.w, height: 12.h),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SkeletonBox(width: double.infinity, height: 1),
            SizedBox(height: 16.h),
            SkeletonBox(width: 200.w, height: 13.h),
            SizedBox(height: 12.h),
            SkeletonBox(width: 150.w, height: 13.h),
          ],
        ),
      ),
    );
  }
}

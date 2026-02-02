import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class DataAsuransiScreen extends StatefulWidget {
  const DataAsuransiScreen({super.key});

  @override
  State<DataAsuransiScreen> createState() => _DataAsuransiScreenState();
}

class _DataAsuransiScreenState extends State<DataAsuransiScreen> {
  bool _isLoading = true;
  List<dynamic> _insuranceList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await EmployeeService().getRelation(
        relation: 'INSURANCE',
      );

      final records = response['original']['records'] as Map<String, dynamic>?;
      final data = records?['employee_insurance'] as List? ?? [];

      if (mounted) {
        setState(() {
          _isLoading = false;
          _insuranceList = data;
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
          'Data Asuransi',
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

    if (_insuranceList.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada data asuransi',
        icon: Icons.health_and_safety_outlined,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: _buildContent(colors),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    return Column(
      children: _insuranceList.map((insurance) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildInsuranceCard(colors, insurance),
        );
      }).toList(),
    );
  }

  Widget _buildInsuranceCard(
    ThemeColors colors,
    Map<String, dynamic> insurance,
  ) {
    final insuranceName = insurance['insurance_name'] ?? '-';
    final branchName = insurance['branch_name'] ?? '-';
    final branchCode = insurance['branch_code'] ?? '-';
    final branchAccount = insurance['branch_account'] ?? '-';
    final branchAddress = insurance['branch_address'] ?? '-';
    final insuranceDate = _formatDate(insurance['insurance_date']);

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
                  Icons.health_and_safety_outlined,
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
                      insuranceName,
                      style: AppTextStyles.bodySemiBold(colors.textPrimary),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      branchName,
                      style: AppTextStyles.caption(colors.primaryBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: colors.divider, height: 1),
          SizedBox(height: 16.h),
          _buildInfoRow(colors, Icons.tag_outlined, 'Kode Cabang', branchCode),
          SizedBox(height: 12.h),
          _buildInfoRow(
            colors,
            Icons.credit_card_outlined,
            'No. Akun',
            branchAccount,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            colors,
            Icons.location_on_outlined,
            'Alamat',
            branchAddress,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            colors,
            Icons.calendar_today_outlined,
            'Tanggal Asuransi',
            insuranceDate,
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
                    SkeletonBox(width: 120.w, height: 12.h),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SkeletonBox(width: double.infinity, height: 1),
            SizedBox(height: 16.h),
            SkeletonBox(width: 200.w, height: 13.h),
            SizedBox(height: 12.h),
            SkeletonBox(width: 180.w, height: 13.h),
            SizedBox(height: 12.h),
            SkeletonBox(width: 220.w, height: 13.h),
            SizedBox(height: 12.h),
            SkeletonBox(width: 160.w, height: 13.h),
          ],
        ),
      ),
    );
  }
}

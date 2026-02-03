import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/models/employee_leave_balance_model.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class JatahCutiScreen extends StatefulWidget {
  const JatahCutiScreen({super.key});

  @override
  State<JatahCutiScreen> createState() => _JatahCutiScreenState();
}

class _JatahCutiScreenState extends State<JatahCutiScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<EmployeeLeaveBalanceModel> _leaveBalances = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EmployeeService().getRelation(relation: 'LEAVE');
      final records = response['original']?['records'] as Map<String, dynamic>?;

      if (records != null) {
        final employeeLeave = records['employee_leave'] as List<dynamic>? ?? [];
        _leaveBalances = employeeLeave
            .map(
              (e) =>
                  EmployeeLeaveBalanceModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching leave balance: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data jatah cuti';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Jatah Cuti', style: AppTextStyles.h3(colors.textPrimary)),
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_isLoading) {
      return _buildSkeletonList(colors);
    }

    if (_errorMessage != null) {
      return EmptyStateWidget(
        message: _errorMessage!,
        icon: Icons.error_outline,
        onRetry: _fetchData,
      );
    }

    if (_leaveBalances.isEmpty) {
      return const EmptyStateWidget(
        message: 'Tidak ada data jatah cuti',
        icon: Icons.event_busy_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: colors.primaryBlue,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _leaveBalances.length,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          return _LeaveBalanceCard(leaveBalance: _leaveBalances[index]);
        },
      ),
    );
  }

  Widget _buildSkeletonList(ThemeColors colors) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (_, __) => _buildSkeletonCard(colors),
    );
  }

  Widget _buildSkeletonCard(ThemeColors colors) {
    return SkeletonContainer(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonText(width: 120.w, height: 16.h),
                SkeletonText(width: 60.w, height: 16.h),
              ],
            ),
            SizedBox(height: 12.h),
            SkeletonBox(width: double.infinity, height: 8.h, borderRadius: 4),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonText(width: 20.w, height: 14.h),
                SkeletonText(width: 150.w, height: 14.h),
                SkeletonText(width: 20.w, height: 14.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget untuk menampilkan saldo cuti
class _LeaveBalanceCard extends StatelessWidget {
  final EmployeeLeaveBalanceModel leaveBalance;

  const _LeaveBalanceCard({required this.leaveBalance});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Calculate progress (remaining / total)
    final total = leaveBalance.countEmployeeLeave?.toDouble() ?? 0;
    final remaining = leaveBalance.remainingLeave?.toDouble() ?? 0;
    final used = total - remaining;
    // Progress shows remaining (full = all remaining, empty = all used)
    final progress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    // Format leave type name: "ANNUAL LEAVES" -> "Annual Leaves"
    final leaveTypeName = _formatLeaveTypeName(leaveBalance.leaveTypeName);

    // Format date range
    final dateRange = FormatDate.dateRangeFromString(
      leaveBalance.startValidDateLeave,
      leaveBalance.endValidDateLeave,
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Leave type name & total days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  leaveTypeName,
                  style: AppTextStyles.bodySemiBold(colors.textPrimary),
                ),
              ),
              Text(
                '${leaveBalance.displayCountEmployeeLeave} Hari',
                style: AppTextStyles.bodySemiBold(colors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primaryBlue),
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 12.h),

          // Footer: Used, date range, remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                used.toInt().toString(),
                style: AppTextStyles.body(colors.textSecondary),
              ),
              Expanded(
                child: Text(
                  dateRange,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ),
              Text(
                leaveBalance.displayRemainingLeave,
                style: AppTextStyles.body(colors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format leave type name from "ANNUAL LEAVES" to "Annual Leaves"
  String _formatLeaveTypeName(String? name) {
    if (name == null || name.isEmpty) return '-';
    return name
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }
}

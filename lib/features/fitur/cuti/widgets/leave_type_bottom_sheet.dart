import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/employee_leave_balance_model.dart';

class LeaveTypeBottomSheet extends StatefulWidget {
  final List<EmployeeLeaveBalanceModel> types;
  final EmployeeLeaveBalanceModel? selectedType;
  final ValueChanged<EmployeeLeaveBalanceModel> onSelected;
  final bool isLoading;

  const LeaveTypeBottomSheet({
    super.key,
    required this.types,
    this.selectedType,
    required this.onSelected,
    this.isLoading = false,
  });

  static Future<EmployeeLeaveBalanceModel?> show(
    BuildContext context, {
    required List<EmployeeLeaveBalanceModel> types,
    EmployeeLeaveBalanceModel? selectedType,
    bool isLoading = false,
  }) {
    return showModalBottomSheet<EmployeeLeaveBalanceModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LeaveTypeBottomSheet(
        types: types,
        selectedType: selectedType,
        isLoading: isLoading,
        onSelected: (type) => Navigator.pop(context, type),
      ),
    );
  }

  @override
  State<LeaveTypeBottomSheet> createState() => _LeaveTypeBottomSheetState();
}

class _LeaveTypeBottomSheetState extends State<LeaveTypeBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<EmployeeLeaveBalanceModel> _filteredTypes = [];

  @override
  void initState() {
    super.initState();
    _filteredTypes = widget.types;
  }

  @override
  void didUpdateWidget(covariant LeaveTypeBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered types if the source types changed
    if (widget.types != oldWidget.types) {
      _filterTypes(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTypes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTypes = widget.types;
      } else {
        _filteredTypes = widget.types
            .where(
              (type) => type.displayLeaveTypeName.toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text('Jenis Cuti', style: AppTextStyles.h4(colors.textPrimary)),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTypes,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: AppTextStyles.body(colors.textSecondary),
                prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: colors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: colors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: colors.primaryBlue),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, color: colors.divider),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 400.h, // Tinggi minimum
              maxHeight: 500.h, // Tinggi maksimum
            ),
            child: _buildContent(colors),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    // Tampilkan loading jika masih memuat
    if (widget.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(
                'Memuat jenis cuti...',
                style: AppTextStyles.body(colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan empty state jika tidak ada data
    if (_filteredTypes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 48.sp,
                color: colors.textSecondary,
              ),
              SizedBox(height: 12.h),
              Text(
                widget.types.isEmpty
                    ? 'Tidak ada jenis cuti tersedia'
                    : 'Tidak ada hasil ditemukan',
                style: AppTextStyles.body(colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan list jenis cuti
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: _filteredTypes.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: colors.divider),
      itemBuilder: (context, index) {
        final type = _filteredTypes[index];
        final isSelected = widget.selectedType?.id == type.id;

        return ListTile(
          title: Text(
            type.displayLeaveTypeName,
            style: AppTextStyles.body(
              isSelected ? colors.primaryBlue : colors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Sisa: ${type.displayRemainingLeave} hari',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.primaryBlue,
                  size: 18.sp,
                ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right,
                color: colors.textSecondary,
                size: 20.sp,
              ),
            ],
          ),
          onTap: () => widget.onSelected(type),
        );
      },
    );
  }
}

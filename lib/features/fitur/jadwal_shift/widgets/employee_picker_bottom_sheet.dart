import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/utils/string_utils.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class EmployeeMemberItem {
  final String value;
  final String label;
  final String? positionName;

  const EmployeeMemberItem({
    required this.value,
    required this.label,
    this.positionName,
  });

  factory EmployeeMemberItem.fromJson(Map<String, dynamic> json) {
    final other = json['other'] as Map<String, dynamic>?;
    return EmployeeMemberItem(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      positionName: other?['position_organization_name']?.toString(),
    );
  }
}

class EmployeePickerBottomSheet extends StatefulWidget {
  final List<EmployeeMemberItem> selectedEmployees;
  final String? employeeId;

  const EmployeePickerBottomSheet({
    super.key,
    this.selectedEmployees = const [],
    this.employeeId,
  });

  static Future<List<EmployeeMemberItem>?> show(
    BuildContext context, {
    List<EmployeeMemberItem> selectedEmployees = const [],
    String? employeeId,
  }) {
    return showModalBottomSheet<List<EmployeeMemberItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmployeePickerBottomSheet(
        selectedEmployees: selectedEmployees,
        employeeId: employeeId,
      ),
    );
  }

  @override
  State<EmployeePickerBottomSheet> createState() =>
      _EmployeePickerBottomSheetState();
}

class _EmployeePickerBottomSheetState extends State<EmployeePickerBottomSheet> {
  final _searchController = TextEditingController();
  List<EmployeeMemberItem> _allEmployees = [];
  List<EmployeeMemberItem> _selected = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedEmployees);
    _fetchEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    try {
      final response = await EmployeeService().getMember(
        employeeId: widget.employeeId,
      );

      List<dynamic>? recordsRaw;
      if (response['original'] != null) {
        recordsRaw = response['original']['records'] as List<dynamic>?;
      } else {
        recordsRaw = response['records'] as List<dynamic>?;
      }

      if (recordsRaw != null) {
        setState(() {
          _allEmployees = recordsRaw!
              .map(
                (e) => EmployeeMemberItem.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('EmployeePicker: Error fetching members: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackbar('Gagal memuat daftar karyawan');
      }
    }
  }

  List<EmployeeMemberItem> get _availableEmployees {
    final selectedIds = _selected.map((e) => e.value).toSet();
    var available = _allEmployees
        .where((e) => !selectedIds.contains(e.value))
        .toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      available = available
          .where(
            (e) =>
                e.label.toLowerCase().contains(query) ||
                (e.positionName?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return available;
  }

  void _toggleSelect(EmployeeMemberItem employee) {
    setState(() {
      _selected.add(employee);
    });
  }

  void _removeSelected(EmployeeMemberItem employee) {
    setState(() {
      _selected.removeWhere((e) => e.value == employee.value);
    });
  }

  void _moveAll() {
    setState(() {
      _selected.addAll(_availableEmployees);
    });
  }

  void _clearAll() {
    setState(() {
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final available = _availableEmployees;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Daftar Karyawan',
                    style: AppTextStyles.h3(colors.textPrimary),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: [
                          // Selected section
                          if (_selected.isNotEmpty) ...[
                            _buildSelectedSection(colors),
                            SizedBox(height: 16.h),
                          ],

                          // Search bar
                          _buildSearchBar(colors),
                          SizedBox(height: 16.h),

                          // Available section header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Karyawan yang dapat Dipilih',
                                style: AppTextStyles.bodyMedium(
                                  colors.textPrimary,
                                ),
                              ),
                              if (available.isNotEmpty)
                                GestureDetector(
                                  onTap: _moveAll,
                                  child: Text(
                                    'Pindahkan Semua',
                                    style: AppTextStyles.bodyMedium(
                                      colors.primaryBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Available list
                          if (available.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.h),
                              child: Center(
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ditemukan'
                                      : 'Semua karyawan sudah dipilih',
                                  style: AppTextStyles.body(
                                    colors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...available.map(
                              (emp) => _buildEmployeeRow(
                                emp,
                                colors,
                                onTap: () => _toggleSelect(emp),
                              ),
                            ),

                          SizedBox(height: 80.h),
                        ],
                      ),
              ),

              // Bottom button
              Container(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  12.h,
                  16.w,
                  MediaQuery.of(context).padding.bottom + 12.h,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected.isNotEmpty
                        ? () => Navigator.pop(context, _selected)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: colors.divider,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: Text(
                      'Tambahkan Yang Dipilih',
                      style: AppTextStyles.button(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedSection(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium(colors.textPrimary),
                children: [
                  const TextSpan(text: 'Total '),
                  TextSpan(
                    text: '${_selected.length}',
                    style: AppTextStyles.bodyMedium(colors.primaryBlue),
                  ),
                  const TextSpan(text: ' Terpilih'),
                ],
              ),
            ),
            GestureDetector(
              onTap: _clearAll,
              child: Text(
                'Bersihkan semua',
                style: AppTextStyles.bodyMedium(colors.textPrimary),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _selected.map((emp) {
            final initials = StringUtils.getInitials(emp.label);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: ColorPalette.slate100,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14.r,
                    backgroundColor: ColorPalette.slate200,
                    child: Text(
                      initials,
                      style: AppTextStyles.xxSmall(ColorPalette.slate500),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    emp.label,
                    style: AppTextStyles.small(colors.textPrimary),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () => _removeSelected(emp),
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeColors colors) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42.h,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: colors.divider),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: AppTextStyles.body(colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari',
                hintStyle: AppTextStyles.body(colors.textSecondary),
                prefixIcon: Icon(
                  Icons.search,
                  color: colors.textSecondary,
                  size: 20.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          height: 42.h,
          width: 42.h,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: colors.divider),
          ),
          child: Icon(
            Icons.filter_alt_outlined,
            color: colors.textSecondary,
            size: 20.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeRow(
    EmployeeMemberItem employee,
    ThemeColors colors, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            UserAvatar(name: employee.label, size: 36),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.label,
                    style: AppTextStyles.bodyMedium(colors.textPrimary),
                  ),
                  if (employee.positionName != null)
                    Text(
                      '${employee.value.length >= 8 ? employee.value.substring(0, 8).toUpperCase() : employee.value} - ${employee.positionName}',
                      style: AppTextStyles.caption(colors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

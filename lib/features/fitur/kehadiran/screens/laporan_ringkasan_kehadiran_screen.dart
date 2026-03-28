import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/rentang_tanggal_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/multi_select_employee_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/download_options_bottom_sheet.dart';

class LaporanRingkasanKehadiranScreen extends StatefulWidget {
  const LaporanRingkasanKehadiranScreen({super.key});

  @override
  State<LaporanRingkasanKehadiranScreen> createState() =>
      _LaporanRingkasanKehadiranScreenState();
}

class _LaporanRingkasanKehadiranScreenState
    extends State<LaporanRingkasanKehadiranScreen> {
  DateTimeRange? _selectedDateRange;
  List<MemberData> _selectedEmployees = [];
  String? _selectedStatus;
  bool _showStatusDetails = false;

  final List<String> _statusOptions = [
    'Semua',
    'Hadir',
    'Terlambat',
    'Pulang Cepat',
    'Izin',
    'Sakit',
    'Cuti',
    'Alpa',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(
        now.year,
        now.month,
        DateUtils.getDaysInMonth(now.year, now.month),
      ),
    );
  }

  void _showEmployeeSelector() async {
    final result = await MultiSelectEmployeeBottomSheet.show(
      context,
      initialSelectedItems: _selectedEmployees,
    );
    if (result != null) {
      setState(() {
        _selectedEmployees = result;
      });
    }
  }

  void _showRentangTanggalSheet() async {
    final result = await RentangTanggalBottomSheet.show(
      context,
      initialStartDate: _selectedDateRange?.start,
      initialEndDate: _selectedDateRange?.end,
    );
    if (result != null) {
      setState(() {
        _selectedDateRange = result;
      });
    }
  }

  void _showStatusBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = context.colors;
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Status', style: AppTextStyles.h4(colors.textPrimary)),
              SizedBox(height: 16.h),
              Divider(height: 1, color: colors.divider),
              ..._statusOptions.map(
                (status) => InkWell(
                  onTap: () {
                    setState(() => _selectedStatus = status);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 20.w,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: colors.divider),
                      ),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.body(colors.textPrimary),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  String _formatDateRange() {
    if (_selectedDateRange == null) return 'Pilih Rentang Tanggal';
    final startStr = FormatDate.shortDateWithYear(_selectedDateRange!.start);
    final endStr = FormatDate.shortDateWithYear(_selectedDateRange!.end);
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.backgroundDetail,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Laporan Ringkasan Kehadiran',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(colors, 'Karyawan'),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: _showEmployeeSelector,
              child: _buildTextField(
                colors,
                hint: _selectedEmployees.isEmpty
                    ? 'Pilih Karyawan'
                    : '${_selectedEmployees.length} Terpilih',
                suffixIcon: Icons.people_outline,
              ),
            ),
            SizedBox(height: 12.h),

            _buildLabel(colors, 'Status'),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: _showStatusBottomSheet,
              child: _buildTextField(
                colors,
                hint: _selectedStatus ?? 'Pilih Status',
                suffixIcon: Icons.keyboard_arrow_down,
              ),
            ),
            SizedBox(height: 12.h),

            _buildCheckbox(
              colors,
              label: 'Tampilkan Detil Status',
              value: _showStatusDetails,
              onChanged: (val) {
                setState(() {
                  _showStatusDetails = val ?? false;
                });
              },
            ),
            SizedBox(height: 12.h),

            _buildLabel(colors, 'Rentang Tanggal'),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: _showRentangTanggalSheet,
              child: _buildTextField(
                colors,
                hint: _formatDateRange(),
                suffixIcon: Icons.calendar_today_outlined,
              ),
            ),
            SizedBox(height: 24.h),

            _buildDownloadButton(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeColors colors, String text) {
    return Text(text, style: AppTextStyles.smallMedium(colors.textSecondary));
  }

  Widget _buildTextField(
    ThemeColors colors, {
    required String hint,
    required IconData suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: AppTextStyles.small(colors.textSecondary)),
          Icon(suffixIcon, color: colors.textSecondary, size: 18.sp),
        ],
      ),
    );
  }

  Widget _buildCheckbox(
    ThemeColors colors, {
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20.w,
          height: 20.w,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primaryBlue,
            side: BorderSide(
              color: colors.textSecondary.withValues(alpha: 0.5),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(label, style: AppTextStyles.small(colors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildDownloadButton(ThemeColors colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors.buttonGradient),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: colors.buttonBlue.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final option = await DownloadOptionsBottomSheet.show(
              context,
              options: const [
                DownloadOption.pdf,
                DownloadOption.excel,
                DownloadOption.email,
                DownloadOption.viewDirectly,
              ],
            );
            if (option != null && context.mounted) {
              // TODO: Implement specific option
            }
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unduh', style: AppTextStyles.button(Colors.white)),
                SizedBox(width: 8.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

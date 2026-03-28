import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/rentang_tanggal_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/multi_select_employee_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/download_options_bottom_sheet.dart';

class LaporanKehadiranYangDicurigaiScreen extends StatefulWidget {
  const LaporanKehadiranYangDicurigaiScreen({super.key});

  @override
  State<LaporanKehadiranYangDicurigaiScreen> createState() =>
      _LaporanKehadiranYangDicurigaiScreenState();
}

class _LaporanKehadiranYangDicurigaiScreenState
    extends State<LaporanKehadiranYangDicurigaiScreen> {
  DateTimeRange? _selectedDateRange;
  List<MemberData> _selectedEmployees = [];
  String? _selectedLokasi;

  final List<String> _lokasiOptions = [
    'Semua',
    'Kantor Pusat',
    'Kantor Cabang',
    'Remote / WFH',
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

  void _showLokasiBottomSheet() {
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
              Text(
                'Pilih Lokasi Kehadiran',
                style: AppTextStyles.h4(colors.textPrimary),
              ),
              SizedBox(height: 16.h),
              Divider(height: 1, color: colors.divider),
              ..._lokasiOptions.map(
                (lokasi) => InkWell(
                  onTap: () {
                    setState(() => _selectedLokasi = lokasi);
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
                      lokasi,
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
          'Laporan Kehadiran yang Dicurigai',
          style: AppTextStyles.h4(colors.textPrimary), // make it h4 since title is long
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

            _buildLabel(colors, 'Lokasi Kehadiran'),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: _showLokasiBottomSheet,
              child: _buildTextField(
                colors,
                hint: _selectedLokasi ?? 'Pilih Lokasi Kehadiran',
                suffixIcon: Icons.keyboard_arrow_down,
              ),
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
            SizedBox(height: 32.h),

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
          Expanded(
            child: Text(
              hint,
              style: AppTextStyles.small(colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(suffixIcon, color: colors.textSecondary, size: 18.sp),
        ],
      ),
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

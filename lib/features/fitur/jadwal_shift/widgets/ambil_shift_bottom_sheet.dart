import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/services/option_service.dart';

class AmbilShiftBottomSheet extends StatefulWidget {
  const AmbilShiftBottomSheet({super.key});

  /// Show and return selected shift map: {value, label, other}
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AmbilShiftBottomSheet(),
    );
  }

  @override
  State<AmbilShiftBottomSheet> createState() => _AmbilShiftBottomSheetState();
}

class _AmbilShiftBottomSheetState extends State<AmbilShiftBottomSheet> {
  bool _quickApply = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _allShifts = [];
  List<Map<String, dynamic>> _filteredShifts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShifts() async {
    setState(() => _isLoading = true);
    try {
      final response = await OptionService().getShiftDaily();
      final records = response['original']?['records'] ?? response['records'];
      if (records is List && mounted) {
        setState(() {
          _allShifts = records.map((e) => e as Map<String, dynamic>).toList();
          _filteredShifts = _allShifts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredShifts = _allShifts;
      } else {
        _filteredShifts = _allShifts.where((shift) {
          final label = (shift['label'] as String? ?? '').toLowerCase();
          final other = shift['other'] as Map<String, dynamic>?;
          final remark = (other?['remark_shift_daily'] as String? ?? '')
              .toLowerCase();
          return label.contains(query) || remark.contains(query);
        }).toList();
      }
    });
  }

  String _getTimeDisplay(Map<String, dynamic> shift) {
    final other = shift['other'] as Map<String, dynamic>?;
    if (other != null) {
      final start = other['start_time_shift'] as String?;
      final end = other['end_time_shift'] as String?;
      if (start != null && end != null) {
        return '$start - $end';
      }
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
              child: Text(
                'Ambil Shift',
                style: AppTextStyles.h3(colors.textPrimary),
              ),
            ),

            // Switch: Pilih Satu / Cepat Terapkan Shift
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Satu',
                            style: AppTextStyles.bodyMedium(colors.textPrimary),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Cepat Terapkan Shift',
                            style: AppTextStyles.caption(colors.primaryBlue),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _quickApply,
                      onChanged: (value) {
                        setState(() => _quickApply = value);
                        if (value && _allShifts.isEmpty) {
                          _loadShifts();
                        }
                      },
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Content: search + shift list (only when switch ON)
            if (_quickApply) ...[
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari',
                    hintStyle: AppTextStyles.body(
                      colors.textSecondary,
                      fontSize: 14.sp,
                    ),
                    suffixIcon: Icon(
                      Icons.search,
                      color: colors.textSecondary,
                      size: 20.sp,
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                  ),
                  style: AppTextStyles.body(
                    colors.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Shift list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredShifts.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada shift ditemukan',
                          style: AppTextStyles.body(colors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        itemCount: _filteredShifts.length,
                        itemBuilder: (ctx, i) =>
                            _buildShiftCard(_filteredShifts[i], colors),
                      ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(Map<String, dynamic> shift, ThemeColors colors) {
    final label = shift['label'] as String? ?? '';
    final timeDisplay = _getTimeDisplay(shift);
    final other = shift['other'] as Map<String, dynamic>?;
    final remark = other?['remark_shift_daily'] as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Shift
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Shift   ',
                style: AppTextStyles.bodyMedium(colors.textPrimary),
              ),
              Expanded(
                child: Text(
                  remark ?? label,
                  style: AppTextStyles.body(colors.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Waktu
          Row(
            children: [
              Text(
                'Waktu   ',
                style: AppTextStyles.bodyMedium(colors.textPrimary),
              ),
              Text(
                timeDisplay,
                style: AppTextStyles.body(colors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Pilih button
          GestureDetector(
            onTap: () => Navigator.pop(context, shift),
            child: Text(
              'Pilih',
              style: AppTextStyles.bodyMedium(colors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

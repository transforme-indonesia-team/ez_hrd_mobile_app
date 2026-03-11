import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/services/option_service.dart';

class ShiftPickerBottomSheet extends StatefulWidget {
  final String? selectedShiftId;

  const ShiftPickerBottomSheet({super.key, this.selectedShiftId});

  /// Show and return selected shift map: {value, label, other}
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String? selectedShiftId,
  }) {
    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShiftPickerBottomSheet(selectedShiftId: selectedShiftId),
    );
  }

  @override
  State<ShiftPickerBottomSheet> createState() => _ShiftPickerBottomSheetState();
}

class _ShiftPickerBottomSheetState extends State<ShiftPickerBottomSheet> {
  List<Map<String, dynamic>> _allShifts = [];
  List<Map<String, dynamic>> _filteredShifts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShifts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShifts() async {
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
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

            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
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
                style: AppTextStyles.body(colors.textPrimary, fontSize: 14.sp),
              ),
            ),

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
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: bottomPadding + 8.h,
                      ),
                      itemCount: _filteredShifts.length,
                      itemBuilder: (ctx, i) =>
                          _buildShiftItem(_filteredShifts[i], colors),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftItem(Map<String, dynamic> shift, ThemeColors colors) {
    final label = shift['label'] as String? ?? '';
    final timeDisplay = _getTimeDisplay(shift);
    final other = shift['other'] as Map<String, dynamic>?;
    final remark = other?['remark_shift_daily'] as String?;

    return InkWell(
      onTap: () => Navigator.pop(context, shift),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 2.w),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.grey.shade300, width: 1),
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium(
                        colors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (remark != null && remark.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Text(
                        remark,
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                timeDisplay,
                style: AppTextStyles.body(
                  colors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

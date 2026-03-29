import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

class BuatSaranBottomSheet extends StatefulWidget {
  const BuatSaranBottomSheet({super.key});

  @override
  State<BuatSaranBottomSheet> createState() => _BuatSaranBottomSheetState();
}

class _BuatSaranBottomSheetState extends State<BuatSaranBottomSheet> {
  final TextEditingController _keteranganController = TextEditingController();
  String? _selectedKaryawan;
  String _tipeSaran = 'Pujian';
  String _tingkatKeparahan = 'Minor';

  final List<String> _tipeOptions = ['Pujian', 'Kritik', 'Keluhan', 'Saran'];
  final List<String> _keparahanOptions = ['Minor', 'Sedang', 'Mayor', 'Kritis'];

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  void _showDropdown(
    ThemeColors colors,
    List<String> options,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  final isSelected = item == currentValue;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(item);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: 20.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: colors.divider)),
                        color: isSelected
                            ? colors.primaryBlue.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        item,
                        style: isSelected
                            ? AppTextStyles.bodyMedium(colors.primaryBlue)
                            : AppTextStyles.body(colors.textPrimary),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(ThemeColors colors, String text, {bool isRequired = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: RichText(
        text: TextSpan(
          text: text,
          style: AppTextStyles.smallMedium(colors.textSecondary).copyWith(fontSize: 13.sp),
          children: isRequired
              ? [TextSpan(text: ' *', style: AppTextStyles.smallMedium(colors.error).copyWith(fontSize: 13.sp))]
              : [],
        ),
      ),
    );
  }

  Widget _buildFieldContainer(
    ThemeColors colors, {
    required String text,
    IconData? iconData,
    bool isPlaceholder = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isPlaceholder
                  ? AppTextStyles.body(colors.textSecondary)
                  : AppTextStyles.body(colors.textPrimary),
            ),
          ),
          if (iconData != null) ...[
            SizedBox(width: 8.w),
            Icon(iconData, color: colors.textSecondary, size: 22.sp),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 12.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    'Buat Saran',
                    style: AppTextStyles.bodyLarge(colors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 18.sp),
                  ),
                ),
                SizedBox(height: 24.h),

                // Ke field
                _buildLabel(colors, 'Ke', isRequired: true),
                GestureDetector(
                  onTap: () {
                    // Show Employee selection bottom sheet (e.g. SearchMemberBottomSheet)
                  },
                  child: _buildFieldContainer(
                    colors,
                    text: _selectedKaryawan ?? 'Pilih Karyawan',
                    iconData: Icons.people_outline,
                    isPlaceholder: _selectedKaryawan == null,
                  ),
                ),
                SizedBox(height: 16.h),

                // Tipe field
                _buildLabel(colors, 'Tipe', isRequired: true),
                GestureDetector(
                  onTap: () {
                    _showDropdown(colors, _tipeOptions, _tipeSaran, (val) {
                      setState(() {
                        _tipeSaran = val;
                      });
                    });
                  },
                  child: _buildFieldContainer(
                    colors,
                    text: _tipeSaran,
                    iconData: Icons.keyboard_arrow_down,
                    isPlaceholder: false,
                  ),
                ),
                SizedBox(height: 16.h),

                // Tingkat Keparahan field
                _buildLabel(colors, 'Tingkat Keparahan', isRequired: true),
                GestureDetector(
                  onTap: () {
                    _showDropdown(colors, _keparahanOptions, _tingkatKeparahan, (val) {
                      setState(() {
                        _tingkatKeparahan = val;
                      });
                    });
                  },
                  child: _buildFieldContainer(
                    colors,
                    text: _tingkatKeparahan,
                    iconData: Icons.keyboard_arrow_down,
                    isPlaceholder: false,
                  ),
                ),
                SizedBox(height: 16.h),

                // Keterangan field
                _buildLabel(colors, 'Keterangan', isRequired: true),
                TextField(
                  controller: _keteranganController,
                  maxLines: 4,
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Keterangan',
                    hintStyle: AppTextStyles.body(colors.textSecondary),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: colors.primaryBlue),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Handle Submit Saran
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Ajukan',
                      style: AppTextStyles.button(Colors.white).copyWith(fontSize: 15.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

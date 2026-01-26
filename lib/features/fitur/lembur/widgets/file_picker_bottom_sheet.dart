import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

enum FilePickerType { camera, gallery, file }

class FilePickerBottomSheet extends StatelessWidget {
  final ValueChanged<FilePickerType> onSelected;

  const FilePickerBottomSheet({super.key, required this.onSelected});

  static Future<FilePickerType?> show(BuildContext context) {
    return showModalBottomSheet<FilePickerType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilePickerBottomSheet(
        onSelected: (type) => Navigator.pop(context, type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            // Handle bar
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            SizedBox(height: 20.h),
            // Title
            Text('Pilih Sumber', style: AppTextStyles.h3(colors.textPrimary)),
            SizedBox(height: 6.h),
            Text(
              'Pilih sumber file yang ingin dilampirkan',
              style: AppTextStyles.body(colors.textSecondary),
            ),
            SizedBox(height: 24.h),
            // Options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionCard(
                    colors,
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    subtitle: 'Ambil foto',
                    gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    onTap: () => onSelected(FilePickerType.camera),
                  ),
                  SizedBox(width: 12.w),
                  _buildOptionCard(
                    colors,
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    subtitle: 'Pilih gambar',
                    gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                    onTap: () => onSelected(FilePickerType.gallery),
                  ),
                  SizedBox(width: 12.w),
                  _buildOptionCard(
                    colors,
                    icon: Icons.description_rounded,
                    label: 'File',
                    subtitle: 'Dokumen',
                    gradient: const [Color(0xFFEA580C), Color(0xFFC2410C)],
                    onTap: () => onSelected(FilePickerType.file),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: colors.divider),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: AppTextStyles.bodyMedium(colors.textSecondary),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    ThemeColors colors, {
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
              SizedBox(height: 10.h),
              Text(label, style: AppTextStyles.bodySemiBold(Colors.white)),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: AppTextStyles.caption(
                  Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

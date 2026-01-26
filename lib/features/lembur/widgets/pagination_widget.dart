import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.itemsPerPage = 10,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final startItem = ((currentPage - 1) * itemsPerPage) + 1;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Showing $startItem of $totalItems Data',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
          SizedBox(width: 16.w),
          _buildPageButton(colors, currentPage.toString(), isActive: true),
          SizedBox(width: 8.w),
          _buildNavButton(
            colors,
            Icons.chevron_left,
            enabled: currentPage > 1,
            onTap: () => onPageChanged(currentPage - 1),
          ),
          SizedBox(width: 4.w),
          _buildNavButton(
            colors,
            Icons.chevron_right,
            enabled: currentPage < totalPages,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(
    ThemeColors colors,
    String text, {
    bool isActive = false,
  }) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: isActive ? colors.textPrimary : colors.surface,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: colors.divider),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.caption(
            isActive ? colors.background : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    ThemeColors colors,
    IconData icon, {
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        size: 24.sp,
        color: enabled ? colors.textSecondary : colors.divider,
      ),
    );
  }
}

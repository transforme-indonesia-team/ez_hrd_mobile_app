import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';

/// Section Informasi Perusahaan dengan empty state
class CompanyInfoSection extends StatelessWidget {
  final List<dynamic>? data;

  const CompanyInfoSection({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasData = data != null && data!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      color: colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Informasi Perusahaan',
              style: AppTextStyles.h4(colors.textPrimary),
            ),
          ),
          SizedBox(height: 16.h),
          // Content or empty state
          if (hasData) _buildContent(colors) else const EmptyStateWidget(),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    // TODO: Implement actual content when data is available
    return const SizedBox.shrink();
  }
}

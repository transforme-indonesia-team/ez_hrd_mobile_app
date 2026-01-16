import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';

/// Screen Postingan dengan fitur empty state
class PostinganScreen extends StatelessWidget {
  const PostinganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: const EmptyStateWidget(
        message: 'Fitur Tidak Diaktifkan\nHubungi admin untuk akses',
        icon: Icons.description_outlined,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeColors colors) {
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      titleSpacing: 16.w,
      title: Text(
        'Postingan',
        style: AppTextStyles.h3(colors.textPrimary),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement search
          },
          icon: Icon(Icons.search, color: colors.textSecondary, size: 24.sp),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/beranda/widgets/company_switcher_bottom_sheet.dart';
import 'package:provider/provider.dart';

class BerandaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BerandaAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authProvider = context.watch<AuthProvider>();
    final companyName = authProvider.selectedCompany?.companyName ?? 'EZ HRD';

    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      titleSpacing: 16.w,
      title: GestureDetector(
        onTap: () => CompanySwitcherBottomSheet.show(context),
        child: Text(companyName, style: AppTextStyles.h3(colors.textPrimary)),
      ),
      actions: [
        IconButton(
          onPressed: () => CompanySwitcherBottomSheet.show(context),
          icon: Icon(
            Icons.chevron_right,
            color: colors.textSecondary,
            size: 24.sp,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.search, color: colors.textSecondary, size: 24.sp),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class CompanySwitcherBottomSheet {
  CompanySwitcherBottomSheet._();

  static void show(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final companies = authProvider.user?.companies;

    if (companies == null || companies.isEmpty) return;

    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Company list
              ...companies.asMap().entries.map((entry) {
                final index = entry.key;
                final company = entry.value;
                final isSelected = index == authProvider.selectedCompanyIndex;

                return InkWell(
                  onTap: () {
                    authProvider.setSelectedCompany(index);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: colors.divider, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          color: isSelected
                              ? colors.primaryBlue
                              : colors.textSecondary,
                          size: 22.sp,
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Text(
                            company.companyName,
                            style: AppTextStyles.bodyMedium(
                              isSelected
                                  ? colors.primaryBlue
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: colors.primaryBlue,
                            size: 22.sp,
                          ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }
}

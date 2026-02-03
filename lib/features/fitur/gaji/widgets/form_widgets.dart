import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Widget untuk password field dengan toggle visibility
class PasswordFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final int? maxLength;

  const PasswordFormField({
    super.key,
    required this.controller,
    required this.hint,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body(
            colors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(
              colors.textSecondary,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: colors.background,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.primaryBlue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colors.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: colors.textSecondary,
                size: 20.sp,
              ),
            ),
          ),
          style: AppTextStyles.body(colors.textPrimary, fontSize: 14.sp),
          validator: validator,
        ),
      ],
    );
  }
}

/// Widget untuk read-only field
class ReadOnlyFormField extends StatelessWidget {
  final String label;
  final String value;

  const ReadOnlyFormField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body(
            colors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: colors.divider.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: colors.divider),
          ),
          child: Text(
            value,
            style: AppTextStyles.body(colors.textPrimary, fontSize: 14.sp),
          ),
        ),
      ],
    );
  }
}

/// Widget untuk submit button dengan loading state
class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    this.isLoading = false,
    this.text = 'Ajukan',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.primaryBlue.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(text, style: AppTextStyles.button(Colors.white)),
      ),
    );
  }
}

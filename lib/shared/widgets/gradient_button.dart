import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Reusable gradient button dengan loading state
///
/// Digunakan untuk tombol utama seperti Login, Submit, dll.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: effectiveEnabled
              ? colors.buttonGradient
              : colors.buttonGradientDisabled,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveEnabled
            ? [
                BoxShadow(
                  color: colors.buttonBlue.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.h4(
                      effectiveEnabled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

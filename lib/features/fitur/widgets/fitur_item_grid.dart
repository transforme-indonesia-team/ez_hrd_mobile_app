import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';

class FiturItemGrid extends StatelessWidget {
  final FiturItemModel item;
  final Color? categoryBackgroundColor;
  final Color? categoryIconColor;
  final VoidCallback? onTap;

  const FiturItemGrid({
    super.key,
    required this.item,
    this.categoryBackgroundColor,
    this.categoryIconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: categoryBackgroundColor ?? colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.divider, width: 1),
            ),
            child: Icon(
              item.icon,
              size: 28,
              color: categoryIconColor ?? colors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          SizedBox(
            height: 32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

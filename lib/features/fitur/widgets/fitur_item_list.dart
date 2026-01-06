import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';

/// Item fitur dalam tampilan list
/// Icon di kiri dengan text di kanan
class FiturItemList extends StatelessWidget {
  final FiturItemModel item;
  final Color? categoryBackgroundColor;
  final Color? categoryIconColor;
  final VoidCallback? onTap;

  const FiturItemList({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: categoryBackgroundColor ?? colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.divider, width: 1),
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: categoryIconColor ?? colors.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

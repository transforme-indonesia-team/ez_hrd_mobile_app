import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/image_url_extension.dart';
import 'package:hrd_app/core/utils/string_utils.dart';

/// Reusable avatar widget that shows user photo or initials as fallback
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? name;
  final double size;
  final double fontSize;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.name,
    this.size = 32,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name != null ? StringUtils.getInitials(name!) : '?';

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorPalette.slate200,
      ),
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                avatarUrl.asFullImageUrl!,
                width: size.w,
                height: size.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to initials if image fails to load
                  return Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.xxSmall(ColorPalette.slate500),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: (size * 0.5).w,
                      height: (size * 0.5).w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorPalette.slate400,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                initials,
                style: AppTextStyles.xxSmall(ColorPalette.slate500),
              ),
            ),
    );
  }
}

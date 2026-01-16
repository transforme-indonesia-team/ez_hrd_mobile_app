import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/beranda/data/favorite_menu_data.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_grid.dart';

/// Section Menu Favorit di Beranda
class FavoriteMenuSection extends StatelessWidget {
  final Function(FiturItemModel)? onItemTap;

  const FavoriteMenuSection({super.key, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              'Menu Favorit',
              style: AppTextStyles.h4(colors.textPrimary),
            ),
          ),
          SizedBox(height: 16.h),
          // Grid menu items
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              itemCount: FavoriteMenuData.items.length,
              itemBuilder: (context, index) {
                final item = FavoriteMenuData.items[index];
                return FiturItemGrid(
                  item: item,
                  categoryBackgroundColor: FavoriteMenuData.getBackgroundColor(
                    item.id,
                  ),
                  categoryIconColor: FavoriteMenuData.getIconColor(item.id),
                  onTap: () => onItemTap?.call(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/constants/app_constants.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_grid.dart';

class FiturBottomSheet extends StatefulWidget {
  final String title;
  final FiturCategoryModel category;
  final Function(FiturItemModel) onItemTap;

  const FiturBottomSheet({
    super.key,
    required this.title,
    required this.category,
    required this.onItemTap,
  });

  static void show(
    BuildContext context, {
    required String title,
    required FiturCategoryModel category,
    required Function(FiturItemModel) onItemTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FiturBottomSheet(
        title: title,
        category: category,
        onItemTap: onItemTap,
      ),
    );
  }

  @override
  State<FiturBottomSheet> createState() => _FiturBottomSheetState();
}

class _FiturBottomSheetState extends State<FiturBottomSheet> {
  final Set<int> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    // Expand first sub-category by default
    if (_hasSubCategories) {
      _expandedCategories.add(0);
    }
  }

  bool get _hasSubCategories =>
      widget.category.subCategories != null &&
      widget.category.subCategories!.isNotEmpty;

  void _toggleCategory(int index) {
    setState(() {
      if (_expandedCategories.contains(index)) {
        _expandedCategories.remove(index);
      } else {
        _expandedCategories.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.5, 0.95],
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                      child: Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: colors.divider,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
                      child: Row(
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.bodySemiBold(
                              colors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(child: Divider(color: colors.divider)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Jika ada subCategories → tampilkan accordion
              // Jika tidak → tampilkan semua items langsung
              if (_hasSubCategories)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final subCat = widget.category.subCategories![index];
                    final isExpanded = _expandedCategories.contains(index);
                    return _buildCategoryTile(
                      subCat,
                      index,
                      isExpanded,
                      colors,
                    );
                  }, childCount: widget.category.subCategories!.length),
                )
              else
                SliverToBoxAdapter(
                  child: _buildItemsGrid(context, widget.category, colors),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTile(
    FiturCategoryModel subCategory,
    int index,
    bool isExpanded,
    ThemeColors colors,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _toggleCategory(index),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subCategory.name,
                  style: AppTextStyles.h4(colors.textPrimary),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: colors.textSecondary,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildItemsGrid(context, subCategory, colors),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: AppConstants.animationFastMs),
        ),
      ],
    );
  }

  Widget _buildItemsGrid(
    BuildContext context,
    FiturCategoryModel category,
    ThemeColors colors,
  ) {
    // Gunakan backgroundColor/iconColor dari parent jika sub-category tidak punya
    final bgColor = category.backgroundColor ?? widget.category.backgroundColor;
    final icColor = category.iconColor ?? widget.category.iconColor;
    final hasVeryLongTitle = category.items.any(
      (item) => item.title.length > 32,
    );
    final rowHeight = hasVeryLongTitle ? 118.h : 94.h;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 2.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisExtent: rowHeight,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 4.h,
        ),
        itemCount: category.items.length,
        itemBuilder: (context, index) {
          final item = category.items[index];
          return FiturItemGrid(
            item: item,
            categoryBackgroundColor: bgColor,
            categoryIconColor: icColor,
            onTap: () {
              Navigator.pop(context);
              widget.onItemTap(item);
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_grid.dart';

class FiturBottomSheet extends StatefulWidget {
  final String title;
  final List<FiturCategoryModel> categories;
  final Function(FiturItemModel) onItemTap;

  const FiturBottomSheet({
    super.key,
    required this.title,
    required this.categories,
    required this.onItemTap,
  });

  static void show(
    BuildContext context, {
    required String title,
    required List<FiturCategoryModel> categories,
    required Function(FiturItemModel) onItemTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FiturBottomSheet(
        title: title,
        categories: categories,
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
    if (widget.categories.isNotEmpty) {
      _expandedCategories.add(0);
    }
  }

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.bodySemiBold(
                              colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Divider(color: colors.divider)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = widget.categories[index];
                  final isExpanded = _expandedCategories.contains(index);
                  return _buildCategoryTile(
                    category,
                    index,
                    isExpanded,
                    colors,
                  );
                }, childCount: widget.categories.length),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTile(
    FiturCategoryModel category,
    int index,
    bool isExpanded,
    ThemeColors colors,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _toggleCategory(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: AppTextStyles.h4(colors.textPrimary),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: colors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildItemsGrid(category, colors),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildItemsGrid(FiturCategoryModel category, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: category.items.map((item) {
            return SizedBox(
              width: 72,
              height: 90,
              child: FiturItemGrid(
                item: item,
                categoryBackgroundColor: category.backgroundColor,
                categoryIconColor: category.iconColor,
                onTap: () {
                  Navigator.pop(context);
                  widget.onItemTap(item);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/overtime_type_model.dart';

class OvertimeTypeBottomSheet extends StatefulWidget {
  final List<OvertimeTypeModel> types;
  final OvertimeTypeModel? selectedType;
  final ValueChanged<OvertimeTypeModel> onSelected;

  const OvertimeTypeBottomSheet({
    super.key,
    required this.types,
    this.selectedType,
    required this.onSelected,
  });

  static Future<OvertimeTypeModel?> show(
    BuildContext context, {
    required List<OvertimeTypeModel> types,
    OvertimeTypeModel? selectedType,
  }) {
    return showModalBottomSheet<OvertimeTypeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OvertimeTypeBottomSheet(
        types: types,
        selectedType: selectedType,
        onSelected: (type) => Navigator.pop(context, type),
      ),
    );
  }

  @override
  State<OvertimeTypeBottomSheet> createState() =>
      _OvertimeTypeBottomSheetState();
}

class _OvertimeTypeBottomSheetState extends State<OvertimeTypeBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<OvertimeTypeModel> _filteredTypes = [];

  @override
  void initState() {
    super.initState();
    _filteredTypes = widget.types;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTypes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTypes = widget.types;
      } else {
        _filteredTypes = widget.types
            .where(
              (type) =>
                  type.name?.toLowerCase().contains(query.toLowerCase()) ??
                  false,
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text('Tipe Lembur', style: AppTextStyles.h4(colors.textPrimary)),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTypes,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: AppTextStyles.body(colors.textSecondary),
                prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                filled: true,
                fillColor: colors.surface,
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
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, color: colors.divider),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300.h),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _filteredTypes.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: colors.divider),
              itemBuilder: (context, index) {
                final type = _filteredTypes[index];
                final isSelected = widget.selectedType?.id == type.id;

                return ListTile(
                  title: Text(
                    type.displayName,
                    style: AppTextStyles.body(
                      isSelected ? colors.primaryBlue : colors.textPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colors.textSecondary,
                    size: 20.sp,
                  ),
                  onTap: () => widget.onSelected(type),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }
}

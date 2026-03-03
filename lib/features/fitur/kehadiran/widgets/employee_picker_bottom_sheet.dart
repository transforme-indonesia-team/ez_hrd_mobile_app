import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class MemberModel {
  final String id;
  final String name;
  final String position;

  MemberModel({required this.id, required this.name, required this.position});

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['value'] ?? '',
      name: json['label'] ?? '',
      position: json['other']?['position_organization_name'] ?? '',
    );
  }
}

class EmployeePickerBottomSheet extends StatefulWidget {
  final List<MemberModel> selectedEmployees;

  const EmployeePickerBottomSheet({
    super.key,
    this.selectedEmployees = const [],
  });

  /// Show the bottom sheet and return selected employees
  static Future<List<MemberModel>?> show(
    BuildContext context, {
    List<MemberModel> selectedEmployees = const [],
  }) {
    return showModalBottomSheet<List<MemberModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EmployeePickerBottomSheet(selectedEmployees: selectedEmployees),
    );
  }

  @override
  State<EmployeePickerBottomSheet> createState() =>
      _EmployeePickerBottomSheetState();
}

class _EmployeePickerBottomSheetState extends State<EmployeePickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<MemberModel> _allMembers = [];
  List<MemberModel> _filteredMembers = [];
  Set<String> _selectedIds = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.selectedEmployees.map((e) => e.id).toSet();
    _fetchMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    try {
      final response = await EmployeeService().getMember();
      final records = response['original']?['records'] ?? response['records'];

      if (records is List) {
        final members = records
            .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) {
          setState(() {
            _allMembers = members;
            _filteredMembers = members;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching members: $e');
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data karyawan';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        _filteredMembers = _allMembers
            .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds = _filteredMembers.map((m) => m.id).toSet();
    });
  }

  void _apply() {
    final selected = _allMembers
        .where((m) => _selectedIds.contains(m.id))
        .toList();
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          children: [
            // Handle bar
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Daftar Karyawan',
                  style: AppTextStyles.h4(colors.textPrimary),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: AppTextStyles.body(colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari',
                  hintStyle: AppTextStyles.body(colors.textSecondary),
                  filled: true,
                  fillColor: colors.surface,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
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
                  suffixIcon: Icon(
                    Icons.search,
                    color: colors.textSecondary,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Header row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Karyawan yang dapat Dipilih',
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: _selectAll,
                    child: Text(
                      'Pindahkan Semua',
                      style: AppTextStyles.captionMedium(colors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Divider(height: 1, color: colors.divider),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: AppTextStyles.body(colors.textSecondary),
                      ),
                    )
                  : _filteredMembers.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada karyawan ditemukan',
                        style: AppTextStyles.body(colors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      itemCount: _filteredMembers.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: colors.divider),
                      itemBuilder: (context, index) {
                        final member = _filteredMembers[index];
                        final isSelected = _selectedIds.contains(member.id);
                        return _buildMemberTile(colors, member, isSelected);
                      },
                    ),
            ),

            // Bottom button
            Container(
              padding: EdgeInsets.fromLTRB(
                16.w,
                10.h,
                16.w,
                MediaQuery.of(context).padding.bottom + 10.h,
              ),
              decoration: BoxDecoration(
                color: colors.background,
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIds.isEmpty ? null : _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.primaryBlue.withValues(
                      alpha: 0.4,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    _selectedIds.isEmpty
                        ? 'Tambahkan Yang Dipilih'
                        : 'Tambahkan Yang Dipilih (${_selectedIds.length})',
                    style: AppTextStyles.button(Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(
    ThemeColors colors,
    MemberModel member,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => _toggleSelect(member.id),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            UserAvatar(name: member.name, size: 40.w, fontSize: 14.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTextStyles.bodyMedium(colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    member.position,
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primaryBlue, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/services/employee_service.dart';
import 'package:hrd_app/features/profile/screens/profile_detail_screen.dart';

/// Model data karyawan dari API getMember
class _MemberData {
  final String value;
  final String label;
  final String? employeeCode;
  final String? positionName;
  final String? profileUrl;

  const _MemberData({
    required this.value,
    required this.label,
    this.employeeCode,
    this.positionName,
    this.profileUrl,
  });

  factory _MemberData.fromJson(Map<String, dynamic> json) {
    final other = json['other'] as Map<String, dynamic>?;
    return _MemberData(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      employeeCode: other?['employee_code']?.toString(),
      positionName: other?['position_organization_name']?.toString(),
      profileUrl: other?['profile']?.toString(),
    );
  }
}

abstract class SearchMemberBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _SearchMemberContent(scrollController: scrollController);
        },
      ),
    );
  }
}

class _SearchMemberContent extends StatefulWidget {
  final ScrollController scrollController;

  const _SearchMemberContent({required this.scrollController});

  @override
  State<_SearchMemberContent> createState() => _SearchMemberContentState();
}

class _SearchMemberContentState extends State<_SearchMemberContent> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<_MemberData> _allMembers = [];
  List<_MemberData> _filteredMembers = [];
  bool _isLoading = true;
  String? _error;

  // Infinite scroll pagination
  static const int _pageSize = 20;
  int _displayCount = _pageSize;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _fetchMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_displayCount < _filteredMembers.length) {
      setState(() {
        _displayCount = (_displayCount + _pageSize).clamp(
          0,
          _filteredMembers.length,
        );
      });
    }
  }

  Future<void> _fetchMembers() async {
    try {
      final response = await EmployeeService().getMember();

      List<dynamic>? recordsRaw;
      if (response['original'] != null) {
        recordsRaw = response['original']['records'] as List<dynamic>?;
      } else {
        recordsRaw = response['records'] as List<dynamic>?;
      }

      if (recordsRaw != null && mounted) {
        final members = recordsRaw
            .map((e) => _MemberData.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _allMembers = members;
          _filteredMembers = List.from(members);
          _isLoading = false;
          _displayCount = _pageSize.clamp(0, _filteredMembers.length);
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('SearchMember: Error fetching members: $e');
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data karyawan';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _applyFilter(query);
    });
  }

  void _applyFilter(String query) {
    setState(() {
      _selectedIndex = null;
      if (query.isEmpty) {
        _filteredMembers = List.from(_allMembers);
      } else {
        final q = query.toLowerCase();
        _filteredMembers = _allMembers.where((m) {
          return m.label.toLowerCase().contains(q) ||
              (m.employeeCode?.toLowerCase().contains(q) ?? false) ||
              (m.positionName?.toLowerCase().contains(q) ?? false);
        }).toList();
      }
      _displayCount = _pageSize.clamp(0, _filteredMembers.length);
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
        children: [
          _buildHeader(colors),
          Expanded(child: _buildBody(colors)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),

        // Search bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: colors.divider),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTextStyles.body(colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari Karyawan atau Menu disini...',
                hintStyle: AppTextStyles.body(
                  colors.textSecondary.withValues(alpha: 0.6),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colors.textSecondary,
                          size: 18.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter('');
                        },
                      )
                    : Icon(
                        Icons.search,
                        color: colors.textSecondary,
                        size: 20.sp,
                      ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Title row: "Daftar Karyawan" + "Sortir"
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Karyawan',
                style: AppTextStyles.h4(colors.textPrimary),
              ),
              Text(
                'Sortir',
                style: AppTextStyles.bodyMedium(colors.primaryBlue),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return EmptyStateWidget(
        message: _error!,
        icon: Icons.error_outline,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          _fetchMembers();
        },
      );
    }

    if (_filteredMembers.isEmpty) {
      return EmptyStateWidget(
        message: _searchController.text.isNotEmpty
            ? 'Karyawan tidak ditemukan'
            : 'Tidak ada data karyawan',
        icon: Icons.person_search_outlined,
      );
    }

    final visibleCount = _displayCount.clamp(0, _filteredMembers.length);
    final hasMore = visibleCount < _filteredMembers.length;

    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      itemCount: visibleCount + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator di akhir list
        if (index == visibleCount) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final member = _filteredMembers[index];
        final isSelected = _selectedIndex == index;

        return _buildMemberItem(colors, member, index, isSelected);
      },
    );
  }

  Widget _buildMemberItem(
    ThemeColors colors,
    _MemberData member,
    int index,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        // Tutup bottom sheet lalu navigate ke profil
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(
              employeeCode: member.employeeCode ?? member.value,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8E1) : Colors.transparent,
          border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            UserAvatar(
              avatarUrl: member.profileUrl,
              name: member.label,
              size: 48,
              fontSize: 16,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.label,
                    style: AppTextStyles.bodySemiBold(colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${member.employeeCode ?? member.value} - ${member.positionName ?? ''}',
                    style: AppTextStyles.caption(colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

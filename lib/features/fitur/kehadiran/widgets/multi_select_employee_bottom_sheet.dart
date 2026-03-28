import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class MemberData {
  final String value;
  final String label;
  final String? employeeCode;
  final String? positionName;
  final String? profileUrl;

  const MemberData({
    required this.value,
    required this.label,
    this.employeeCode,
    this.positionName,
    this.profileUrl,
  });

  factory MemberData.fromJson(Map<String, dynamic> json) {
    final other = json['other'] as Map<String, dynamic>?;
    return MemberData(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      employeeCode: other?['employee_code']?.toString(),
      positionName: other?['position_organization_name']?.toString(),
      profileUrl: other?['profile']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemberData && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class MultiSelectEmployeeBottomSheet {
  static Future<List<MemberData>?> show(
    BuildContext context, {
    required List<MemberData> initialSelectedItems,
  }) {
    return showModalBottomSheet<List<MemberData>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _MultiSelectEmployeeContent(
            scrollController: scrollController,
            initialSelectedItems: initialSelectedItems,
          );
        },
      ),
    );
  }
}

class _MultiSelectEmployeeContent extends StatefulWidget {
  final ScrollController scrollController;
  final List<MemberData> initialSelectedItems;

  const _MultiSelectEmployeeContent({
    required this.scrollController,
    required this.initialSelectedItems,
  });

  @override
  State<_MultiSelectEmployeeContent> createState() =>
      _MultiSelectEmployeeContentState();
}

class _MultiSelectEmployeeContentState
    extends State<_MultiSelectEmployeeContent> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<MemberData> _allMembers = [];
  List<MemberData> _filteredMembers = [];
  bool _isLoading = true;
  String? _error;

  List<MemberData> _selectedMembers = [];

  static const int _pageSize = 20;
  int _displayCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _selectedMembers = List.from(widget.initialSelectedItems);
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
            .map((e) => MemberData.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _allMembers = members;
          _applyFilter(_searchController.text);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
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
      final q = query.toLowerCase();
      _filteredMembers = _allMembers.where((m) {
        if (_selectedMembers.contains(m)) return false;

        if (q.isEmpty) return true;
        return m.label.toLowerCase().contains(q) ||
            (m.employeeCode?.toLowerCase().contains(q) ?? false) ||
            (m.positionName?.toLowerCase().contains(q) ?? false);
      }).toList();
      _displayCount = _pageSize.clamp(0, _filteredMembers.length);
    });
  }

  void _toggleSelection(MemberData member) {
    setState(() {
      if (_selectedMembers.contains(member)) {
        _selectedMembers.remove(member);
      } else {
        _selectedMembers.add(member);
      }
      _applyFilter(_searchController.text);
    });
  }

  void _selectAllFiltered() {
    setState(() {
      for (var member in _filteredMembers) {
        if (!_selectedMembers.contains(member)) {
          _selectedMembers.add(member);
        }
      }
      _applyFilter(_searchController.text);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedMembers.clear();
      _applyFilter(_searchController.text);
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
          if (_selectedMembers.isNotEmpty) _buildSelectedChips(colors),
          _buildSearchBarAndActions(colors),
          Expanded(child: _buildBody(colors)),
          _buildBottomButton(colors),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Daftar Karyawan',
            style: AppTextStyles.h4(colors.textPrimary),
          ),
        ),
        SizedBox(height: 12.h),
        Divider(color: colors.divider, height: 1),
      ],
    );
  }

  Widget _buildSelectedChips(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Total ',
                      style: AppTextStyles.body(colors.textPrimary),
                    ),
                    TextSpan(
                      text: '${_selectedMembers.length}',
                      style: AppTextStyles.bodySemiBold(colors.primaryBlue),
                    ),
                    TextSpan(
                      text: ' Terpilih',
                      style: AppTextStyles.body(colors.textPrimary),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _clearAll,
                child: Text(
                  'Bersihkan semua',
                  style: AppTextStyles.bodyMedium(
                    colors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Horizontally scrolling chips
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _selectedMembers.length,
            itemBuilder: (context, index) {
              final member = _selectedMembers[index];
              return Container(
                margin: EdgeInsets.only(right: 8.w, bottom: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.divider),
                  borderRadius: BorderRadius.circular(20.r),
                  color: colors.surface,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserAvatar(
                      avatarUrl: member.profileUrl,
                      name: member.label,
                      size: 20, // Smaller avatar
                      fontSize: 10,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      member.label,
                      style: AppTextStyles.smallMedium(colors.textSecondary),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () => _toggleSelection(member),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Divider(color: colors.divider, height: 1),
      ],
    );
  }

  Widget _buildSearchBarAndActions(ThemeColors colors) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: colors.divider),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: AppTextStyles.body(colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari',
                      hintStyle: AppTextStyles.body(
                        colors.textSecondary.withValues(alpha: 0.6),
                      ),
                      prefixIcon: _searchController.text.isEmpty
                          ? Icon(
                              Icons.search,
                              color: colors.textSecondary,
                              size: 20.sp,
                            )
                          : null,
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
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.filter_alt_outlined,
                color: colors.textSecondary,
                size: 24.sp,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Karyawan yang dapat Dipilih',
                style: AppTextStyles.body(colors.textPrimary),
              ),
              InkWell(
                onTap: _selectAllFiltered,
                child: Text(
                  'Pindahkan Semua',
                  style: AppTextStyles.bodyMedium(colors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
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
        final isSelected = _selectedMembers.contains(member);

        return _buildMemberItem(colors, member, isSelected);
      },
    );
  }

  Widget _buildMemberItem(
    ThemeColors colors,
    MemberData member,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => _toggleSelection(member),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8E1).withValues(alpha: 0.5) : Colors.transparent,
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

  Widget _buildBottomButton(ThemeColors colors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors.buttonGradient),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: colors.buttonBlue.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context, _selectedMembers);
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              alignment: Alignment.center,
              child: Text(
                'Tambahkan Yang Dipilih',
                style: AppTextStyles.button(Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

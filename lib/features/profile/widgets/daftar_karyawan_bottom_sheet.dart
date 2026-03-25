import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/services/employee_service.dart';
import 'package:hrd_app/features/profile/screens/profile_detail_screen.dart';
import 'package:provider/provider.dart';

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

abstract class DaftarKaryawanBottomSheet {
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
          return _DaftarKaryawanContent(scrollController: scrollController);
        },
      ),
    );
  }
}

class _DaftarKaryawanContent extends StatefulWidget {
  final ScrollController scrollController;

  const _DaftarKaryawanContent({required this.scrollController});

  @override
  State<_DaftarKaryawanContent> createState() => _DaftarKaryawanContentState();
}

class _DaftarKaryawanContentState extends State<_DaftarKaryawanContent> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<_MemberData> _allMembers = [];
  List<_MemberData> _filteredMembers = [];
  bool _isLoading = true;
  String? _error;

  // Pagination
  static const int _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _filterMembers(_searchController.text);
    });
  }

  void _filterMembers(String query) {
    setState(() {
      _currentPage = 1;
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
    });
  }

  Future<void> _fetchMembers() async {
    try {
      final response = await EmployeeService().getMember();
      if (!mounted) return;

      final original = response['original'] as Map<String, dynamic>?;
      final records = original?['records'] as List?;

      if (records != null) {
        setState(() {
          _allMembers = records
              .map((e) => _MemberData.fromJson(e as Map<String, dynamic>))
              .toList();
          _filteredMembers = List.from(_allMembers);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat data karyawan';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('DaftarKaryawan: Error fetching members: $e');
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data karyawan';
          _isLoading = false;
        });
      }
    }
  }

  /// Get members excluding self
  List<_MemberData> get _otherMembers {
    final user = context.read<AuthProvider>().user;
    if (user == null) return _filteredMembers;
    return _filteredMembers.where((m) {
      return m.employeeCode != user.employeeCode;
    }).toList();
  }

  /// Paginated other members
  List<_MemberData> get _pagedOtherMembers {
    final others = _otherMembers;
    final end = (_currentPage * _pageSize).clamp(0, others.length);
    return others.sublist(0, end);
  }

  int get _totalPages {
    final total = _otherMembers.length;
    return (total / _pageSize).ceil().clamp(1, 999);
  }

  void _navigateToProfile(_MemberData member) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(
          employeeCode: member.employeeCode ?? member.value,
        ),
      ),
    );
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
          // Drag handle + title
          _buildHeader(colors),

          // Search bar
          _buildSearchBar(colors),

          // Content
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
                : _buildContent(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: colors.textSecondary.withAlpha(80),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 12.h),
        Text('Daftar Karyawan', style: AppTextStyles.h3(colors.textPrimary)),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildSearchBar(ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.divider),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.body(colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari Karyawan',
                  hintStyle: AppTextStyles.body(colors.textSecondary),
                  suffixIcon: Icon(Icons.search, color: colors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Icon(Icons.filter_alt_outlined, color: colors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    final user = context.read<AuthProvider>().user;
    final pagedOthers = _pagedOtherMembers;
    final totalOthers = _otherMembers.length;

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      children: [
        // ── SAYA section ──
        if (user != null) ...[
          _buildSectionLabel(colors, 'SAYA'),
          _buildSelfItem(colors, user),
        ],

        // ── SEMUA KARYAWAN section ──
        _buildSectionLabel(colors, 'SEMUA KARYAWAN'),
        if (pagedOthers.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: Text(
                'Tidak ada data karyawan',
                style: AppTextStyles.body(colors.textSecondary),
              ),
            ),
          )
        else ...[
          ...pagedOthers.map((m) => _buildMemberItem(colors, m)),
        ],

        // ── Pagination ──
        SizedBox(height: 16.h),
        _buildPagination(colors, totalOthers),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildSectionLabel(ThemeColors colors, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.captionMedium(colors.textSecondary)),
          SizedBox(width: 8.w),
          Expanded(child: Divider(color: colors.divider, height: 1)),
        ],
      ),
    );
  }

  Widget _buildSelfItem(ThemeColors colors, dynamic user) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileDetailScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: colors.primaryBlue.withAlpha(25),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            UserAvatar(
              avatarUrl: user.avatarUrl,
              name: user.name ?? 'User',
              size: 48,
              fontSize: 16,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (user.name ?? 'User').toUpperCase(),
                    style: AppTextStyles.bodySemiBold(colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    user.role ?? 'Employee',
                    style: AppTextStyles.caption(colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    user.company ?? '',
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

  Widget _buildMemberItem(ThemeColors colors, _MemberData member) {
    return InkWell(
      onTap: () => _navigateToProfile(member),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
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
                    '${member.employeeCode ?? ''} - ${member.positionName ?? ''}',
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

  Widget _buildPagination(ThemeColors colors, int totalItems) {
    final displayedEnd = (_currentPage * _pageSize).clamp(0, totalItems);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Menampilkan $displayedEnd dari $totalItems Data',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
          SizedBox(width: 12.w),
          // Page number
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colors.primaryBlue,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '$_currentPage',
              style: AppTextStyles.captionMedium(Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          // Previous
          GestureDetector(
            onTap: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            child: Icon(
              Icons.chevron_left,
              color: _currentPage > 1
                  ? colors.textPrimary
                  : colors.textSecondary.withAlpha(100),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 4.w),
          // Next
          GestureDetector(
            onTap: _currentPage < _totalPages
                ? () => setState(() => _currentPage++)
                : null,
            child: Icon(
              Icons.chevron_right,
              color: _currentPage < _totalPages
                  ? colors.textPrimary
                  : colors.textSecondary.withAlpha(100),
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/models/overtime_employee_model.dart';
import 'package:hrd_app/data/services/leave_service.dart';
import 'package:hrd_app/data/services/overtime_service.dart';
import 'package:hrd_app/features/fitur/cuti/screens/detail_cuti_screen.dart';
import 'package:hrd_app/features/fitur/cuti/widgets/leave_request_card.dart';
import 'package:hrd_app/features/fitur/lembur/screens/detail_lembur_screen.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/overtime_request_card.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/pagination_widget.dart';

class PermohonanKaryawanScreen extends StatefulWidget {
  const PermohonanKaryawanScreen({super.key});

  @override
  State<PermohonanKaryawanScreen> createState() =>
      _PermohonanKaryawanScreenState();
}

class _PermohonanKaryawanScreenState extends State<PermohonanKaryawanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dropdown
  final List<String> _tipePermintaan = [
    'Permintaan Kehadiran',
    'Permintaan Lembur',
  ];
  String? _selectedTipe;

  // Sub-filter di tab Persetujuan
  int _selectedPersetujuanFilter = 0; // 0 = Belum Disetujui, 1 = Riwayat

  // Data state
  bool _isLoading = false;
  String? _errorMessage;

  // Leave (Kehadiran) data
  List<LeaveEmployeeModel> _leaveRequests = [];

  // Overtime (Lembur) data
  List<OvertimeEmployeeModel> _overtimeRequests = [];

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
    // Tidak auto-fetch, tunggu user pilih tipe dulu
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_selectedTipe == 'Permintaan Kehadiran') {
        await _fetchLeaveData();
      } else {
        await _fetchOvertimeData();
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan saat memuat data';
        });
      }
    }
  }

  Future<void> _fetchLeaveData() async {
    final response = await LeaveService().getLeaveEmployee(
      page: _currentPage,
      limit: 10,
    );

    final recordsRaw = response['original']['records'];

    if (recordsRaw == null || recordsRaw is List) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _leaveRequests = [];
          _totalItems = 0;
          _totalPages = 1;
        });
      }
      return;
    }

    final records = recordsRaw as Map<String, dynamic>;
    final items = records['items'] as List<dynamic>? ?? [];
    final pagination = records['pagination'] as Map<String, dynamic>?;

    if (mounted) {
      setState(() {
        _isLoading = false;
        _leaveRequests = items
            .map((e) => LeaveEmployeeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _totalItems = pagination?['total_data'] as int? ?? 0;
        _totalPages = pagination?['total_pages'] as int? ?? 1;
      });
    }
  }

  Future<void> _fetchOvertimeData() async {
    final response = await OvertimeService().getOvertimeEmployee(
      page: _currentPage,
      limit: 10,
    );

    final recordsRaw = response['original']['records'];

    if (recordsRaw == null || recordsRaw is List) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _overtimeRequests = [];
          _totalItems = 0;
          _totalPages = 1;
        });
      }
      return;
    }

    final records = recordsRaw as Map<String, dynamic>;
    final items = records['items'] as List<dynamic>? ?? [];
    final pagination = records['pagination'] as Map<String, dynamic>?;

    if (mounted) {
      setState(() {
        _isLoading = false;
        _overtimeRequests = items
            .map(
              (e) => OvertimeEmployeeModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        _totalItems = pagination?['total_data'] as int? ?? 0;
        _totalPages = pagination?['total_pages'] as int? ?? 1;
      });
    }
  }

  void _onTipeChanged(String? value) {
    if (value != null && value != _selectedTipe) {
      setState(() {
        _selectedTipe = value;
        _currentPage = 1;
        _leaveRequests = [];
        _overtimeRequests = [];
      });
      _fetchData();
    }
  }

  Future<void> _navigateToLeaveDetail(LeaveEmployeeModel request) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCutiScreen(detailLeave: request),
      ),
    );
    if (result == true && mounted) _fetchData();
  }

  Future<void> _navigateToOvertimeDetail(OvertimeEmployeeModel request) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailLemburScreen(detailOvertime: request),
      ),
    );
    if (result == true && mounted) _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Permohonan Karyawan',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: colors.textPrimary),
            onPressed: () {
              // TODO: filter bottom sheet
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(44.h),
          child: _buildTabBar(colors),
        ),
      ),
      body: Column(
        children: [
          _buildTipePermintaanDropdown(colors),

          if (_tabController.index == 1) _buildPersetujuanFilter(colors),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildContent(colors), _buildContent(colors)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeColors colors) {
    return TabBar(
      controller: _tabController,
      labelColor: colors.primaryBlue,
      unselectedLabelColor: colors.textSecondary,
      indicatorColor: colors.primaryBlue,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: colors.divider,
      labelStyle: AppTextStyles.bodySemiBold(colors.primaryBlue),
      unselectedLabelStyle: AppTextStyles.body(colors.textSecondary),
      tabs: const [
        Tab(text: 'Permintaan Saya'),
        Tab(text: 'Persetujuan'),
      ],
    );
  }

  Widget _buildTipePermintaanDropdown(ThemeColors colors) {
    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipe Permintaan',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              border: Border.all(color: colors.divider),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTipe,
                isExpanded: true,
                hint: Text(
                  'Pilih Tipe Permintaan',
                  style: AppTextStyles.body(colors.textSecondary),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: colors.textSecondary,
                ),
                style: AppTextStyles.body(colors.textPrimary),
                dropdownColor: colors.background,
                items: _tipePermintaan.map((tipe) {
                  return DropdownMenuItem<String>(
                    value: tipe,
                    child: Text(tipe),
                  );
                }).toList(),
                onChanged: _onTipeChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersetujuanFilter(ThemeColors colors) {
    final filters = ['Belum Disetujui', 'Riwayat'];

    return Container(
      color: colors.background,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipe', style: AppTextStyles.caption(colors.textSecondary)),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(filters.length, (index) {
              final isSelected = _selectedPersetujuanFilter == index;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedPersetujuanFilter = index);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primaryBlue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? colors.primaryBlue : colors.divider,
                      ),
                    ),
                    child: Text(
                      filters[index],
                      style: AppTextStyles.captionMedium(
                        isSelected ? colors.primaryBlue : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    // Belum pilih tipe → tampilkan empty state
    if (_selectedTipe == null) {
      return const EmptyStateWidget(
        message: 'Pilih tipe permintaan\nuntuk melihat data',
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return EmptyStateWidget(
        message: _errorMessage!,
        icon: Icons.error_outline,
        onRetry: _fetchData,
      );
    }

    final bool isLeave = _selectedTipe == 'Permintaan Kehadiran';
    final bool isEmpty = isLeave
        ? _leaveRequests.isEmpty
        : _overtimeRequests.isEmpty;

    if (isEmpty) {
      return const EmptyStateWidget();
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 8.h),
            itemCount: isLeave
                ? _leaveRequests.length
                : _overtimeRequests.length,
            itemBuilder: (context, index) {
              if (isLeave) {
                final request = _leaveRequests[index];
                return LeaveRequestCard(
                  request: request,
                  onTap: () => _navigateToLeaveDetail(request),
                );
              } else {
                final request = _overtimeRequests[index];
                return OvertimeRequestCard(
                  request: request,
                  onTap: () => _navigateToOvertimeDetail(request),
                );
              }
            },
          ),
        ),
        if (!isEmpty)
          PaginationWidget(
            currentPage: _currentPage,
            totalPages: _totalPages,
            totalItems: _totalItems,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              _fetchData();
            },
          ),
      ],
    );
  }
}

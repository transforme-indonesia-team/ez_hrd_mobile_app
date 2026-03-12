import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/data/models/attendance_correction_model.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/models/overtime_employee_model.dart';
import 'package:hrd_app/data/services/attendance_correction_service.dart';
import 'package:hrd_app/data/services/leave_service.dart';
import 'package:hrd_app/data/services/overtime_service.dart';
import 'package:hrd_app/features/fitur/cuti/screens/detail_cuti_screen.dart';
import 'package:hrd_app/features/fitur/cuti/widgets/leave_request_card.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/detail_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/widgets/attendance_correction_card.dart';
import 'package:hrd_app/features/fitur/lembur/screens/detail_lembur_screen.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/overtime_request_card.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/pagination_widget.dart';

class PermohonanKaryawanScreen extends StatefulWidget {
  final int initialTab;
  final String? initialTipePermintaan;

  const PermohonanKaryawanScreen({
    super.key,
    this.initialTab = 0,
    this.initialTipePermintaan,
  });

  @override
  State<PermohonanKaryawanScreen> createState() =>
      _PermohonanKaryawanScreenState();
}

class _PermohonanKaryawanScreenState extends State<PermohonanKaryawanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State untuk Batch Approval
  Set<String> _selectedIds = {};
  bool _isProcessingApproval = false;

  // Dropdown — 4 tipe permintaan seperti di notification
  final List<String> _tipePermintaan = [
    'Permintaan Koreksi Kehadiran',
    'Permintaan Cuti Kehadiran',
    'Permintaan Lembur',
    'Pembatalan Cuti',
  ];
  String? _selectedTipe;

  // Sub-filter di tab Persetujuan
  int _selectedPersetujuanFilter = 0; // 0 = Belum Disetujui, 1 = Riwayat

  // Data state
  bool _isLoading = false;
  String? _errorMessage;

  // Data lists per tipe
  List<AttendanceCorrectionModel> _correctionRequests = [];
  List<LeaveEmployeeModel> _leaveRequests = [];
  List<OvertimeEmployeeModel> _overtimeRequests = [];
  List<LeaveEmployeeModel> _cancellationRequests = [];

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _selectedTipe = widget.initialTipePermintaan;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      // Re-fetch data when switching tabs (different endpoint)
      if (_selectedTipe != null) {
        setState(() {
          _currentPage = 1;
        });
        _fetchData();
      } else {
        setState(() {});
      }
    });

    if (_selectedTipe != null) {
      _fetchData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Whether we are on the "Persetujuan" tab
  bool get _isApprovalTab => _tabController.index == 1;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      switch (_selectedTipe) {
        case 'Permintaan Koreksi Kehadiran':
          await _fetchCorrectionData();
          break;
        case 'Permintaan Cuti Kehadiran':
          await _fetchLeaveData();
          break;
        case 'Permintaan Lembur':
          await _fetchOvertimeData();
          break;
        case 'Pembatalan Cuti':
          await _fetchCancellationData();
          break;
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

  // ============ Fetch methods ============

  Future<void> _fetchCorrectionData() async {
    final approvalStatus = _isApprovalTab
        ? (_selectedPersetujuanFilter == 0 ? 'UNAPPROVED' : 'HISTORY')
        : null;

    final response = _isApprovalTab
        ? await AttendanceCorrectionService().getAttendanceCorrectionApproval(
            pages: _currentPage.toString(),
            sizes: '10',
            approvalStatus: approvalStatus,
          )
        : await AttendanceCorrectionService().getAttendanceCorrection(
            pages: _currentPage.toString(),
            sizes: '10',
          );

    _handlePaginatedResponse(
      response,
      onItems: (items) {
        _correctionRequests = items
            .map(
              (e) =>
                  AttendanceCorrectionModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
      onEmpty: () => _correctionRequests = [],
    );
  }

  Future<void> _fetchLeaveData() async {
    final approvalStatus = _isApprovalTab
        ? (_selectedPersetujuanFilter == 0 ? 'UNAPPROVED' : 'HISTORY')
        : null;

    final response = _isApprovalTab
        ? await LeaveService().getLeaveEmployeeApproval(
            page: _currentPage,
            limit: 10,
            approvalStatus: approvalStatus,
          )
        : await LeaveService().getLeaveEmployee(page: _currentPage, limit: 10);

    _handlePaginatedResponse(
      response,
      onItems: (items) {
        _leaveRequests = items
            .map((e) => LeaveEmployeeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      onEmpty: () => _leaveRequests = [],
    );
  }

  Future<void> _fetchOvertimeData() async {
    final approvalStatus = _isApprovalTab
        ? (_selectedPersetujuanFilter == 0 ? 'UNAPPROVED' : 'HISTORY')
        : null;

    final response = _isApprovalTab
        ? await OvertimeService().getOvertimeEmployeeApproval(
            page: _currentPage,
            limit: 10,
            approvalStatus: approvalStatus,
          )
        : await OvertimeService().getOvertimeEmployee(
            page: _currentPage,
            limit: 10,
          );

    _handlePaginatedResponse(
      response,
      onItems: (items) {
        _overtimeRequests = items
            .map(
              (e) => OvertimeEmployeeModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
      onEmpty: () => _overtimeRequests = [],
    );
  }

  Future<void> _fetchCancellationData() async {
    final approvalStatus = _isApprovalTab
        ? (_selectedPersetujuanFilter == 0 ? 'UNAPPROVED' : 'HISTORY')
        : null;

    final response = _isApprovalTab
        ? await LeaveService().getLeaveCancellationApproval(
            page: _currentPage,
            limit: 10,
            approvalStatus: approvalStatus,
          )
        : await LeaveService().getLeaveCancellation(
            page: _currentPage,
            limit: 10,
          );

    _handlePaginatedResponse(
      response,
      onItems: (items) {
        _cancellationRequests = items
            .map((e) => LeaveEmployeeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      onEmpty: () => _cancellationRequests = [],
    );
  }

  /// Generic handler for paginated API responses
  void _handlePaginatedResponse(
    Map<String, dynamic> response, {
    required void Function(List<dynamic> items) onItems,
    required void Function() onEmpty,
  }) {
    final recordsRaw = response['original']['records'];

    if (recordsRaw == null || recordsRaw is List) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          onEmpty();
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
        onItems(items);
        _totalItems = pagination?['total_data'] as int? ?? 0;
        _totalPages = pagination?['total_pages'] as int? ?? 1;
      });
    }
  }

  // ============ Event handlers ============

  void _onTipeChanged(String? value) {
    if (value != null && value != _selectedTipe) {
      setState(() {
        _selectedTipe = value;
        _currentPage = 1;
        _correctionRequests = [];
        _leaveRequests = [];
        _overtimeRequests = [];
        _cancellationRequests = [];
        _selectedIds.clear();
      });
      _fetchData();
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        switch (_selectedTipe) {
          case 'Permintaan Koreksi Kehadiran':
            _selectedIds = _correctionRequests
                .map((e) => e.id)
                .whereType<String>()
                .toSet();
            break;
          case 'Permintaan Cuti Kehadiran':
            _selectedIds = _leaveRequests
                .map((e) => e.id)
                .whereType<String>()
                .toSet();
            break;
          case 'Permintaan Lembur':
            _selectedIds = _overtimeRequests
                .map((e) => e.id)
                .whereType<String>()
                .toSet();
            break;
          case 'Pembatalan Cuti':
            _selectedIds = _cancellationRequests
                .map((e) => e.id)
                .whereType<String>()
                .toSet();
            break;
        }
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelect(String? id) {
    if (id == null) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _handleBatchApproval(String status) async {
    if (_selectedIds.isEmpty) return;

    String remark = '';

    // Jika status bukan APPROVE (yaitu REJECT atau REVISE), tampilkan dialog alasan
    if (status != 'APPROVE') {
      final bool? isProceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final textController = TextEditingController();
          final colors = context.colors;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            backgroundColor: colors.surface,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catatan', style: AppTextStyles.h4(colors.textPrimary)),
                  SizedBox(height: 8.h),
                  Text(
                    'Berikan catatan untuk karyawan',
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.divider),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: textController,
                      maxLines: 3,
                      minLines: 1,
                      style: AppTextStyles.body(colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Masukkan alasan Anda',
                        hintStyle: AppTextStyles.body(
                          colors.textSecondary.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Batalkan',
                            style: AppTextStyles.bodyMedium(colors.primaryBlue),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            remark = textController.text.trim();
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primaryBlue,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Simpan',
                            style: AppTextStyles.bodyMedium(Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (isProceed != true) return;
    }

    setState(() => _isProcessingApproval = true);

    // Tampilkan loading spinner
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      Map<String, dynamic>? response;

      switch (_selectedTipe) {
        case 'Permintaan Koreksi Kehadiran':
          response = await AttendanceCorrectionService()
              .batchApprovalAttendanceCorrection(
                attendanceCorrectionIds: _selectedIds.toList(),
                status: status,
                remark: remark,
              );
          break;
        case 'Permintaan Cuti Kehadiran':
          response = await LeaveService().batchApprovalLeaveEmployee(
            leaveIds: _selectedIds.toList(),
            status: status,
            remark: remark,
          );
          break;
        case 'Permintaan Lembur':
          response = await OvertimeService().batchApprovalOvertime(
            overtimeIds: _selectedIds.toList(),
            status: status,
            remark: remark,
          );
          break;
        case 'Pembatalan Cuti':
          response = await LeaveService().batchApprovalLeaveCancellation(
            leaveCancellationIds: _selectedIds.toList(),
            status: status,
            remark: remark,
          );
          break;
      }

      if (mounted && response != null) {
        Navigator.pop(context); // Close loading

        final records = response['original'];
        final isSuccess = records['status'] == true || records['code'] == 200;

        if (isSuccess) {
          context.showSuccessSnackbar(
            records['message'] ?? 'Berhasil memproses data',
          );

          // Refresh list dan bersihkan seleksi
          setState(() {
            _selectedIds.clear();
          });
          _fetchData();
        } else {
          context.showErrorSnackbar(
            records['message'] ?? 'Gagal memproses data',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        context.showErrorSnackbar('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessingApproval = false);
    }
  }

  // ============ Navigation ============

  Future<void> _navigateToCorrectionDetail(
    AttendanceCorrectionModel request,
  ) async {
    if (request.id == null) return;
    final isApproval = _isApprovalTab && _selectedPersetujuanFilter == 0;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailKoreksiKehadiranScreen(
          correctionId: request.id!,
          isApprovalMode: isApproval,
        ),
      ),
    );
    if (result == true && mounted) {
      _selectedIds.clear();
      _fetchData();
    }
  }

  Future<void> _navigateToLeaveDetail(LeaveEmployeeModel request) async {
    final isApproval = _isApprovalTab && _selectedPersetujuanFilter == 0;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCutiScreen(
          detailLeave: request,
          isApprovalMode: isApproval,
          isCancellation: false,
        ),
      ),
    );
    if (result == true && mounted) {
      _selectedIds.clear();
      _fetchData();
    }
  }

  Future<void> _navigateToOvertimeDetail(OvertimeEmployeeModel request) async {
    final isApproval = _isApprovalTab && _selectedPersetujuanFilter == 0;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailLemburScreen(
          detailOvertime: request,
          isApprovalMode: isApproval,
        ),
      ),
    );

    if (result == true && mounted) {
      _selectedIds.clear(); // Bersihkan seleksi jika refresh
      _fetchData();
    }
  }

  Future<void> _navigateToCancellationDetail(LeaveEmployeeModel request) async {
    final isApproval = _isApprovalTab && _selectedPersetujuanFilter == 0;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCutiScreen(
          detailLeave: request,
          isApprovalMode: isApproval,
          isCancellation: true,
        ),
      ),
    );
    if (result == true && mounted) {
      _selectedIds.clear();
      _fetchData();
    }
  }

  // ============ Build methods ============

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
      bottomNavigationBar: _buildBatchApprovalBottomBar(colors),
    );
  }

  Widget _buildBatchApprovalBottomBar(ThemeColors colors) {
    // Tampilkan hanya jika di tab persetujuan, belum disetujui, dan ada yang dipilih
    if (!_isApprovalTab ||
        _selectedPersetujuanFilter != 0 ||
        _selectedIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: colors.primaryBlue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '${_selectedIds.length} item(s) selected',
                style: AppTextStyles.bodyMedium(colors.primaryBlue),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Button Reject (X)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.divider),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: IconButton(
                  onPressed: _isProcessingApproval
                      ? null
                      : () => _handleBatchApproval('REJECT'),
                  icon: Icon(Icons.close, color: Colors.red, size: 24.sp),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Button Revisi
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: _isProcessingApproval
                      ? null
                      : () => _handleBatchApproval('REVISE'),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: colors.primaryBlue,
                    size: 18.sp,
                  ),
                  label: Text(
                    'Revisi',
                    style: AppTextStyles.bodyMedium(colors.primaryBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: colors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Button Menyetujui
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isProcessingApproval
                      ? null
                      : () => _handleBatchApproval('APPROVE'),
                  icon: Icon(Icons.check, color: Colors.white, size: 18.sp),
                  label: Text(
                    'Menyetujui',
                    style: AppTextStyles.bodyMedium(Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
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
                    if (_selectedPersetujuanFilter != index) {
                      setState(() {
                        _selectedPersetujuanFilter = index;
                        _currentPage = 1;
                        _correctionRequests = [];
                        _leaveRequests = [];
                        _overtimeRequests = [];
                        _cancellationRequests = [];
                        _selectedIds.clear();
                      });
                      if (_selectedTipe != null) {
                        _fetchData();
                      }
                    }
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

    // Get appropriate list based on selected type
    final (bool isEmpty, int itemCount) = _getListInfo();

    if (isEmpty) {
      return const EmptyStateWidget();
    }

    return Column(
      children: [
        if (_isApprovalTab && _selectedPersetujuanFilter == 0 && !isEmpty)
          _buildSelectAllRow(colors),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 8.h),
            itemCount: itemCount,
            itemBuilder: (context, index) => _buildCard(index),
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

  /// Returns (isEmpty, itemCount) based on selected type
  (bool, int) _getListInfo() {
    switch (_selectedTipe) {
      case 'Permintaan Koreksi Kehadiran':
        return (_correctionRequests.isEmpty, _correctionRequests.length);
      case 'Permintaan Cuti Kehadiran':
        return (_leaveRequests.isEmpty, _leaveRequests.length);
      case 'Permintaan Lembur':
        return (_overtimeRequests.isEmpty, _overtimeRequests.length);
      case 'Pembatalan Cuti':
        return (_cancellationRequests.isEmpty, _cancellationRequests.length);
      default:
        return (true, 0);
    }
  }

  Widget _buildSelectAllRow(ThemeColors colors) {
    bool isAllSelected = false;

    switch (_selectedTipe) {
      case 'Permintaan Koreksi Kehadiran':
        isAllSelected =
            _correctionRequests.isNotEmpty &&
            _correctionRequests.every(
              (item) => item.id != null && _selectedIds.contains(item.id),
            );
        break;
      case 'Permintaan Cuti Kehadiran':
        isAllSelected =
            _leaveRequests.isNotEmpty &&
            _leaveRequests.every((item) => _selectedIds.contains(item.id));
        break;
      case 'Permintaan Lembur':
        isAllSelected =
            _overtimeRequests.isNotEmpty &&
            _overtimeRequests.every((item) => _selectedIds.contains(item.id));
        break;
      case 'Pembatalan Cuti':
        isAllSelected =
            _cancellationRequests.isNotEmpty &&
            _cancellationRequests.every(
              (item) => _selectedIds.contains(item.id),
            );
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: colors.background,
      child: Row(
        children: [
          Checkbox(
            value: isAllSelected,
            onChanged: _toggleSelectAll,
            activeColor: colors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            side: BorderSide(
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: Text(
              'Pilih Semua',
              style: AppTextStyles.bodyMedium(colors.textPrimary),
            ),
          ),
          if (_selectedIds.isNotEmpty)
            Text(
              '${_selectedIds.length} Terpilih',
              style: AppTextStyles.bodyMedium(colors.primaryBlue),
            ),
        ],
      ),
    );
  }

  /// Build the correct card widget based on selected type
  Widget _buildCard(int index) {
    final isApprovalMode = _isApprovalTab && _selectedPersetujuanFilter == 0;

    switch (_selectedTipe) {
      case 'Permintaan Koreksi Kehadiran':
        final request = _correctionRequests[index];
        return AttendanceCorrectionCard(
          request: request,
          isApprovalMode: isApprovalMode,
          isSelected: request.id != null
              ? _selectedIds.contains(request.id)
              : false,
          onSelectChanged: isApprovalMode
              ? (val) => _toggleSelect(request.id)
              : null,
          onTap: () => _navigateToCorrectionDetail(request),
        );
      case 'Permintaan Cuti Kehadiran':
        final request = _leaveRequests[index];
        return LeaveRequestCard(
          request: request,
          isApprovalMode: isApprovalMode,
          isSelected: _selectedIds.contains(request.id),
          onSelectChanged: isApprovalMode
              ? (val) => _toggleSelect(request.id)
              : null,
          onTap: () => _navigateToLeaveDetail(request),
        );
      case 'Permintaan Lembur':
        final request = _overtimeRequests[index];
        return OvertimeRequestCard(
          request: request,
          isApprovalMode: isApprovalMode,
          isSelected: _selectedIds.contains(request.id),
          onSelectChanged: isApprovalMode
              ? (val) => _toggleSelect(request.id)
              : null,
          onTap: () => _navigateToOvertimeDetail(request),
        );
      case 'Pembatalan Cuti':
        final request = _cancellationRequests[index];
        return LeaveRequestCard(
          request: request,
          isApprovalMode: isApprovalMode,
          isSelected: _selectedIds.contains(request.id),
          onSelectChanged: isApprovalMode
              ? (val) => _toggleSelect(request.id)
              : null,
          onTap: () => _navigateToCancellationDetail(request),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

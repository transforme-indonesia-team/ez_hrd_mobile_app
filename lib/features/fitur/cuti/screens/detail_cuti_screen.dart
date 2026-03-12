import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/services/leave_service.dart';
import 'package:hrd_app/features/fitur/cuti/screens/form_permintaan_cuti.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/detail_lembur_widgets.dart';

class DetailCutiScreen extends StatefulWidget {
  final LeaveEmployeeModel? detailLeave;
  final bool isApprovalMode;
  final bool isCancellation;

  const DetailCutiScreen({
    super.key,
    this.detailLeave,
    this.isApprovalMode = false,
    this.isCancellation = false,
  });

  @override
  State<DetailCutiScreen> createState() => _DetailCutiScreenState();
}

class _DetailCutiScreenState extends State<DetailCutiScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isProcessingApproval = false;
  String? _errorMessage;
  LeaveEmployeeModel? _detailData;
  List<ApproverModel> _approverList = [];
  List<ApproverModel> _historyApproverList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await LeaveService().getDetailLeaveEmployee(
        leaveId: widget.detailLeave!.id,
      );

      Map<String, dynamic>? records;
      if (response.containsKey('original')) {
        records = response['original'] as Map<String, dynamic>?;
      } else {
        records = response;
      }

      if (records == null) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Data tidak ditemukan';
            _isLoading = false;
          });
        }
        return;
      }

      // Get the actual data - handle multiple response formats
      Map<String, dynamic>? data;
      List<dynamic>? approverRequest;

      if (records.containsKey('records') && records['records'] != null) {
        final recordsValue = records['records'];

        // Case 1: records is a List (e.g., [{...}])
        if (recordsValue is List && recordsValue.isNotEmpty) {
          data = recordsValue.first as Map<String, dynamic>;
          approverRequest = data['approver_request'] as List<dynamic>?;
        }
        // Case 2: records is a Map with 'data' key
        else if (recordsValue is Map<String, dynamic>) {
          if (recordsValue.containsKey('data') &&
              recordsValue['data'] != null) {
            data = recordsValue['data'] as Map<String, dynamic>;
            approverRequest =
                recordsValue['approver_request'] as List<dynamic>?;
          }
          // Case 3: records is a Map with 'id' key (data directly)
          else if (recordsValue.containsKey('id')) {
            data = recordsValue;
            approverRequest =
                recordsValue['approver_request'] as List<dynamic>?;
          }
        }
      } else if (records.containsKey('id')) {
        data = records;
        approverRequest = records['approver_request'] as List<dynamic>?;
      }

      if (data == null) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Data tidak ditemukan';
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _detailData = LeaveEmployeeModel.fromJson(data!);
          _approverList = _parseApproverList(
            approverRequest ?? data['approver_request'],
          );
          // Parse history_approver from data level
          _historyApproverList = _parseApproverList(data['history_approver']);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching detail cuti: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Terjadi kesalahan saat memuat data: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<ApproverModel> _parseApproverList(dynamic approverData) {
    if (approverData == null || approverData is! List) return [];
    return approverData
        .map((e) => ApproverModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Helper to sanitize photo URL - treats '-' as null
  String? _sanitizePhotoUrl(String? url) {
    if (url == null || url.isEmpty || url == '-') return null;
    return url;
  }

  /// Helper to sanitize name - treats null or '-' as '-'
  String _sanitizeName(String? name) {
    if (name == null || name.isEmpty || name == '-') return '-';
    return name;
  }

  Future<void> _cancelLeave() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await LeaveService().cancellationLeaveEmployee(
        leaveId: widget.detailLeave!.id,
      );

      if (mounted) Navigator.pop(context);

      final records = response['original'];
      final isSuccess = records['status'] == true || records['code'] == 200;

      if (isSuccess) {
        if (mounted) {
          context.showSuccessSnackbar(
            records['message'] ?? 'Cuti berhasil dibatalkan',
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          context.showErrorSnackbar(
            records['message'] ?? 'Gagal membatalkan cuti',
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        context.showErrorSnackbar('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rincian Riwayat Cuti',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: _buildContent(colors),
      bottomNavigationBar: _isLoading || _hasError || _detailData == null
          ? null
          : (widget.isApprovalMode
                ? _buildApprovalBottomBar(colors, _detailData!)
                : _buildCancelButton(colors, _detailData!)),
    );
  }

  Future<void> _handleApproval(String status) async {
    String remark = '';

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

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      Map<String, dynamic> response;
      if (widget.isCancellation) {
        response = await LeaveService().approvalLeaveCancellation(
          leaveCancellationId: widget.detailLeave!.id,
          status: status,
          remark: remark,
        );
      } else {
        response = await LeaveService().approvalLeaveEmployee(
          leaveId: widget.detailLeave!.id,
          status: status,
          remark: remark,
        );
      }

      if (mounted) {
        Navigator.pop(context); // Close loading

        final records = response['original'];
        final isSuccess = records['status'] == true || records['code'] == 200;

        if (isSuccess) {
          context.showSuccessSnackbar(
            records['message'] ?? 'Berhasil memproses data',
          );

          Navigator.pop(context, true); // true = refresh list
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

  Widget _buildApprovalBottomBar(ThemeColors colors, LeaveEmployeeModel data) {
    if (data.displayStatus.toUpperCase() != 'UNVERIFIED' &&
        data.displayStatus.toUpperCase() != 'PENDING') {
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
      child: SafeArea(
        child: Row(
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
                    : () => _handleApproval('REJECT'),
                icon: Icon(Icons.close, color: Colors.red, size: 24.sp),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
            ),
            SizedBox(width: 12.w),
            // Button Revisi
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: _isProcessingApproval
                    ? null
                    : () => _handleApproval('REVISE'),
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
                    : () => _handleApproval('APPROVE'),
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
      ),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    if (_isLoading) {
      return _buildSkeletonBody(colors);
    }

    if (_hasError || _detailData == null) {
      return EmptyStateWidget(
        message: _errorMessage ?? 'Data tidak tersedia',
        icon: Icons.error_outline,
      );
    }

    return _buildBody(colors);
  }

  Widget _buildSkeletonBody(ThemeColors colors) {
    return SkeletonContainer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LabelValueColumnSkeleton(valueWidth: 160),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: UserInfoItemSkeleton()),
                SizedBox(width: 12.w),
                const Expanded(child: UserInfoItemSkeleton()),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: LabelValueColumnSkeleton(valueWidth: 100),
                ),
                SizedBox(width: 12.w),
                const Expanded(
                  child: LabelValueColumnSkeleton(valueWidth: 100),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: LabelValueColumnSkeleton(valueWidth: 80)),
                SizedBox(width: 12.w),
                const Expanded(child: LabelValueColumnSkeleton(valueWidth: 40)),
              ],
            ),
            SizedBox(height: 24.h),
            Container(
              width: 120.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 12.h),
            const ApprovalListItemSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    final data = _detailData!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            color: colors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor Permintaan & Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabelValueColumn(
                        label: 'Nomor Permintaan',
                        value: data.displayRequestNo,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 6.h),
                        _buildStatusBadge(colors, data.displayStatus),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Permintaan untuk & Permintaan Oleh
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: UserInfoItem(
                        label: 'Permintaan untuk',
                        name: data.displayEmployeeName,
                        role: 'EMPLOYEE',
                        photoUrl: _sanitizePhotoUrl(data.profile),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: UserInfoItem(
                        label: 'Permintaan Oleh',
                        name: _sanitizeName(data.createdBy),
                        role: 'CREATOR',
                        photoUrl: _sanitizePhotoUrl(data.createdByPhoto),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Tanggal Mulai & Tanggal Berakhir
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabelValueColumn(
                        label: 'Tanggal Mulai',
                        value: data.startLeave != null
                            ? FormatDate.fullDate(
                                DateTime.parse(data.startLeave!),
                              )
                            : '-',
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          size: 14.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: LabelValueColumn(
                        label: 'Tanggal Berakhir',
                        value: data.endLeave != null
                            ? FormatDate.fullDate(
                                DateTime.parse(data.endLeave!),
                              )
                            : '-',
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          size: 14.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Jenis Cuti & Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabelValueColumn(
                        label: 'Jenis Cuti',
                        value: data.displayLeaveTypeName,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: LabelValueColumn(
                        label: 'Total Hari',
                        value: data.displayTotalDays,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Keterangan
                LabelValueColumn(
                  label: 'Keterangan',
                  value: data.displayRemark,
                  fontSize: 12.sp,
                ),
                SizedBox(height: 16.h),

                // Saldo Cuti
                LabelValueColumn(
                  label: 'Saldo Cuti Tersisa',
                  value: data.displayRemainingLeave,
                  fontSize: 13.sp,
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Daftar Persetujuan Section
          _buildApprovalSection(colors),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeColors colors, String status) {
    final statusUpper = status.toUpperCase();

    // Convert status to readable format: PARTIALLY_APPROVED -> Partially Approved
    String label = status
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');

    final (Color backgroundColor, Color textColor) = switch (statusUpper) {
      'UNVERIFIED' => (const Color(0xFFE0E7FF), const Color(0xFF4338CA)),
      'PENDING' => (const Color(0xFFFFF3CD), const Color(0xFFD68910)),
      _ when statusUpper.contains('WAITING') => (
        const Color(0xFFFFF3CD),
        const Color(0xFFD68910),
      ),
      _ when statusUpper.contains('APPROVE') => (
        const Color(0xFFD4EDDA),
        const Color(0xFF28A745),
      ),
      _ when statusUpper.contains('REJECT') => (
        const Color(0xFFF8D7DA),
        const Color(0xFFDC3545),
      ),
      _ when statusUpper.contains('CANCEL') => (
        const Color(0xFFF8D7DA),
        const Color(0xFFDC3545),
      ),
      _ => (colors.divider, colors.textSecondary),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(label, style: AppTextStyles.caption(textColor)),
    );
  }

  Widget _buildApprovalSection(ThemeColors colors) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daftar Persetujuan",
            style: AppTextStyles.h4(colors.textPrimary),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Modern pill-style tab bar
                Container(
                  margin: EdgeInsets.all(8.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: colors.divider.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: colors.textSecondary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: colors.primaryBlue,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelStyle: AppTextStyles.bodySemiBold(
                      Colors.white,
                      fontSize: 12.sp,
                    ),
                    unselectedLabelStyle: AppTextStyles.body(
                      colors.textSecondary,
                      fontSize: 12.sp,
                    ),
                    tabs: [
                      Tab(
                        height: 36.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.approval, size: 16.sp),
                            SizedBox(width: 6.w),
                            const Text('Persetujuan'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 36.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 16.sp),
                            SizedBox(width: 6.w),
                            const Text('Riwayat'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height:
                      (_approverList.length > _historyApproverList.length
                              ? _approverList.length
                              : _historyApproverList.length)
                          .clamp(1, 5) *
                      80.h,
                  child: TabBarView(
                    children: [
                      _buildApproverList(_approverList, colors),
                      _buildApproverList(_historyApproverList, colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApproverList(List<ApproverModel> approvers, ThemeColors colors) {
    if (approvers.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Belum ada data',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      itemCount: approvers.length,
      itemBuilder: (context, index) {
        final approver = approvers[index];
        return ApprovalListItem(
          name: approver.displayApproverName,
          role: approver.approverPosisition,
          status: _getStatusLabel(approver.statusApproval),
          statusColor: _getStatusColor(approver.statusApproval),
          photoUrl: approver.approverProfile,
          date: FormatDate.fromStringWithTime(approver.approvalAt),
          remark: approver.remarkLeaveEmployee,
        );
      },
    );
  }

  String _getStatusLabel(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVE':
        return 'Mengetahui';
      case 'PENDING':
        return 'Menunggu';
      case 'REJECT':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVE':
        return ColorPalette.green600;
      case 'PENDING':
        return ColorPalette.orange500;
      case 'REJECT':
        return ColorPalette.red500;
      default:
        return ColorPalette.orange500;
    }
  }

  bool _canCancel(LeaveEmployeeModel data) {
    final status = data.status?.toUpperCase();
    return status == 'UNVERIFIED' || status == 'PENDING';
  }

  Widget _buildCancelButton(ThemeColors colors, LeaveEmployeeModel data) {
    final status = data.status?.toUpperCase();
    final canCancel = status == 'UNVERIFIED' || status == 'PENDING';
    final isRevised = status == 'REVISE' || status == 'REVISED';

    if (!canCancel && !isRevised) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: (isRevised && !widget.isCancellation)
            ? Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: () => _showCancelConfirmation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.red500,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Batalkan',
                          style: AppTextStyles.bodySemiBold(Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormPermintaanCutiScreeen(
                                existingLeave: data,
                              ),
                            ),
                          );
                          if (result == true && mounted) {
                            _fetchData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Ubah',
                          style: AppTextStyles.bodySemiBold(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => _showCancelConfirmation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.red500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Batalkan',
                    style: AppTextStyles.bodySemiBold(Colors.white),
                  ),
                ),
              ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Cuti'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan permintaan cuti ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              _cancelLeave();
              Navigator.pop(context);
            },
            child: Text('Ya', style: TextStyle(color: ColorPalette.red500)),
          ),
        ],
      ),
    );
  }
}

/// Model untuk Approver
class ApproverModel {
  final String? approverId;
  final String? userName;
  final String? jobGradeName;
  final String? positionOrganizationName;
  final String? statusLeaveEmployee;
  final String? remarkLeaveEmployee;
  final String? approvalAt;
  final String? approverProfile;

  ApproverModel({
    this.approverId,
    this.userName,
    this.jobGradeName,
    this.positionOrganizationName,
    this.statusLeaveEmployee,
    this.remarkLeaveEmployee,
    this.approvalAt,
    this.approverProfile,
  });

  factory ApproverModel.fromJson(Map<String, dynamic> json) {
    return ApproverModel(
      approverId: json['approver_id'] as String?,
      // Handle both field name formats
      userName: (json['user_name'] ?? json['approver_name']) as String?,
      jobGradeName: json['job_grade_name'] as String?,
      positionOrganizationName:
          (json['position_organization_name'] ?? json['approver_position'])
              as String?,
      statusLeaveEmployee:
          (json['status_leave_employee'] ?? json['status_approval']) as String?,
      remarkLeaveEmployee: json['remark_leave_employee'] as String?,
      approvalAt: json['approval_at'] as String?,
      approverProfile: json['approver_profile'] as String?,
    );
  }

  String get displayApproverName => userName ?? '-';
  String get approverPosisition => positionOrganizationName ?? '-';
  String? get statusApproval => statusLeaveEmployee;
}

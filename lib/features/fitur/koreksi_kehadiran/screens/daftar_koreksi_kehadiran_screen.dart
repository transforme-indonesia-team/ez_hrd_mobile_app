import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/data/models/attendance_correction_model.dart';
import 'package:hrd_app/data/services/attendance_correction_service.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/widgets/attendance_correction_card.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/widgets/koreksi_filter_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/detail_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/form_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/pagination_widget.dart';

class DaftarKoreksiKehadiranScreen extends StatefulWidget {
  const DaftarKoreksiKehadiranScreen({super.key});

  @override
  State<DaftarKoreksiKehadiranScreen> createState() =>
      _DaftarKoreksiKehadiranScreenState();
}

class _DaftarKoreksiKehadiranScreenState
    extends State<DaftarKoreksiKehadiranScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceCorrectionModel> _requests = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // Filter state
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await AttendanceCorrectionService()
          .getAttendanceCorrection(
            pages: _currentPage.toString(),
            sizes: '10',
            startDate: _filterStartDate != null
                ? FormatDate.apiFormat(_filterStartDate!)
                : null,
            endDate: _filterEndDate != null
                ? FormatDate.apiFormat(_filterEndDate!)
                : null,
            status: _filterStatus,
          );

      final recordsRaw = response['original']['records'];

      // Handle case where records is empty list [] instead of Map
      if (recordsRaw == null || recordsRaw is List) {
        setState(() {
          _isLoading = false;
          _requests = [];
          _totalItems = 0;
          _totalPages = 1;
          _errorMessage = null;
        });
        return;
      }

      final records = recordsRaw as Map<String, dynamic>;
      final items = records['items'] as List<dynamic>? ?? [];
      final pagination = records['pagination'] as Map<String, dynamic>?;

      setState(() {
        _requests = items
            .map(
              (e) =>
                  AttendanceCorrectionModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        _totalItems = pagination?['total_data'] as int? ?? 0;
        _totalPages = pagination?['total_pages'] as int? ?? 1;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Error fetching attendance correction list: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan saat memuat data';
        });
      }
    }
  }

  bool get _hasActiveFilters =>
      _filterStartDate != null ||
      _filterEndDate != null ||
      _filterStatus != null;

  void _showFilter() {
    KoreksiFilterBottomSheet.show(
      context,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      status: _filterStatus,
      onApply: (result) {
        setState(() {
          _filterStartDate = result.startDate;
          _filterEndDate = result.endDate;
          _filterStatus = result.status;
          _currentPage = 1;
        });
        _fetchData();
      },
    );
  }

  Future<void> _navigateToForm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const FormKoreksiKehadiranScreen(),
      ),
    );
    if (result == true && mounted) {
      _currentPage = 1;
      _fetchData();
    }
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
          'Daftar Koreksi Kehadiran',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.filter_alt_outlined,
                  color: colors.textPrimary,
                ),
                onPressed: () => _showFilter(),
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: colors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(colors),
      bottomNavigationBar: _buildBottomButton(colors),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: colors.divider),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              style: AppTextStyles.body(colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: _fetchData,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primaryBlue,
                side: BorderSide(color: colors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _requests.isEmpty
              ? _buildEmptyState(colors)
              : RefreshIndicator(
                  onRefresh: () async {
                    _currentPage = 1;
                    await _fetchData();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      return AttendanceCorrectionCard(
                        request: _requests[index],
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailKoreksiKehadiranScreen(
                                    correctionId: _requests[index].id ?? '',
                                  ),
                            ),
                          );
                          if (result == true && mounted) {
                            _fetchData();
                          }
                        },
                      );
                    },
                  ),
                ),
        ),
        if (_requests.isNotEmpty)
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

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80.sp, color: colors.divider),
          SizedBox(height: 16.h),
          Text(
            'Belum ada permintaan\nkoreksi kehadiran',
            textAlign: TextAlign.center,
            style: AppTextStyles.h4(colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _navigateToForm,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Permintaan Baru',
            style: AppTextStyles.button(Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/overtime_request_model.dart';
import 'package:hrd_app/features/fitur/lembur/screens/form_lembur_screen.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/lembur_filter_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/overtime_request_card.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/pagination_widget.dart';

class DaftarLemburScreen extends StatefulWidget {
  const DaftarLemburScreen({super.key});

  @override
  State<DaftarLemburScreen> createState() => _DaftarLemburScreenState();
}

class _DaftarLemburScreenState extends State<DaftarLemburScreen> {
  final bool _isLoading = false;
  List<OvertimeRequestModel> _requests = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Dummy data untuk testing UI
    setState(() {
      _requests = [
        const OvertimeRequestModel(
          id: '1',
          requestNumber: 'CO4-OVR-202601-016478',
          description: 'rest',
          startDate: '14 Jan 2026',
          endDate: '14 Jan 2026',
          status: 'Belum diverifikasi',
          cancellation: '-',
          overtimeType: 'Jam Lembur',
        ),
      ];
      _totalItems = 1;
      _totalPages = 1;
    });
  }

  void _showFilterBottomSheet() {
    LemburFilterBottomSheet.show(
      context,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      onApply: (startDate, endDate) {
        setState(() {
          _filterStartDate = startDate;
          _filterEndDate = endDate;
        });
        // TODO: Apply filter to API call
      },
    );
  }

  void _navigateToForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormLemburScreen()),
    );
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
          'Daftar Lembur',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _hasActiveFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _hasActiveFilter ? colors.primaryBlue : colors.textPrimary,
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _requests.isEmpty
                      ? _buildEmptyState(colors)
                      : ListView.builder(
                          padding: EdgeInsets.only(top: 8.h),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            return OvertimeRequestCard(
                              request: _requests[index],
                              onTap: () {
                                // TODO: Navigate to detail
                              },
                            );
                          },
                        ),
                ),
                if (_requests.isNotEmpty)
                  PaginationWidget(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    totalItems: _totalItems,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                      // TODO: Load page data
                    },
                  ),
              ],
            ),
      bottomNavigationBar: _buildBottomButton(colors),
    );
  }

  bool get _hasActiveFilter =>
      _filterStartDate != null || _filterEndDate != null;

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80.sp, color: colors.divider),
          SizedBox(height: 16.h),
          Text(
            'Belum ada permintaan lembur',
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

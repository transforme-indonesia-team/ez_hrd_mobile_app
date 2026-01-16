import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class RekamMedisScreen extends StatefulWidget {
  const RekamMedisScreen({super.key});

  @override
  State<RekamMedisScreen> createState() => _RekamMedisScreenState();
}

class _RekamMedisScreenState extends State<RekamMedisScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Simulasi Fetch API
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _data = {
          // Data Rekam Medis
          'tinggi': '-',
          'berat': '-',
          'golongan_darah': '-',
          'ukuran_kepala': '-',
          'ukuran_baju': '-',
          'ukuran_celana': '-',

          // Laporan Medis
          'memiliki_disabilitas': '-',
          'test_kesehatan': false,
          'alasan_test_medis': '-',
          'alasan_dirawat_dirumah_sakit': '-',
          'kondisi_medis_harus_diperhatikan': 'Tidak ada',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rekam Medis',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: _isLoading ? _buildSkeletonLoading() : _buildContent(colors),
      ),
    );
  }

  Widget _buildContent(dynamic colors) {
    return Column(
      children: [
        // SECTION 1: Rekam Medis
        _buildSectionCard(
          colors,
          title: 'Rekam Medis',
          subtitle: 'Anda dapat mengubah informasi dasar anda di sini',
          children: [
            _buildInfoRow(colors, 'Tinggi (CM)', _data?['tinggi']),
            _buildInfoRow(colors, 'Berat (KG)', _data?['berat']),
            _buildInfoRow(colors, 'Golongan Darah', _data?['golongan_darah']),
            Divider(color: colors.divider, thickness: 1.h, height: 0),
            _buildInfoRow(colors, 'Ukuran Kepala', _data?['ukuran_kepala']),
            _buildInfoRow(colors, 'Ukuran Baju', _data?['ukuran_baju']),
            _buildInfoRow(colors, 'Ukuran Celana', _data?['ukuran_celana']),
          ],
        ),
        SizedBox(height: 16.h),

        // SECTION 2: Laporan Medis
        _buildSectionCard(
          colors,
          title: 'Laporan Medis',
          subtitle: 'Siapkan laporan medis di sini',
          childrenSpacing: 16.h,
          children: [
            _buildInfoRow(
              colors,
              'Memiliki Disabilitas',
              _data?['memiliki_disabilitas'],
            ),
            _buildInfoRow(
              colors,
              'Test Kesehatan',
              _data?['test_kesehatan'] == true ? 'Ya' : 'Tidak',
            ),
            Divider(color: colors.divider, thickness: 1.h, height: 0),
            _buildInfoRow(
              colors,
              'Alasan Test Medis',
              _data?['alasan_test_medis'],
            ),
            _buildInfoRow(
              colors,
              'Alasan Dirawat Dirumah Sakit',
              _data?['alasan_dirawat_dirumah_sakit'],
            ),
            _buildInfoRow(
              colors,
              'Kondisi Medis Harus Diperhatikan',
              _data?['kondisi_medis_harus_diperhatikan'],
            ),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSectionCard(
    dynamic colors, {
    required String title,
    required String subtitle,
    required List<Widget> children,
    double? childrenSpacing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySemiBold(colors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: AppTextStyles.caption(colors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: childrenSpacing ?? 0,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    dynamic colors,
    String label,
    String? value, {
    String? note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium(colors.textPrimary),
        ),
        SizedBox(height: 4.h),
        Text(
          value ?? '-',
          style: AppTextStyles.body(colors.textPrimary),
        ),
        if (note != null) ...[
          SizedBox(height: 4.h),
          Text(
            note,
            style: AppTextStyles.caption(colors.textSecondary),
          ),
        ],
        // SizedBox(height: 8.h),
      ],
    );
  }

  // --- SKELETON WIDGETS ---

  Widget _buildSkeletonLoading() {
    return Column(
      children: [
        _buildSkeletonCard(3),
        SizedBox(height: 16.h),
        _buildSkeletonCard(6),
      ],
    );
  }

  Widget _buildSkeletonCard(int itemCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.colors.divider),
      ),
      child: Shimmer.fromColors(
        baseColor: context.colors.divider,
        highlightColor: context.colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Skeleton
            Container(
              width: 150.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            // Subtitle Skeleton
            Container(
              width: 250.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 24.h),
            // Items
            ...List.generate(itemCount, (index) => _buildSkeletonItem()),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ), // Label
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ), // Value
        ],
      ),
    );
  }
}

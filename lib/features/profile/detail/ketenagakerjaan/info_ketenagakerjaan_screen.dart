import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class InfoKetenagakerjaanScreen extends StatefulWidget {
  const InfoKetenagakerjaanScreen({super.key});

  @override
  State<InfoKetenagakerjaanScreen> createState() =>
      _InfoKetenagakerjaanScreenState();
}

class _InfoKetenagakerjaanScreenState extends State<InfoKetenagakerjaanScreen> {
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
          'nomor_karyawan': '90035857',
          'status_karyawan': 'AKTIF',
          'tingkat_jabatan': 'PETUGAS LAPANGAN',
          'tanggal_bergabung': '25 Agustus 2022',
          'tanggal_akhir_karyawan': '25 Agustus 2027',
          'lokasi_kerja': 'LOKASI BARU PARKIR',
          'atasan_langsung': 'LUHUT',
          'manager_langsung': 'XI JINPING',
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
          'Informasi Ketenagakerjaan',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
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
        // SECTION 1: Data Ketenagakerjaan
        _buildSectionCard(
          colors,
          title: 'Data Ketenagakerjaan',
          subtitle: 'Informasi data Anda terkait dengan perusahaan',
          childrenSpacing: 16.h,
          children: [
            _buildInfoRow(colors, 'No. Karyawan', _data?['nomor_karyawan']),
            _buildInfoRow(colors, 'Status Karyawan', _data?['status_karyawan']),
            _buildInfoRow(colors, 'Tingkat Jabatan', _data?['tingkat_jabatan']),
            _buildInfoRow(
              colors,
              'Tanggal Bergabung',
              _data?['tanggal_bergabung'],
            ),
            _buildInfoRow(
              colors,
              'Tanggal Akhir Karyawan',
              _data?['tanggal_akhir_karyawan'],
            ),
            _buildInfoRow(colors, 'Lokasi Kerja', _data?['lokasi_kerja']),
            _buildInfoRow(colors, 'Atasan Langsung', _data?['atasan_langsung']),
            _buildInfoRow(
              colors,
              'Manager Langsung',
              _data?['manager_langsung'],
            ),
          ],
        ),
        SizedBox(height: 20.h),
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
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: colors.textPrimary,
              fontWeight: FontWeight.w300,
            ),
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
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value ?? '-',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: colors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (note != null) ...[
          SizedBox(height: 4.h),
          Text(
            note,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: colors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
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

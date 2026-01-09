import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class InformasiDasarScreen extends StatefulWidget {
  const InformasiDasarScreen({super.key});

  @override
  State<InformasiDasarScreen> createState() => _InformasiDasarScreenState();
}

class _InformasiDasarScreenState extends State<InformasiDasarScreen> {
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
        // Dummy data sesuai screenshot
        _data = {
          // Data Ketenagakerjaan
          'nama_pengguna': '90035857',

          // Data Personal
          'nama_lengkap': 'DANY TRANSFORME',
          'nama_lokal': 'Local First Name Local Middle Name Local Last Name',
          'nama_panggilan': '-',
          'tempat_lahir': 'JAKARTA',
          'tanggal_lahir': '3 Juni 2007',
          'usia': '18 tahun 7 bulan',
          'agama': 'Islam',
          'status_perkawinan': '-',
          'jenis_kelamin': 'Pria',
          'kewarganegaraan': 'Indonesia',
          'dialek': '-',
          'ras': '-',

          // Dokumen Negara
          'nomor_id': '3654123456781236',
          'tanggal_berakhir_id': '-',
          'nama_terdaftar_pajak': '-',
          'nomor_berkas_pajak': '-',
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
          'Informasi Dasar',
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
          children: [
            _buildInfoRow(
              colors,
              'Nama Pengguna',
              _data?['nama_pengguna'],
              note: 'Nama Pengguna akan digunakan untuk login',
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // SECTION 2: Data Personal
        _buildSectionCard(
          colors,
          title: 'Data Personal',
          subtitle: 'Detail data pribadi Anda',
          childrenSpacing: 16.h,
          children: [
            _buildInfoRow(colors, 'Nama Lengkap', _data?['nama_lengkap']),
            _buildInfoRow(colors, 'Nama Lokal', _data?['nama_lokal']),
            _buildInfoRow(colors, 'Nama panggilan', _data?['nama_panggilan']),
            Divider(color: colors.divider, thickness: 1.h, height: 0),
            _buildInfoRow(colors, 'Tempat Lahir', _data?['tempat_lahir']),
            _buildInfoRow(colors, 'Tanggal Lahir', _data?['tanggal_lahir']),
            _buildInfoRow(colors, 'Usia', _data?['usia']),
            _buildInfoRow(colors, 'Agama', _data?['agama']),
            _buildInfoRow(
              colors,
              'Status Perkawinan',
              _data?['status_perkawinan'],
            ),
            _buildInfoRow(colors, 'Jenis Kelamin', _data?['jenis_kelamin']),
            Divider(color: colors.divider, thickness: 1.h, height: 0),
            _buildInfoRow(colors, 'Kewarganegaraan', _data?['kewarganegaraan']),
            _buildInfoRow(colors, 'Dialek', _data?['dialek']),
            _buildInfoRow(colors, 'Ras', _data?['ras']),
          ],
        ),
        SizedBox(height: 16.h),

        // SECTION 3: Dokumen Negara
        _buildSectionCard(
          colors,
          title: 'Dokumen Negara',
          subtitle: 'Dokumen yang terkait dengan negara',
          childrenSpacing: 16.h,
          children: [
            _buildInfoRow(colors, 'Nomor ID', _data?['nomor_id']),
            _buildInfoRow(
              colors,
              'Tanggal Berakhir ID',
              _data?['tanggal_berakhir_id'],
            ),
            Divider(color: colors.divider, thickness: 1.h, height: 0),
            _buildInfoRow(
              colors,
              'Nama Terdaftar Pajak',
              _data?['nama_terdaftar_pajak'],
            ),
            _buildInfoRow(
              colors,
              'Nomor Berkas Pajak',
              _data?['nomor_berkas_pajak'],
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/data/models/user_model.dart';
import 'package:provider/provider.dart';

class InformasiDasarScreen extends StatelessWidget {
  const InformasiDasarScreen({super.key});

  String _calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) return '-';

    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();

      int years = now.year - dob.year;
      int months = now.month - dob.month;

      if (months < 0 || (months == 0 && now.day < dob.day)) {
        years--;
        months += 12;
      }
      if (now.day < dob.day) {
        months--;
      }

      if (years > 0 && months > 0) {
        return '$years tahun $months bulan';
      } else if (years > 0) {
        return '$years tahun';
      } else {
        return '$months bulan';
      }
    } catch (e) {
      return '-';
    }
  }

  String _formatDate(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) return '-';

    try {
      final dob = DateTime.parse(dateOfBirth);
      const months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${dob.day} ${months[dob.month - 1]} ${dob.year}';
    } catch (e) {
      return dateOfBirth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.watch<AuthProvider>().user;

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
        child: _buildContent(colors, user),
      ),
    );
  }

  Widget _buildContent(dynamic colors, UserModel? user) {
    return Column(
      children: [
        _buildSectionCard(
          colors,
          title: 'Data Ketenagakerjaan',
          subtitle: 'Informasi data Anda terkait dengan perusahaan',
          children: [
            _buildInfoRow(
              colors,
              'Nama Pengguna',
              user?.username ?? user?.employeeCode,
              note: 'Nama Pengguna akan digunakan untuk login',
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSectionCard(
          colors,
          title: 'Data Personal',
          subtitle: 'Detail data pribadi Anda',
          childrenSpacing: 16.h,
          children: [
            _buildInfoRow(colors, 'Nama Lengkap', user?.name),
            Divider(color: colors.divider, thickness: 1.h, height: 0),
            _buildInfoRow(colors, 'Tempat Lahir', user?.placeOfBirth),
            _buildInfoRow(
              colors,
              'Tanggal Lahir',
              _formatDate(user?.dateOfBirth),
            ),
            _buildInfoRow(colors, 'Usia', _calculateAge(user?.dateOfBirth)),
            _buildInfoRow(colors, 'Agama', user?.religion),
            _buildInfoRow(colors, 'Status Perkawinan', user?.maritalStatus),
            _buildInfoRow(
              colors,
              'Jenis Kelamin',
              user?.gender == 'MALE' ? 'Pria' : 'Wanita',
            ),
            Divider(color: colors.divider, thickness: 1.h, height: 0),
            _buildInfoRow(colors, 'Kewarganegaraan', 'Indonesia'),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSectionCard(
          colors,
          title: 'Dokumen Negara',
          subtitle: 'Dokumen yang terkait dengan negara',
          childrenSpacing: 16.h,
          children: [
            _buildInfoRow(colors, 'Nomor ID', user?.nik),
            _buildInfoRow(colors, 'Tanggal Berakhir ID', '-'),
            Divider(color: colors.divider, thickness: 1.h, height: 0),
            _buildInfoRow(colors, 'Nama Terdaftar Pajak', '-'),
            _buildInfoRow(colors, 'Nomor Berkas Pajak', '-'),
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
      ],
    );
  }
}

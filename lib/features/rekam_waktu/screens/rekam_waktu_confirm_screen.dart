import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/config/env_config.dart';

/// Screen konfirmasi kehadiran dengan map dan foto.
class RekamWaktuConfirmScreen extends StatefulWidget {
  final File photo;
  final Position position;

  const RekamWaktuConfirmScreen({
    super.key,
    required this.photo,
    required this.position,
  });

  @override
  State<RekamWaktuConfirmScreen> createState() =>
      _RekamWaktuConfirmScreenState();
}

class _RekamWaktuConfirmScreenState extends State<RekamWaktuConfirmScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = false;
  bool _isMapLoading = true;
  final bool _mapError = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.read<AuthProvider>().user;
    final userName = (user?.name ?? 'USER').toUpperCase();
    final profilePhotoUrl = user?.avatarUrl;
    final now = DateTime.now();
    final dateTimeFormatted = DateFormat("MMM, dd yyyy, HH:mm").format(now);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapSection(colors),
                  _buildDivider(colors),
                  SizedBox(height: 16.h),
                  _buildUserName(userName, colors),
                  _buildDateTime(dateTimeFormatted, colors),
                  SizedBox(height: 20.h),
                  _buildPhotoComparison(colors, profilePhotoUrl),
                  SizedBox(height: 16.h),
                  _buildFaceIdentificationStatus(colors),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          _buildBottomButton(colors),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeColors colors) {
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: colors.textPrimary),
      ),
      title: Text(
        'Lihat Langsung',
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMapSection(ThemeColors colors) {
    final latLng = LatLng(widget.position.latitude, widget.position.longitude);
    final accuracy = widget.position.accuracy.round();

    return SizedBox(
      height: 220.h,
      child: Stack(
        children: [
          // Map or fallback
          if (_mapError)
            _buildFallbackMap(latLng, colors)
          else
            Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: latLng,
                    zoom: 17,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('user_location'),
                      position: latLng,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (mounted) {
                      setState(() => _isMapLoading = false);
                    }
                  },
                ),
                // Loading overlay
                if (_isMapLoading) _buildMapLoadingOverlay(colors),
              ],
            ),

          // Accuracy Badge
          Positioned(
            bottom: 16.h,
            left: 16.w,
            child: _buildAccuracyBadge(accuracy, colors),
          ),

          // Center Location Button
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: _buildCenterButton(latLng, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLoadingOverlay(ThemeColors colors) {
    return Container(
      color: colors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primaryBlue,
            ),
            SizedBox(height: 12.h),
            Text(
              'Memuat peta...',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyBadge(int accuracy, ThemeColors colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gps_fixed, size: 14.sp, color: colors.textSecondary),
          SizedBox(width: 6.w),
          Text(
            'Akurasi lokasi $accuracy meter',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton(LatLng latLng, ThemeColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
        },
        icon: Icon(Icons.my_location, color: colors.textSecondary, size: 20.sp),
      ),
    );
  }

  Widget _buildFallbackMap(LatLng latLng, ThemeColors colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8F4E5),
            const Color(0xFFD4E8D1),
            const Color(0xFFE2EBE0),
          ],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: _MapGridPainter()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: colors.primaryBlue,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeColors colors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 120.w),
      height: 4.h,
      decoration: BoxDecoration(
        color: colors.divider,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildUserName(String userName, ThemeColors colors) {
    return Text(
      userName,
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildDateTime(String dateTimeFormatted, ThemeColors colors) {
    final parts = dateTimeFormatted.split(', ');
    final datePart = parts.length > 1 ? '${parts[0]}, ${parts[1]}' : parts[0];
    final timePart = parts.length > 2 ? parts[2] : '';

    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 14.sp, color: colors.textSecondary),
        children: [
          TextSpan(text: '$datePart, '),
          TextSpan(
            text: timePart,
            style: TextStyle(
              color: colors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoComparison(ThemeColors colors, String? profilePhotoUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Foto Kehadiran
          Expanded(
            child: _buildPhotoCard(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  widget.photo,
                  width: 120.w,
                  height: 150.h,
                  fit: BoxFit.cover,
                ),
              ),
              label: 'Foto Kehadiran',
              colors: colors,
            ),
          ),
          SizedBox(width: 24.w),
          // Foto Dasar
          Expanded(
            child: _buildPhotoCard(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildProfilePhoto(profilePhotoUrl, colors),
              ),
              label: 'Foto Dasar',
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard({
    required Widget child,
    required String label,
    required ThemeColors colors,
  }) {
    return Column(
      children: [
        child,
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(String? profilePhotoUrl, ThemeColors colors) {
    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      final fullUrl = profilePhotoUrl.startsWith('http')
          ? profilePhotoUrl
          : '${EnvConfig.baseUrl}$profilePhotoUrl';

      return Image.network(
        fullUrl,
        width: 120.w,
        height: 150.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderPhoto(colors);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderPhoto(colors, isLoading: true);
        },
      );
    }
    return _buildPlaceholderPhoto(colors);
  }

  Widget _buildPlaceholderPhoto(ThemeColors colors, {bool isLoading = false}) {
    return Container(
      width: 120.w,
      height: 150.h,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: isLoading
            ? CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primaryBlue,
              )
            : Icon(Icons.person, size: 48.sp, color: colors.textSecondary),
      ),
    );
  }

  Widget _buildFaceIdentificationStatus(ThemeColors colors) {
    // TODO: Implement actual face recognition
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.green, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            'Identifikasi Wajah : ',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: colors.textPrimary,
            ),
          ),
          Text(
            'Lulus',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          Text(
            ' (--% Cocok)',
            style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSaveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Simpan Kehadiran',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSaveAttendance() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        context.showSuccessSnackbar('Kehadiran berhasil disimpan!');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal menyimpan kehadiran: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

/// Custom painter for fallback map grid
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCDDCC)
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

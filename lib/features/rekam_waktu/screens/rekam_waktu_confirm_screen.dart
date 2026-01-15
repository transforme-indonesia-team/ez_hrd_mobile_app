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
import 'package:hrd_app/core/utils/location_utils.dart';
import 'package:hrd_app/core/config/env_config.dart';

/// Screen konfirmasi kehadiran dengan map dan foto.
/// Lokasi ditampilkan real-time menggunakan blue dot Google Maps.
class RekamWaktuConfirmScreen extends StatefulWidget {
  final File photo;

  const RekamWaktuConfirmScreen({super.key, required this.photo});

  @override
  State<RekamWaktuConfirmScreen> createState() =>
      _RekamWaktuConfirmScreenState();
}

class _RekamWaktuConfirmScreenState extends State<RekamWaktuConfirmScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = false;
  bool _isMapLoading = true;
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _getInitialPosition();
  }

  Future<void> _getInitialPosition() async {
    try {
      // Try last known position first (faster), fallback to current
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );

      // Position is guaranteed non-null after getCurrentPosition
      if (mounted) {
        setState(() {
          _initialPosition = LatLng(position!.latitude, position.longitude);
        });
        // Also move camera if map is already created
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_initialPosition!),
        );
      }
    } catch (e) {
      debugPrint('Error getting initial position: $e');
    }
  }

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
    return SizedBox(
      height: 220.h,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition ?? const LatLng(0, 0),
              zoom: 18,
            ),
            markers: {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              if (mounted) {
                setState(() => _isMapLoading = false);
              }
              // Move camera to current location
              _moveCameraToCurrentLocation();
            },
          ),
          // Loading overlay
          if (_isMapLoading)
            Positioned.fill(child: _buildMapLoadingOverlay(colors)),

          // Center Location Button
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: _buildCenterButton(colors),
          ),
        ],
      ),
    );
  }

  Future<void> _moveCameraToCurrentLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      debugPrint('Error moving camera: $e');
    }
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

  Widget _buildCenterButton(ThemeColors colors) {
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
        onPressed: _moveCameraToCurrentLocation,
        icon: Icon(Icons.my_location, color: colors.textSecondary, size: 20.sp),
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
      return Image.network(
        '${EnvConfig.imageBaseUrl}$profilePhotoUrl',
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
      // Get current location when saving
      final position = await LocationUtils.getCurrentPosition();
      if (position == null) {
        if (mounted) {
          context.showErrorSnackbar('Gagal mendapatkan lokasi');
          setState(() => _isLoading = false);
        }
        return;
      }

      // TODO: Implement actual API call with position and photo
      debugPrint(
        'Saving attendance at: ${position.latitude}, ${position.longitude}',
      );
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

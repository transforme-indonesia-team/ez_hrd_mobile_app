import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/constants/app_constants.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrd_app/data/models/attendance_location_model.dart';
import 'package:hrd_app/data/services/attendance_service.dart';
import 'package:hrd_app/data/services/employee_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/providers/connectivity_provider.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/utils/location_utils.dart';
import 'package:hrd_app/data/services/attendance_sync_service.dart';
import 'package:hrd_app/core/utils/image_url_extension.dart';

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

  // State untuk lokasi kehadiran & validasi radius
  List<LocationAreaModel> _locationAreas = [];
  bool _isLoadingLocations = true;
  bool _isWithinRadius = false;
  bool _hasLocationRestriction = false;
  double? _nearestDistanceMeters;

  @override
  void initState() {
    super.initState();
    _getInitialPosition();
    _loadAttendanceLocations();
  }

  // ============ Data Loading ============

  Future<void> _getInitialPosition() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: AppConstants.geocodingTimeoutSeconds),
        ),
      );

      if (mounted) {
        setState(() {
          _initialPosition = LatLng(position!.latitude, position.longitude);
        });
        _validateRadiusIfReady();
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_initialPosition!),
        );
      }
    } catch (e) {
      debugPrint('RekamWaktuConfirmScreen: Gagal ambil posisi awal: $e');
    }
  }

  Future<void> _loadAttendanceLocations() async {
    // Saat offline, skip loading lokasi dan izinkan simpan langsung
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    if (!isOnline) {
      debugPrint('=== REKAM WAKTU: Offline, skip muat lokasi ===');
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
          _hasLocationRestriction = false;
        });
      }
      return;
    }

    try {
      debugPrint('=== REKAM WAKTU: Memuat lokasi kehadiran... ===');
      final response = await EmployeeService().getRelation(
        relation: 'ATTENDANCE_LOCATION',
        employeeCode: context.read<AuthProvider>().user?.employeeCode,
      );

      if (!mounted) return;

      debugPrint(
        '=== REKAM WAKTU: Response diterima, keys: ${response.keys} ===',
      );
      final locations = AttendanceLocationModel.parseFromApiResponse(response);
      debugPrint('=== REKAM WAKTU: Total lokasi: ${locations.length} ===');

      for (final loc in locations) {
        debugPrint(
          '=== REKAM WAKTU: Lokasi "${loc.attendanceLocationName}" '
          '(${loc.startDate} ~ ${loc.endDate}), '
          'jumlah area: ${loc.locationAreas.length} ===',
        );
      }

      // Kumpulkan semua area dari semua lokasi
      final areas = <LocationAreaModel>[];
      for (final location in locations) {
        areas.addAll(location.locationAreas);
      }

      debugPrint('=== REKAM WAKTU: Total area: ${areas.length} ===');
      for (final area in areas) {
        debugPrint(
          '=== REKAM WAKTU: Area "${area.areaName}" '
          'lat=${area.lat}, lng=${area.lng}, '
          'radius=${area.maxRadiusKm}km (${area.maxRadiusMeters}m) ===',
        );
      }

      setState(() {
        _locationAreas = areas;
        _hasLocationRestriction = areas.isNotEmpty;
        _isLoadingLocations = false;
      });

      _validateRadiusIfReady();
      _fitMapToShowAllAreas();
    } catch (e) {
      debugPrint('=== REKAM WAKTU: GAGAL memuat lokasi: $e ===');
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
          _hasLocationRestriction = false;
        });
      }
    }
  }

  // ============ Validasi Radius ============

  void _validateRadiusIfReady() {
    if (_initialPosition == null || _isLoadingLocations) return;
    if (!_hasLocationRestriction) return;

    double nearestDistance = double.infinity;
    bool withinAny = false;

    for (final area in _locationAreas) {
      final distance = Geolocator.distanceBetween(
        _initialPosition!.latitude,
        _initialPosition!.longitude,
        area.lat,
        area.lng,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
      }

      if (distance <= area.maxRadiusMeters) {
        withinAny = true;
      }
    }

    setState(() {
      _isWithinRadius = withinAny;
      _nearestDistanceMeters = nearestDistance;
    });
  }

  void _fitMapToShowAllAreas() {
    if (_mapController == null || _locationAreas.isEmpty) return;

    // Kumpulkan semua titik (area + posisi user)
    final points = <LatLng>[];
    for (final area in _locationAreas) {
      points.add(LatLng(area.lat, area.lng));
    }
    if (_initialPosition != null) {
      points.add(_initialPosition!);
    }

    if (points.length == 1) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 16),
      );
      return;
    }

    // Hitung bounds
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60, // padding
      ),
    );
  }

  /// Apakah tombol simpan boleh ditekan
  bool get _canSave {
    if (_isLoadingLocations) return false;
    if (!_hasLocationRestriction) return true; // Tidak ada restriksi lokasi
    return _isWithinRadius;
  }

  // ============ Build Methods ============

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
                  _buildRadiusStatus(colors),
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
        style: AppTextStyles.h4(colors.textPrimary),
      ),
    );
  }

  // ============ Map Section ============

  Set<Circle> _buildMapCircles() {
    if (_locationAreas.isEmpty || _isLoadingLocations) return {};

    final isInside = _isWithinRadius;

    return _locationAreas.asMap().entries.map((entry) {
      final area = entry.value;
      return Circle(
        circleId: CircleId('area_${entry.key}'),
        center: LatLng(area.lat, area.lng),
        radius: area.maxRadiusMeters,
        fillColor: isInside
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        strokeColor: isInside
            ? Colors.green.withValues(alpha: 0.6)
            : Colors.red.withValues(alpha: 0.6),
        strokeWidth: 2,
      );
    }).toSet();
  }

  Set<Marker> _buildMapMarkers() {
    return _locationAreas.asMap().entries.map((entry) {
      final area = entry.value;
      return Marker(
        markerId: MarkerId('area_marker_${entry.key}'),
        position: LatLng(area.lat, area.lng),
        infoWindow: InfoWindow(
          title: area.areaName,
          snippet: 'Radius: ${(area.maxRadiusKm * 1000).toInt()}m',
        ),
      );
    }).toSet();
  }

  Widget _buildMapSection(ThemeColors colors) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    // Saat offline, tampilkan koordinat sebagai pengganti peta
    if (!isOnline) {
      return _buildOfflineMapPlaceholder(colors);
    }

    return SizedBox(
      height: 220.h,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition ?? const LatLng(0, 0),
              zoom: 15,
            ),
            circles: _buildMapCircles(),
            markers: _buildMapMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              if (mounted) {
                setState(() => _isMapLoading = false);
              }
              _moveCameraToCurrentLocation();
              // Setelah map siap, fit ke semua area jika ada
              Future.delayed(const Duration(milliseconds: 500), () {
                _fitMapToShowAllAreas();
              });
            },
          ),
          if (_isMapLoading)
            Positioned.fill(child: _buildMapLoadingOverlay(colors)),

          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: _buildCenterButton(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineMapPlaceholder(ThemeColors colors) {
    final lat = _initialPosition?.latitude;
    final lng = _initialPosition?.longitude;

    return Container(
      height: 220.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 40.sp,
            color: colors.primaryBlue,
          ),
          SizedBox(height: 12.h),
          Text(
            'Lokasi Terdeteksi',
            style: AppTextStyles.body(
              colors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          if (lat != null && lng != null) ...[
            Text(
              'Lat: ${lat.toStringAsFixed(6)}',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 2.h),
            Text(
              'Lng: ${lng.toStringAsFixed(6)}',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
          ] else
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primaryBlue,
              ),
            ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, size: 14.sp, color: Colors.orange),
                SizedBox(width: 6.w),
                Text(
                  'Peta tidak tersedia (offline)',
                  style: AppTextStyles.caption(Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ Radius Status ============

  Widget _buildRadiusStatus(ThemeColors colors) {
    if (_isLoadingLocations) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primaryBlue,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Memeriksa area kehadiran...',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (!_hasLocationRestriction) {
      return const SizedBox.shrink();
    }

    final isInside = _isWithinRadius;
    final icon = isInside ? Icons.check_circle : Icons.cancel;
    final color = isInside ? Colors.green : Colors.red;
    final text = isInside ? 'Dalam area kehadiran' : _buildOutsideRadiusText();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.caption(color),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _buildOutsideRadiusText() {
    if (_nearestDistanceMeters == null) {
      return 'Di luar area kehadiran';
    }

    final distance = _nearestDistanceMeters!;
    if (distance >= 1000) {
      final km = (distance / 1000).toStringAsFixed(1);
      return 'Di luar area kehadiran (${km}km dari area terdekat)';
    }
    return 'Di luar area kehadiran (${distance.toInt()}m dari area terdekat)';
  }

  // ============ Existing UI Methods (tidak berubah) ============

  Future<void> _moveCameraToCurrentLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      debugPrint('RekamWaktuConfirmScreen: Gagal pindah kamera: $e');
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
              style: AppTextStyles.caption(colors.textSecondary),
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
    return Text(userName, style: AppTextStyles.body(colors.textPrimary));
  }

  Widget _buildDateTime(String dateTimeFormatted, ThemeColors colors) {
    final parts = dateTimeFormatted.split(', ');
    final datePart = parts.length > 1 ? '${parts[0]}, ${parts[1]}' : parts[0];
    final timePart = parts.length > 2 ? parts[2] : '';

    return RichText(
      text: TextSpan(
        style: AppTextStyles.body(colors.textSecondary),
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
        Text(label, style: AppTextStyles.caption(colors.textSecondary)),
      ],
    );
  }

  Widget _buildProfilePhoto(String? profilePhotoUrl, ThemeColors colors) {
    if (profilePhotoUrl?.asFullImageUrl != null) {
      return Image.network(
        profilePhotoUrl.asFullImageUrl!,
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
            style: AppTextStyles.body(colors.textPrimary),
          ),
          Text('Lulus', style: AppTextStyles.body(Colors.green)),
          Text(' (--% Cocok)', style: AppTextStyles.body(Colors.green)),
        ],
      ),
    );
  }

  // ============ Bottom Button ============

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
            onPressed: (_isLoading || !_canSave) ? null : _handleSaveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSave
                  ? colors.primaryBlue
                  : colors.inactiveGray,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
              disabledBackgroundColor: colors.inactiveGray.withValues(
                alpha: 0.5,
              ),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.buttonTextOnPrimary,
                    ),
                  )
                : Text(
                    'Simpan Kehadiran',
                    style: AppTextStyles.body(
                      _canSave
                          ? colors.buttonTextOnPrimary
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ============ Save Attendance ============

  Future<void> _handleSaveAttendance() async {
    setState(() => _isLoading = true);

    try {
      final position = await LocationUtils.getCurrentPosition();
      if (position == null) {
        if (mounted) {
          context.showErrorSnackbar('Gagal mendapatkan lokasi');
          setState(() => _isLoading = false);
        }
        return;
      }

      final user = context.read<AuthProvider>().user;

      final isOnline = context.read<ConnectivityProvider>().isOnline;

      if (isOnline) {
        // Online → kirim langsung ke API
        await AttendanceService().absent(
          latitude: position.latitude,
          longitude: position.longitude,
          photo: widget.photo,
          employeeCode: user?.employeeCode ?? '',
        );
        if (mounted) {
          context.showSuccessSnackbar('Kehadiran berhasil disimpan!');
          Navigator.of(context).pop(true);
        }
      } else {
        // Offline → simpan ke lokal
        await AttendanceSyncService().saveOffline(
          latitude: position.latitude,
          longitude: position.longitude,
          photo: widget.photo,
        );
        if (mounted) {
          context.showSuccessSnackbar(
            'Kehadiran disimpan offline. Akan dikirim otomatis saat online.',
          );
          Navigator.of(context).pop(true);
        }
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

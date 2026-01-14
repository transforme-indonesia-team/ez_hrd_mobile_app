import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/location_utils.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/rekam_waktu/screens/rekam_waktu_confirm_screen.dart';

/// Screen untuk mengambil foto kehadiran dengan kamera.
/// Mengambil lokasi secara paralel dengan inisialisasi kamera.
class RekamWaktuCameraScreen extends StatefulWidget {
  const RekamWaktuCameraScreen({super.key});

  @override
  State<RekamWaktuCameraScreen> createState() => _RekamWaktuCameraScreenState();
}

class _RekamWaktuCameraScreenState extends State<RekamWaktuCameraScreen>
    with WidgetsBindingObserver {
  // Camera state
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 1;

  // Location state
  Position? _position;
  bool _isLocationReady = false;
  bool _isLocationError = false;
  LocationErrorType? _locationErrorType;

  // Settings return flags
  bool _waitingForLocationSettings = false;
  bool _waitingForAppSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle return from settings
    if (state == AppLifecycleState.resumed) {
      if (_waitingForLocationSettings || _waitingForAppSettings) {
        _waitingForLocationSettings = false;
        _waitingForAppSettings = false;
        Future.delayed(const Duration(milliseconds: 300), _initLocation);
      }
    }
  }

  /// Initialize camera and location in parallel
  Future<void> _initializeAll() async {
    await Future.wait([_initCamera(), _initLocation()]);
  }

  // ============================================
  // CAMERA METHODS
  // ============================================

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          context.showErrorSnackbar('Tidak ada kamera tersedia');
          Navigator.pop(context);
        }
        return;
      }

      // Find front camera for selfie
      _selectedCameraIndex = _cameras!.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

      await _setupCamera(_selectedCameraIndex);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        context.showErrorSnackbar('Gagal mengakses kamera');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          _selectedCameraIndex = cameraIndex;
        });
      }
    } catch (e) {
      debugPrint('Error setting up camera: $e');
      if (mounted) {
        context.showErrorSnackbar('Gagal mengaktifkan kamera');
      }
    }
  }

  void _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final newIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    setState(() => _isCameraReady = false);
    await _setupCamera(newIndex);
  }

  void _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_cameras![_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front) {
      context.showInfoSnackbar('Flash tidak tersedia di kamera depan');
      return;
    }

    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  // ============================================
  // LOCATION METHODS
  // ============================================

  Future<void> _initLocation() async {
    setState(() {
      _isLocationError = false;
      _locationErrorType = null;
    });

    final position = await LocationUtils.checkAndRequestLocation(
      onError: (message, type) {
        if (mounted) {
          setState(() {
            _isLocationError = true;
            _locationErrorType = type;
          });
        }
      },
    );

    if (position != null && mounted) {
      setState(() {
        _position = position;
        _isLocationReady = true;
      });
    }
  }

  void _handleLocationError() {
    if (_locationErrorType == null) return;

    switch (_locationErrorType!) {
      case LocationErrorType.serviceDisabled:
        _showGPSDialog();
        break;
      case LocationErrorType.permissionDeniedForever:
        _showPermissionDialog();
        break;
      default:
        context.showErrorSnackbar('Gagal mendapatkan lokasi');
    }
  }

  // ============================================
  // CAPTURE METHOD
  // ============================================

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return;
    if (!_isLocationReady || _position == null) {
      context.showErrorSnackbar('Lokasi belum tersedia');
      return;
    }

    setState(() => _isCapturing = true);

    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      }

      final XFile photo = await _controller!.takePicture();

      if (mounted) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => RekamWaktuConfirmScreen(
              photo: File(photo.path),
              position: _position!,
            ),
          ),
        );

        if (result == true && mounted) {
          Navigator.pop(context);
        } else {
          setState(() => _isCapturing = false);
        }
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (mounted) {
        context.showErrorSnackbar('Gagal mengambil foto');
        setState(() => _isCapturing = false);
      }
    }
  }

  // ============================================
  // DIALOGS
  // ============================================

  void _showGPSDialog() {
    final colors = context.colors;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                color: colors.primaryBlue,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Aktifkan Lokasi',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Untuk mencatat kehadiran, Anda perlu mengaktifkan layanan lokasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: colors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Nanti Saja',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _waitingForLocationSettings = true;
                      LocationUtils.openLocationSettings();
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
                      'Aktifkan',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    final colors = context.colors;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: colors.warning,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Izin Lokasi Diperlukan',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Silakan aktifkan izin lokasi di pengaturan aplikasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: colors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Nanti Saja',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _waitingForAppSettings = true;
                      LocationUtils.openAppSettings();
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
                      'Buka Pengaturan',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BUILD METHODS
  // ============================================

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview (Full Screen)
            if (_isCameraReady && _controller != null)
              Positioned.fill(child: _buildCameraPreview())
            else
              _buildLoadingState(colors),

            // Face Silhouette Overlay
            if (_isCameraReady)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/silhouette_face.png',
                  fit: BoxFit.contain,
                ),
              ),

            // Top Bar
            _buildTopBar(colors),

            // Location Status Badge
            _buildLocationStatus(colors),

            // Bottom Bar
            _buildBottomBar(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    final cameraRatio = _controller!.value.aspectRatio;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.width * cameraRatio,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primaryBlue),
          SizedBox(height: 16.h),
          Text(
            'Memuat kamera...',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeColors colors) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekam Waktu',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Posisikan wajah dalam bingkai',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (_cameras != null && _cameras!.length > 1)
              IconButton(
                onPressed: _isCameraReady ? _toggleCamera : null,
                icon: Icon(
                  Icons.cameraswitch_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus(ThemeColors colors) {
    return Positioned(
      top: 80.h,
      left: 16.w,
      child: GestureDetector(
        onTap: _isLocationError ? _handleLocationError : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isLocationReady && !_isLocationError) ...[
                SizedBox(
                  width: 14.sp,
                  height: 14.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primaryBlue,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Mendapatkan lokasi...',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
              ] else if (_isLocationError) ...[
                Icon(Icons.location_off, size: 14.sp, color: colors.error),
                SizedBox(width: 8.w),
                Text(
                  'Lokasi gagal - Tap untuk retry',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: colors.error,
                  ),
                ),
              ] else ...[
                Icon(Icons.location_on, size: 14.sp, color: colors.success),
                SizedBox(width: 8.w),
                Text(
                  'Lokasi siap',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: colors.success,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeColors colors) {
    final canCapture = _isCameraReady && _isLocationReady && !_isCapturing;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Flash Toggle
            IconButton(
              onPressed: _isCameraReady ? _toggleFlash : null,
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _isFlashOn ? Colors.yellow : Colors.white,
                size: 28.sp,
              ),
            ),

            // Capture Button
            GestureDetector(
              onTap: canCapture ? _capturePhoto : null,
              child: Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: canCapture ? Colors.white : Colors.grey,
                    width: 4,
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing
                        ? Colors.grey
                        : (canCapture ? Colors.white : Colors.grey.shade700),
                  ),
                  child: _isCapturing
                      ? Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primaryBlue,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: canCapture ? Colors.black87 : Colors.grey,
                          size: 28.sp,
                        ),
                ),
              ),
            ),

            // Placeholder for balance
            SizedBox(width: 48.w),
          ],
        ),
      ),
    );
  }
}

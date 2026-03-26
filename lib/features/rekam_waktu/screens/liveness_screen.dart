import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

/// Screen yang menjalankan liveness detection challenge.
/// Mengembalikan [File] foto jika liveness berhasil, atau null jika gagal/cancel.
class LivenessScreen extends StatefulWidget {
  final String? scannedEmployeeCode;
  final String? scannedEmployeeName;
  final String? scannedProfileUrl;

  const LivenessScreen({
    super.key,
    this.scannedEmployeeCode,
    this.scannedEmployeeName,
    this.scannedProfileUrl,
  });

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  List<CameraDescription>? _cameras;
  bool _isLoading = true;
  String? _error;

  // Track status dari package via callbacks
  bool _isFaceDetected = false;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Tidak ada kamera tersedia';
            _isLoading = false;
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          _cameras = cameras;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal mengakses kamera: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colors.primaryBlue),
              SizedBox(height: 16.h),
              Text(
                'Mempersiapkan verifikasi wajah...',
                style: AppTextStyles.body(Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_error != null || _cameras == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: colors.error, size: 48.sp),
              SizedBox(height: 16.h),
              Text(
                _error ?? 'Kamera tidak tersedia',
                style: AppTextStyles.body(Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _initCameras();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Liveness detection dengan custom bottom indicators
    return Stack(
      children: [
        // Package LivenessDetectionScreen (punya Scaffold sendiri)
        LivenessDetectionScreen(
          cameras: _cameras!,
          captureFinalImage: true,

          // Sembunyikan status indicators bawaan (posisi hardcoded top, overlap)
          showStatusIndicators: false,

          // Custom AppBar
          showAppBar: true,
          customAppBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.6),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Verifikasi Wajah',
              style: AppTextStyles.h4(Colors.white),
            ),
            centerTitle: true,
          ),

          // Konfigurasi challenge — dioptimasi untuk attendance (cepat & mudah)
          config: LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.turnLeft,
              ChallengeType.turnRight,
              ChallengeType.smile,
            ],
            numberOfRandomChallenges: 2, // Cukup 2 challenge agar cepat
            alwaysIncludeBlink: true,
            sandwichNormalChallenge: false, // Tanpa extra "normal" step
            maxSessionDuration: const Duration(minutes: 2),

            // Threshold deteksi — di-relax agar lebih responsif
            eyeBlinkThresholdOpen: 0.6, // Lebih mudah detect mata terbuka
            eyeBlinkThresholdClosed: 0.4, // Lebih mudah detect mata tertutup
            smileThresholdNeutral: 0.35,
            smileThresholdSmiling: 0.45, // Senyum ringan sudah cukup
            headTurnThreshold: 10.0, // Noleh sedikit sudah cukup
            // Oval guide — proporsional seperti app banking
            ovalHeightRatio: 0.45,
            ovalWidthRatio: 0.73,
            strokeWidth: 2.5,

            // Anti-spoofing — relax untuk attendance
            enableGyroscopeCheck: false,
            enableRelaxedFacePositioningOnTiltDown: true,
            minDeviceMovementThreshold: 0.01,
            significantHeadMovementStdDev: 50.0,

            // Challenge hint di-disable
            defaultChallengeHintConfig: ChallengeHintConfig(enabled: false),

            // Pesan dalam Bahasa Indonesia
            messages: const LivenessMessages(
              moveFartherAway: 'Mundur sedikit',
              moveCloser: 'Maju sedikit',
              moveLeft: 'Geser ke kiri',
              moveRight: 'Geser ke kanan',
              moveUp: 'Geser ke atas',
              moveDown: 'Geser ke bawah',
              perfectHoldStill: 'Sempurna! Tetap diam',
              noFaceDetected: 'Wajah tidak terdeteksi',
              initializing: 'Mempersiapkan...',
              initialInstruction: 'Posisikan wajah Anda dalam oval',
              poorLighting: 'Pencahayaan kurang, pindah ke tempat lebih terang',
              processingVerification: 'Memproses verifikasi...',
              verificationComplete: 'Verifikasi selesai!',
              errorInitializingCamera:
                  'Gagal menginisialisasi kamera. Silakan coba lagi.',
              spoofingDetected: 'Kemungkinan spoofing terdeteksi',
            ),
            challengeInstructions: {
              ChallengeType.blink: 'Kedipkan mata Anda',
              ChallengeType.smile: 'Tersenyumlah',
              ChallengeType.turnLeft: 'Hadapkan wajah ke kiri',
              ChallengeType.turnRight: 'Hadapkan wajah ke kanan',
              ChallengeType.tiltUp: 'Angkat kepala ke atas',
              ChallengeType.tiltDown: 'Tundukkan kepala ke bawah',
            },
          ),

          // Theme — clean & modern banking style
          theme: LivenessTheme(
            primaryColor: Colors.white,
            successColor: const Color(0xFF4CAF50),
            errorColor: const Color(0xFFE53935),
            warningColor: const Color(0xFFFFA726),
            ovalGuideColor: Colors.white,
            overlayColor: Colors.black,
            overlayOpacity: 0.85, // Dark masking kuat — fokus ke oval
            instructionTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  blurRadius: 12,
                  color: Colors.black87,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            guidanceTextStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black87,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            progressIndicatorColor: Colors.white,
            progressIndicatorHeight: 4,
            useOvalPulseAnimation: false,
          ),

          // Track face detection via callbacks
          onFaceDetected: (challengeType, firstPassed, image, faces, camera) {
            if (mounted && !_isFaceDetected) {
              setState(() => _isFaceDetected = true);
            }
          },
          onFaceNotDetected: (challengeType, controller) {
            if (mounted && _isFaceDetected) {
              setState(() => _isFaceDetected = false);
            }
          },

          // Callbacks
          onChallengeCompleted: (challengeType) {
            debugPrint('LivenessScreen: challenge completed: $challengeType');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            debugPrint(
              'LivenessScreen: completed - success=$isSuccessful, metadata=$metadata',
            );
            if (!isSuccessful && mounted) {
              final antiSpoofing = metadata['antiSpoofingDetection'];
              if (antiSpoofing != null) {
                debugPrint(
                  'LivenessScreen: Anti-spoofing detail: $antiSpoofing',
                );
              }
            }
          },
          onFinalImageCaptured: (sessionId, imageFile, metadata) {
            debugPrint('LivenessScreen: image captured at ${imageFile.path}');
            if (mounted) {
              if (_isFaceDetected) {
                // Wajah terdeteksi — foto valid, kembalikan
                Navigator.pop(context, File(imageFile.path));
              } else {
                // Wajah tidak terdeteksi — foto tidak valid
                debugPrint(
                  'LivenessScreen: foto ditolak — wajah tidak terdeteksi',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Wajah tidak terdeteksi pada foto. Silakan coba lagi.',
                    ),
                    backgroundColor: Color(0xFFE53935),
                    duration: Duration(seconds: 3),
                  ),
                );
                // Pop dengan null → caller tahu verifikasi gagal
                Navigator.pop(context, null);
              }
            }
          },
        ),

        // Custom status indicators di bottom — tidak overlap dengan oval
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusBadge(
                icon: Icons.light_mode,
                label: 'Lighting',
                isActive: true, // Lighting always shows as active
                activeColor: const Color(0xFF4CAF50),
                inactiveColor: const Color(0xFFFFA726),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(
                icon: _isFaceDetected ? Icons.face : Icons.face_retouching_off,
                label: 'Face',
                isActive: _isFaceDetected,
                activeColor: const Color(0xFF4CAF50),
                inactiveColor: const Color(0xFFE53935),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget pill-shaped status badge — clean & modern
  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final color = isActive ? activeColor : inactiveColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

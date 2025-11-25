//This wrapper over SharedPreferences is needed as flutter doesn't provide
//non-async method for getting preferences. This is becoming a problem as
//at some places getting pref in constructor is required and constructors
//can't be async in flutter.
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:color_scanner/provider/auth_provider.dart';
import 'package:color_scanner/screen/color_details_screen.dart';
import 'package:color_scanner/utils/shared_pref.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as Math;
import 'package:image/image.dart' as img;

class ColorScannerScreen extends StatefulWidget {
  const ColorScannerScreen({Key? key}) : super(key: key);

  @override
  State<ColorScannerScreen> createState() => _ColorScannerScreenState();
}

class _ColorScannerScreenState extends State<ColorScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isScanning = false;
  bool _dialogShown = false;
  bool _cameraMode = false;
  bool _galleryMode = false;
  bool _isLoadingCameras = true;
  int _scanCount = 0;

  @override
  void initState() {
    super.initState();
    _loadScanCount();
    _initializeCameraSystem();
  }

  void _loadScanCount() {
    setState(() {
      _scanCount = SharedPrefUtil.getScanCount();
    });
  }

  void _incrementScanCount() {
    SharedPrefUtil.incrementScanCount();
    _loadScanCount();
  }

  Future<bool> scanCount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.increaseScanCount(context);

    if (success) {
      SharedPrefUtil.incrementScanCount();
      _loadScanCount();
      return true; // ✅ return true on success
    } else {
      return false; // ✅ return false on failure
    }
  }

  Future<void> _initializeCameraSystem() async {
    try {
      _cameras = await availableCameras();
      setState(() => _isLoadingCameras = false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_dialogShown) {
          _showImageSourceDialog();
        }
      });
    } catch (e) {
      print("Error getting cameras: $e");
      setState(() => _isLoadingCameras = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera initialization failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    try {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => _isScanning = true);
    try {
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return;

      int centerX = decodedImage.width ~/ 2;
      int centerY = decodedImage.height ~/ 2;
      final pixel = decodedImage.getPixel(centerX, centerY);

      final color = Color.fromARGB(
        pixel.a.toInt(),
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
      );

      // Increment scan count
      // _incrementScanCount();
      bool isSuccess = await scanCount();
      if (isSuccess) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColorDetailScreen(
              color: color,
              imagePath: imageFile.path,
              scanCount: _scanCount + 1, // Show the new count after increment
            ),
          ),
        );
      }
    } catch (e) {
      print("Error processing image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image processing error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _scanFromCamera() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isScanning) return;

    try {
      final image = await _cameraController!.takePicture();
      await _processImage(File(image.path));
    } catch (e) {
      print("Error capturing image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      await _processImage(File(pickedFile.path));
    } catch (e) {
      print("Error picking image from gallery: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallery error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    _dialogShown = true;
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SELECT SOURCE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSourceButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          enabled: _cameras != null && _cameras!.isNotEmpty,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _cameraMode = true;
                              _galleryMode = false;
                            });
                            _initializeCamera();
                          },
                        ),
                        _buildSourceButton(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          enabled: true,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _galleryMode = true;
                              _cameraMode = false;
                            });
                            _pickFromGallery();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        children: [
          InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: enabled
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blueAccent.shade400,
                          Colors.purpleAccent.shade400,
                        ],
                      )
                    : null,
                color: enabled ? null : Colors.grey,
                border: Border.all(
                  color: enabled ? Colors.white : Colors.grey,
                  width: 1.5,
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text(
                  'COLOR SCANNER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.white,
                ),
                actions: [
                  // Scan counter badge
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.color_lens, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '$_scanCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.source, size: 26),
                    onPressed: _showImageSourceDialog,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Processing Color...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingCameras) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Initializing Camera System',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_cameraMode) {
      return _buildCameraPreview();
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: const Icon(
                Icons.color_lens_rounded,
                size: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Capture or select an image\nto scan colors',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 15),
            // Total scans display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: Text(
                'Total Scans: $_scanCount',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('SELECT SOURCE'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6A11CB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_cameras != null && _cameras!.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Camera not available',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: 14,
                  ),
                ),
              ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Initializing Camera',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => _showImageSourceDialog(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        CameraPreview(_cameraController!),
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TargetPainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 70,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Center target on color to scan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Scans: $_scanCount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 100,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: _scanFromCamera,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6A11CB),
              elevation: 8,
              child: const Icon(Icons.camera, size: 32),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _pickFromGallery,
            mini: true,
            backgroundColor: Colors.black54,
            child: const Icon(Icons.photo_library_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _TargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw crosshairs
    canvas.drawLine(
      Offset(center.dx - 40, center.dy),
      Offset(center.dx - 15, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + 15, center.dy),
      Offset(center.dx + 40, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 40),
      Offset(center.dx, center.dy - 15),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 15),
      Offset(center.dx, center.dy + 40),
      paint,
    );

    // Draw inner circle
    canvas.drawCircle(center, 10, paint..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

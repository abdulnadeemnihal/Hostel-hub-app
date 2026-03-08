import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../scan_result/scan_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final raw = barcode.rawValue!;

    // Expect format: hostel_student:<studentId>
    if (!raw.startsWith('hostel_student:')) {
      _showInvalidQR();
      return;
    }

    final studentId = raw.replaceFirst('hostel_student:', '');
    if (studentId.isEmpty) {
      _showInvalidQR();
      return;
    }

    setState(() => _isProcessing = true);
    _controller.stop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(studentId: studentId),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _controller.start();
      }
    });
  }

  void _showInvalidQR() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid QR code. Not a hostel student QR.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scanner area
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
              // Overlay with scan frame
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Top instruction
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Point camera at student QR code',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom controls
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => _controller.toggleTorch(),
                icon: const Icon(Icons.flash_on),
                iconSize: 32,
                tooltip: 'Toggle Flash',
              ),
              IconButton(
                onPressed: () => _controller.switchCamera(),
                icon: const Icon(Icons.cameraswitch),
                iconSize: 32,
                tooltip: 'Switch Camera',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

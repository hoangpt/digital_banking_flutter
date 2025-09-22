import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _flashOn = false;
  bool _frontCamera = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        // Return the scanned data back
        Navigator.of(context).pop(barcode.rawValue);
        break;
      }
    }
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    setState(() {
      _frontCamera = !_frontCamera;
    });
    cameraController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: _toggleFlash,
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Overlay with scanning area
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Position QR code within the frame',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The QR code will be scanned automatically',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final double cutOutWidth = cutOutSize;
    final double cutOutHeight = cutOutSize;

    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.center,
          width: cutOutWidth,
          height: cutOutHeight,
        ),
        Radius.circular(borderRadius),
      ),
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final double cutOutWidth = cutOutSize;
    final double cutOutHeight = cutOutSize;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutWidth,
      height: cutOutHeight,
    );

    final bgPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()..addRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      ),
    );

    canvas.drawPath(path, bgPaint);

    // Draw border corners
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final radius = Radius.circular(borderRadius);

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
        ..lineTo(cutOutRect.left, cutOutRect.top + radius.y)
        ..arcToPoint(
          Offset(cutOutRect.left + radius.x, cutOutRect.top),
          radius: radius,
        )
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.top)
        ..lineTo(cutOutRect.right - radius.x, cutOutRect.top)
        ..arcToPoint(
          Offset(cutOutRect.right, cutOutRect.top + radius.y),
          radius: radius,
        )
        ..lineTo(cutOutRect.right, cutOutRect.top + borderLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.bottom - borderLength)
        ..lineTo(cutOutRect.left, cutOutRect.bottom - radius.y)
        ..arcToPoint(
          Offset(cutOutRect.left + radius.x, cutOutRect.bottom),
          radius: radius,
        )
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.bottom),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.bottom)
        ..lineTo(cutOutRect.right - radius.x, cutOutRect.bottom)
        ..arcToPoint(
          Offset(cutOutRect.right, cutOutRect.bottom - radius.y),
          radius: radius,
        )
        ..lineTo(cutOutRect.right, cutOutRect.bottom - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}

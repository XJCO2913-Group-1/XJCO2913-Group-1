import 'package:easy_scooter/pages/home_page/order_page/page.dart';
import 'package:easy_scooter/pages/scanner_page/scanner_controller.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_scooter/pages/scanner_page/ui_components.dart';
import 'package:easy_scooter/pages/scanner_page/manual_input_handler.dart';
import 'package:easy_scooter/pages/scanner_page/gallery_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessingCode = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner component
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              if (barcodes.first.rawValue == null) return;

              if (!_isProcessingCode) {
                _isProcessingCode = true;
                cameraController.stop();
                handleBarcode(
                  context,
                  barcodes.first.rawValue!,
                  onReset: _resetScanner,
                  onNavigate: (int scooterId, double price) {
                    cameraController.dispose();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderPage(
                          scooterId: scooterId,
                          price: price,
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),

          // UI components
          buildScanFrame(),
          buildPromptText(),

          // Gallery button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'galleryBtn',
              mini: true,
              onPressed: () => pickImageFromGallery(
                context,
                cameraController,
                _picker,
                onProcessingStart: () => _isProcessingCode = true,
                onReset: _resetScanner,
              ),
              backgroundColor: Colors.white.withOpacity(0.8),
              foregroundColor: Colors.black,
              child: const Icon(Icons.photo_library),
            ),
          ),

          // Manual input button
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'manualInputBtn',
              mini: true,
              onPressed: () => showManualInputDialog(
                context,
                cameraController,
                onProcessingStart: () => _isProcessingCode = true,
                onReset: _resetScanner,
              ),
              backgroundColor: Colors.white.withOpacity(0.8),
              foregroundColor: Colors.black,
              child: const Icon(Icons.keyboard),
            ),
          ),
        ],
      ),
    );
  }

  void _resetScanner() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessingCode = false;
        });
        cameraController.start();
      }
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

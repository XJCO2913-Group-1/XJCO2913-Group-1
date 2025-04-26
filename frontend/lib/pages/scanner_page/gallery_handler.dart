import 'package:easy_scooter/pages/home_page/order_page/page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_scooter/pages/scanner_page/scanner_controller.dart';

Future<void> pickImageFromGallery(
  BuildContext context,
  MobileScannerController cameraController,
  ImagePicker picker, {
  required Function() onProcessingStart,
  required Function() onReset,
}) async {
  try {
    // Pause camera scanning
    cameraController.stop();

    // Select image from gallery
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Process the image
      processPickedImage(
        context,
        pickedFile,
        onProcessingStart: onProcessingStart,
        onReset: onReset,
      );
    } else {
      // User canceled image picking, resume camera
      cameraController.start();
    }
  } catch (e) {
    showErrorMessage(context, 'Failed to pick image: $e');
    cameraController.start();
  }
}

Future<void> processPickedImage(
  BuildContext context,
  XFile file, {
  required Function() onProcessingStart,
  required Function() onReset,
}) async {
  onProcessingStart();

  try {
    // Create a temporary controller for image scanning
    final MobileScannerController imageScannerController =
        MobileScannerController();

    // Use the controller to analyze the image
    final BarcodeCapture? barcodeCapture =
        await imageScannerController.analyzeImage(file.path);

    // Clean up the temporary controller
    imageScannerController.dispose();

    if (barcodeCapture != null &&
        barcodeCapture.barcodes.isNotEmpty &&
        barcodeCapture.barcodes.first.rawValue != null) {
      // Handle the detected barcode
      handleBarcode(
        context,
        barcodeCapture.barcodes.first.rawValue!,
        onReset: onReset,
        onNavigate: (scooterId, price) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderPage(
                  scooterId: scooterId,
                  price: price,
                ),
              ));
        },
      );
    } else {
      showErrorMessage(context, 'No QR code found in the image');
      onReset();
    }
  } catch (e) {
    showErrorMessage(context, 'Failed to process image: $e');
    debugPrint('Image processing error: $e');
    onReset();
  }
}

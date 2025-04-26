import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_scooter/providers/scooters_provider.dart';
import 'package:easy_scooter/pages/home_page/order_page/page.dart';
import 'package:easy_scooter/pages/scanner_page/scanner_controller.dart';

void showManualInputDialog(
  BuildContext context,
  MobileScannerController cameraController, {
  required Function() onProcessingStart,
  required Function() onReset,
}) {
  // Pause camera scanning
  cameraController.stop();

  final TextEditingController textController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enter Scooter ID'),
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(hintText: 'Scooter ID'),
        keyboardType: TextInputType.number,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            cameraController.start(); // Resume scanning
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final String input = textController.text.trim();
            Navigator.of(context).pop();
            if (input.isNotEmpty) {
              try {
                final int scooterId = int.parse(input);
                processManualInput(
                  context,
                  scooterId,
                  cameraController,
                  onProcessingStart: onProcessingStart,
                  onReset: onReset,
                );
              } catch (e) {
                showErrorMessage(context, 'Please enter a valid ID number');
                cameraController.start(); // Resume scanning
              }
            } else {
              showErrorMessage(context, 'ID cannot be empty');
              cameraController.start(); // Resume scanning
            }
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}

void processManualInput(
  BuildContext context,
  int scooterId,
  MobileScannerController cameraController, {
  required Function() onProcessingStart,
  required Function() onReset,
}) {
  onProcessingStart();

  try {
    // Find the corresponding scooter in provider
    final scooters = ScootersProvider().scooters;
    final scooterIndex =
        scooters.indexWhere((scooter) => scooter.id == scooterId);

    if (scooterIndex != -1) {
      // Found the corresponding scooter
      final price = scooters[scooterIndex].price;
      if (price != null) {
        // Price is valid, can proceed with subsequent operations
        debugPrint('Found scooter, price: $price');
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
      } else {
        showErrorMessage(context, "This scooter is abnormal");
        onReset();
      }
    } else {
      showErrorMessage(context, "Could not recognize this scooter");
      onReset();
    }
  } catch (e) {
    showErrorMessage(context, 'Error processing input: ${e.toString()}');
    onReset();
  }
}

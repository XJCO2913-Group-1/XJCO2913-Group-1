import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_scooter/providers/scooters_provider.dart';

void handleBarcode(
  BuildContext context,
  String code, {
  required Function() onReset,
  required Function(int, double) onNavigate,
}) {
  debugPrint('Scan result: $code');

  try {
    // Try to parse the string as a JSON object
    final Map<String, dynamic> jsonData = jsonDecode(code);
    debugPrint('Parsed JSON: $jsonData');
    // Check if it contains id field
    if (jsonData.containsKey('id')) {
      final int scooterId = jsonData['id'];

      // Find the corresponding scooter in provider
      final scooters = ScootersProvider().scooters;
      final scooterIndex =
          scooters.indexWhere((scooter) => scooter.id == scooterId);

      if (scooterIndex != -1) {
        // Found the corresponding scooter
        final price = scooters[scooterIndex].price;
        if (price != null && price > 0) {
          // Price is valid, can proceed with subsequent operations
          debugPrint('Found scooter, price: $price');
          onNavigate(scooterId, price);
        } else {
          showErrorMessage(context, "This scooter is abnormal");
          onReset();
        }
      } else {
        showErrorMessage(context, "Could not recognize this scooter");
        onReset();
      }
    } else {
      showErrorMessage(context, 'No ID information found in this QR code');
      onReset();
    }
  } catch (e) {
    // JSON parsing failed
    showErrorMessage(context, 'QR code not recognizable');
    debugPrint('Parsing error: $e');
    onReset();
  }
}

void showErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
  );
}

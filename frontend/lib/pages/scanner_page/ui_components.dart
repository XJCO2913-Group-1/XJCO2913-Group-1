import 'package:flutter/material.dart';
import 'package:easy_scooter/utils/colors.dart';

Widget buildScanFrame() {
  return Center(
    child: Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(
          color: secondaryColor,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

Widget buildPromptText() {
  return Positioned(
    bottom: 80,
    left: 0,
    right: 0,
    child: Text(
      'Place QR code inside the frame',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        backgroundColor: Colors.black54,
        fontSize: 18,
      ),
    ),
  );
}

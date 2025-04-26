import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class PaymentFooter extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onPaymentConfirmed;

  const PaymentFooter({
    Key? key,
    required this.isProcessing,
    required this.onPaymentConfirmed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isProcessing ? null : onPaymentConfirmed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: isProcessing
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Confirm Payment', style: TextStyle(fontSize: 18.0)),
        ),
      ),
    );
  }
}

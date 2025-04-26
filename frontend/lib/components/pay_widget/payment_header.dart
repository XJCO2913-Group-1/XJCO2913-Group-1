import 'package:flutter/material.dart';

class PaymentHeader extends StatelessWidget {
  final double amount;

  const PaymentHeader({Key? key, required this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const Text(
            'Payment Amount',
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8),
          Text(
            '£${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

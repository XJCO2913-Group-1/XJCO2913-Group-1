import 'package:flutter/material.dart';
import 'package:easy_scooter/utils/colors.dart';

class FooterSection extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onPayPressed;

  const FooterSection({
    super.key,
    required this.totalPrice,
    required this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 总价
        Row(
          children: [
            const Text(
              'Total price',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              '￡ ${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        // 支付按钮
        ElevatedButton(
          onPressed: onPayPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 13.0),
          ),
          child: const Text(
            'To Pay',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

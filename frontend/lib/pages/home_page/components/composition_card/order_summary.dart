import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  final double totalPrice;

  const OrderSummary({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 押金
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Deposit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              '￡ 199(Refundable)',
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
        // 订单金额
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Order amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              '￡ ${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ],
    );
  }
}

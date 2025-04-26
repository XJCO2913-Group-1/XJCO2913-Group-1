import 'package:flutter/material.dart';
import 'package:easy_scooter/models/enums.dart';

import 'cost_item.dart';
import 'order_summary.dart';

class CostItemsSection extends StatelessWidget {
  final RentalPeriod rentalPeriod;
  final double price;
  final double totalPrice;

  const CostItemsSection({
    super.key,
    required this.rentalPeriod,
    required this.price,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Extract rental hours for display
    final rentalHours = rentalPeriod.hour;
    final basePrice = rentalHours * price;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 电动车租赁费
            CostItem(
              title: 'Scooter rental fees (${rentalPeriod.value})',
              amount: '￡ $basePrice',
            ),
            const SizedBox(height: 20),

            CostItem(
              title: 'Discount ',
              amount: ' ${rentalPeriod.discount}',
            ),
            // 订单金额和押金
            OrderSummary(totalPrice: totalPrice),
          ],
        ),
      ),
    );
  }
}

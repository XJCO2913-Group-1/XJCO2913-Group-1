import 'package:flutter/material.dart';
import 'package:easy_scooter/models/enums.dart';

import 'cost_item.dart';
import 'order_summary.dart';

class CostItemsSection extends StatelessWidget {
  final RentalPeriod rentalPeriod;
  final double price;
  final double totalPrice;
  final bool isStudent;
  final bool isElderly;
  final double vipDiscount;
  final double periodDiscount;
  final bool hasServerDiscount;

  const CostItemsSection({
    super.key,
    required this.rentalPeriod,
    required this.price,
    required this.totalPrice,
    this.isStudent = false,
    this.isElderly = false,
    this.vipDiscount = 1.0,
    this.periodDiscount = 1.0,
    this.hasServerDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    // Extract rental hours for display
    final rentalHours = rentalPeriod.hour;
    final basePrice = rentalHours * price;

    // 将折扣率改为百分比格式显示 (使用服务器的折扣率)
    final rentalPeriodDiscountPercent =
        ((1 - periodDiscount) * 100).toStringAsFixed(0);

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
              title: hasServerDiscount
                  ? 'Server Discount (${rentalPeriod.value})'
                  : 'Discount (${rentalPeriod.value})',
              amount: '-${rentalPeriodDiscountPercent}%',
            ),

            // Show VIP discount if applicable
            if (vipDiscount < 1.0) ...[
              const SizedBox(height: 20),
              CostItem(
                title: isStudent
                    ? 'Student VIP Discount'
                    : (isElderly ? 'Senior VIP Discount' : 'VIP Discount'),
                amount: '-${((1.0 - vipDiscount) * 100).toStringAsFixed(0)}%',
                isHighlighted: true,
              ),
            ],

            const SizedBox(height: 40),

            // 订单摘要
            OrderSummary(
              totalPrice: totalPrice,
            ),
          ],
        ),
      ),
    );
  }
}

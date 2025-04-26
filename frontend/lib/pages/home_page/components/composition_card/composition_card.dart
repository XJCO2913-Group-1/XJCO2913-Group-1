import 'package:easy_scooter/models/enums.dart';
import 'package:easy_scooter/models/new_rental.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../components/pay_widget/index.dart';
import 'header.dart';
import 'cost_items_section.dart';
import 'footer_section.dart';

// ignore: must_be_immutable
class CompositionCard extends StatefulWidget {
  final int scooterId;
  DateTime startTime;
  DateTime endTime;
  RentalPeriod rentalPeriod;
  double? price;
  CompositionCard({
    super.key,
    required this.scooterId,
    required this.startTime,
    required this.endTime,
    required this.rentalPeriod,
    this.price,
  });

  @override
  State<CompositionCard> createState() => _CompositionCardState();
}

class _CompositionCardState extends State<CompositionCard> {
  late double totalPrice;
  late DateTime startTime;
  @override
  void initState() {
    super.initState();
    startTime = widget.startTime;
    _calculateTotalPrice();
  }

  @override
  void didUpdateWidget(CompositionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rentalPeriod != widget.rentalPeriod) {
      _calculateTotalPrice();
    }
  }

  void _calculateTotalPrice() {
    // Extract numeric value from rental period (e.g. "1h" -> 1)
    final rentalHours = widget.rentalPeriod.hour;

    final basePrice = rentalHours * widget.price!;

    // Add additional costs (insurance, depreciation)
    const insuranceCost = 0.0;
    const depreciationCost = 0.0;

    // Subtract coupons
    const couponDiscount = 0.0;

    // Calculate final price
    setState(() {
      totalPrice =
          basePrice + insuranceCost + depreciationCost - couponDiscount;
      totalPrice *= widget.rentalPeriod.discount;
      // Round to two decimal places
      totalPrice = double.parse(totalPrice.toStringAsFixed(2));
      startTime = widget.startTime;
    });
  }

  Future<void> _handlePayment(
    BuildContext context,
    DateTime startTime,
    RentalPeriod rentalPeriod,
  ) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PayWidget(
                  newRental: NewRental(
                    scooterId: widget.scooterId,
                    startTime: widget.startTime,
                    endTime: widget.endTime,
                    rentalPeriod: widget.rentalPeriod.value,
                    cost: totalPrice,
                  ),
                  payType: PayType.newRental,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withAlpha(255),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CompositionHeader(
            onClose: () => Navigator.pop(context),
          ),
          // 费用明细
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Cost items and deposit section - scrollable
                  CostItemsSection(
                    rentalPeriod: widget.rentalPeriod,
                    price: widget.price!,
                    totalPrice: totalPrice,
                  ),
                  const SizedBox(height: 20),
                  // Bottom total price and pay button - fixed at bottom
                  FooterSection(
                    totalPrice: totalPrice,
                    onPayPressed: () => _handlePayment(
                      context,
                      widget.startTime,
                      widget.rentalPeriod,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

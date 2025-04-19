import 'package:easy_scooter/providers/rentals_provider.dart';
import 'package:easy_scooter/providers/scooters_provider.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompositionCard extends StatefulWidget {
  final int scooterId;
  final DateTime startTime;
  final DateTime endTime;
  final String rentalPeriod;
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

  @override
  void initState() {
    super.initState();
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
    final rentalHours =
        int.tryParse(widget.rentalPeriod.replaceAll(RegExp(r'[^0-9]'), '')) ??
            1;

    final basePrice = rentalHours * widget.price!;

    // Add additional costs (insurance, depreciation)
    const insuranceCost = 8.0;
    const depreciationCost = 2.0;

    // Subtract coupons
    const couponDiscount = 0.0;

    // Calculate final price
    setState(() {
      totalPrice =
          basePrice + insuranceCost + depreciationCost - couponDiscount;
    });
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
          _buildHeader(context),
          // 费用明细
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Cost items and deposit section - scrollable
                  _buildCostItemsSection(),
                  const SizedBox(height: 20),
                  // Bottom total price and pay button - fixed at bottom
                  _buildFooterSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Cost composition',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildCostItemsSection() {
    // Extract rental hours for display
    final rentalHours =
        int.tryParse(widget.rentalPeriod.replaceAll(RegExp(r'[^0-9]'), '')) ??
            1;
    final basePrice = rentalHours * widget.price!;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 电动车租赁费
            _buildCostItem(
                'Scooter rental and service fees (${widget.rentalPeriod})',
                '￡ $basePrice'),
            const SizedBox(height: 20),

            // 保险费
            _buildCostItem('Insurance costs', '￡ 8'),
            const SizedBox(height: 20),

            // 折旧费
            _buildCostItem('Scooter depreciation cost', '￡ 2'),
            const SizedBox(height: 20),

            // // 优惠券
            // _buildCostItem('Coupon', '- ￡ 20'),
            // const SizedBox(height: 20),

            // 订单金额和押金
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
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

  Widget _buildFooterSection(BuildContext context) {
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
                fontSize: 18.0,
              ),
            ),
          ],
        ),
        // 支付按钮
        _buildPayButton(context),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handlePayment(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 13.0),
      ),
      child: const Text(
        'To Pay',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    final rentalProvider = Provider.of<RentalsProvider>(
      context,
      listen: false,
    );
    final success = await rentalProvider.createRental(
      scooterId: widget.scooterId,
      startTime: widget.startTime.toString(),
      status: "paid",
      endTime: widget.endTime.toString(),
      rentalPeriod: widget.rentalPeriod,
    );
    if (!context.mounted) return;
    if (success) {
      Provider.of<ScootersProvider>(context, listen: false).fetchScooters();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Order added successfully! \nThe bill has been sent to your email, please check your email for details.'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add order, please try again')),
      );
    }
  }

  // 构建费用项
  Widget _buildCostItem(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}

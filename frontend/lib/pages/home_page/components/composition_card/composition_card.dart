import 'package:easy_scooter/models/enums.dart';
import 'package:easy_scooter/models/new_rental.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:easy_scooter/models/discount.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:easy_scooter/services/rental_service.dart';

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
  Discount? _discount;
  bool _isStudent = false;
  bool _isElderly = false;
  double _vipDiscount = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    startTime = widget.startTime;
    _loadDiscountConfig();
  }

  Future<void> _loadDiscountConfig() async {
    try {
      final userProvider = UserProvider();
      final user = userProvider.user;

      // Check user status (student or elderly)
      if (user != null) {
        setState(() {
          _isStudent = user.school != null && user.school!.isNotEmpty;
          _isElderly = user.age != null && user.age! > 60;

          // Prioritize elderly discount if both conditions are met
          if (_isElderly && _isStudent) {
            _isStudent = false;
          }
        });
      }

      // Get discount configuration
      _discount = await RentalService().getRentalConfig();

      // Apply VIP discount based on user type
      if (_isStudent && _discount != null) {
        _vipDiscount = _discount!.studentDiscount;
      } else if (_isElderly && _discount != null) {
        _vipDiscount = _discount!.oldDiscount;
      }

      setState(() {
        _isLoading = false;
      });

      // Calculate price after getting discount config
      _calculateTotalPrice();
    } catch (e) {
      print('Error loading discount config: $e');
      setState(() {
        _isLoading = false;
      });
      _calculateTotalPrice();
    }
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

    // Calculate final price
    setState(() {
      totalPrice = basePrice;

      // Apply rental period discount based on the period type
      if (_discount != null) {
        switch (widget.rentalPeriod) {
          case RentalPeriod.oneHour:
            totalPrice *= _discount!.oneHourDiscount;
            break;
          case RentalPeriod.fourHours:
            totalPrice *= _discount!.fourHoursDiscount;
            break;
          case RentalPeriod.oneDay:
            totalPrice *= _discount!.oneDayDiscount;
            break;
          case RentalPeriod.oneWeek:
            totalPrice *= _discount!.oneWeekDiscount;
            break;
        }
      } else {
        // Fallback to enum discount if server data isn't available
        totalPrice *= widget.rentalPeriod.discount;
      }

      // Apply VIP discount (student or elderly)
      if (_vipDiscount < 1.0) {
        totalPrice *= _vipDiscount;
      }

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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                          isStudent: _isStudent,
                          isElderly: _isElderly,
                          vipDiscount: _vipDiscount,
                          periodDiscount: _getPeriodDiscount(),
                          hasServerDiscount: _discount != null,
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

  double _getPeriodDiscount() {
    if (_discount == null) {
      return widget.rentalPeriod.discount;
    }

    switch (widget.rentalPeriod) {
      case RentalPeriod.oneHour:
        return _discount!.oneHourDiscount;
      case RentalPeriod.fourHours:
        return _discount!.fourHoursDiscount;
      case RentalPeriod.oneDay:
        return _discount!.oneDayDiscount;
      case RentalPeriod.oneWeek:
        return _discount!.oneWeekDiscount;
    }
  }
}

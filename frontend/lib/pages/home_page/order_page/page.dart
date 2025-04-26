import 'package:easy_scooter/components/scooter_card.dart';
import 'package:easy_scooter/models/enums.dart';
import 'package:easy_scooter/pages/home_page/components/composition_card/composition_card.dart';

import 'package:flutter/material.dart';
import '../../../components/rental_time_select_card.dart';

// ignore: must_be_immutable
class OrderPage extends StatefulWidget {
  final int scooterId;
  double? price;
  OrderPage({
    super.key,
    required this.scooterId,
    this.price,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  DateTime startTime = DateTime.now().add(const Duration(hours: 8));
  DateTime endTime = DateTime.now().add(const Duration(hours: 9));
  RentalPeriod rentalPeriod = RentalPeriod.oneHour;

  @override
  void initState() {
    super.initState();
  }

  void _onTimeChanged(
    DateTime newStartTime,
    DateTime newEndTime,
    RentalPeriod newRentalPeriod,
  ) {
    setState(() {
      startTime = newStartTime;
      endTime = newEndTime;
      rentalPeriod = newRentalPeriod;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Rental Time Selection",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                RentalTimeSelectCard(
                  startDate: startTime,
                  endDate: endTime,
                  period: rentalPeriod,
                  onTimeChanged: _onTimeChanged,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                "The Nearest Vehicle",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              ScooterCard(
                id: widget.scooterId,
                model: 'City Scooter',
                status: 'Available',
                distance: 0.5,
                location:
                    'No. 1, Zhongguancun Street, Haidian District, Beijing',
                rating: 4.5,
                price: 15.0,
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: CompositionCard(
              scooterId: widget.scooterId,
              startTime: startTime,
              endTime: endTime,
              rentalPeriod: rentalPeriod,
              price: widget.price,
            ),
          )
        ],
      ),
    ));
  }
}

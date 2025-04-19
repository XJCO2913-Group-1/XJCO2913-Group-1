import 'package:easy_scooter/components/scooter_card.dart';

import 'package:flutter/material.dart';
import 'components/rental_time_select_card.dart';
import 'components/composition_card.dart';

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
  late DateTime startTime;
  late DateTime endTime;
  String rentalPeriod = '1hr';

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    endTime = DateTime.now().add(const Duration(hours: 1));
  }

  void _onTimeChanged(
      DateTime newStartTime, DateTime newEndTime, String newRentalPeriod) {
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
                  timeLabel: rentalPeriod,
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
          ))
        ],
      ),
    ));
  }
}

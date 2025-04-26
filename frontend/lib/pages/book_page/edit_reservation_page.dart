import 'package:easy_scooter/components/page_title.dart';
import 'package:easy_scooter/models/enums.dart';
import 'package:easy_scooter/models/new_rental.dart';
import 'package:easy_scooter/models/rental.dart';
import 'package:easy_scooter/pages/book_page/components/new_bill_card.dart';
import 'package:easy_scooter/pages/book_page/components/new_rental_info_card.dart';
import 'package:easy_scooter/components/rental_time_select_card.dart';

import 'package:flutter/material.dart';

class EditRentalPage extends StatefulWidget {
  final Rental rental;
  const EditRentalPage({
    Key? key,
    required this.rental,
  }) : super(key: key);

  @override
  State<EditRentalPage> createState() => _EditRentalPageState();
}

class _EditRentalPageState extends State<EditRentalPage> {
  int extraTime = 1; // Extra time in minutes
  late DateTime startTime;
  late DateTime endTime;

  void _updateExtraTime(int hours) {
    setState(() {
      extraTime = hours;
    });
  }

  @override
  void initState() {
    super.initState();
    startTime = widget.rental.startTime;
    endTime = widget.rental.endTime;
  }

  void _onTimeChanged(DateTime newStartTime, DateTime newEndTime,
      RentalPeriod newRentalPeriod) {
    setState(() {
      startTime = newStartTime;
      endTime = newEndTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PageTitle(title: 'Edit Reservation'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          Text(
                            "Time Modification",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          RentalTimeSelectCard(
                            startDate: widget.rental.startTime,
                            endDate: widget.rental.endTime,
                            callBack: _updateExtraTime,
                            onTimeChanged: _onTimeChanged,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(children: [
                        Text(
                          "New Bill",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        // ToDo: update rental period
                        NewBillCard(
                          newTime: extraTime,
                          newRental: NewRental(
                            scooterId: widget.rental.scooterId,
                            startTime: startTime,
                            endTime: endTime,
                            cost: widget.rental.cost * extraTime,
                            rentalPeriod: widget.rental.rentalPeriod,
                          ),
                          rentalId: widget.rental.id,
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            NewRentalInfoCard(
              rental: widget.rental,
            ),
          ],
        ),
      ),
    );
  }
}

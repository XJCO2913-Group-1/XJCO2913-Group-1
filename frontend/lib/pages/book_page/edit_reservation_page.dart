import 'package:easy_scooter/components/page_title.dart';
import 'package:easy_scooter/models/rental.dart';
import 'package:easy_scooter/pages/book_page/components/location_edit_card.dart';
import 'package:easy_scooter/pages/book_page/components/new_bill_card.dart';
import 'package:easy_scooter/pages/book_page/components/new_rental_info_card.dart';
import 'package:easy_scooter/pages/home_page/components/rental_time_select_card.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PageTitle(title: 'Edit Reservation'),
      ),
      body: SafeArea(
          child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                  startDate: DateTime(2023, 1, 1),
                  endDate: DateTime(2023, 1, 1),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Text(
                "Pick-up and return location",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              LocationEditCard(),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Text(
                "New Bill",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              NewBillCard(),
            ]),
          ),
          NewRentalInfoCard(
            rental: widget.rental,
          )
        ],
      )),
    );
  }
}

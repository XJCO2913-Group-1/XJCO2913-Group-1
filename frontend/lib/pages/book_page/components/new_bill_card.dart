import 'package:easy_scooter/components/pay_widget/index.dart';
import 'package:easy_scooter/models/enums.dart';
import 'package:easy_scooter/models/new_rental.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class NewBillCard extends StatelessWidget {
  final int newTime;
  final NewRental newRental;
  final int rentalId;
  const NewBillCard(
      {super.key,
      required this.newTime,
      required this.newRental,
      required this.rentalId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Additional fees",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                "￡ ${newRental.cost * newTime}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PayWidget(
                            newRental: newRental,
                            payType: PayType.editRental,
                            rentalId: rentalId,
                          )),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFB4E197), // 浅绿色按钮
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "To Pay",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

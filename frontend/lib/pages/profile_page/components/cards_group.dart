import 'package:easy_scooter/components/payment_card.dart';
import 'package:easy_scooter/pages/profile_page/card_check_page.dart';

import 'package:flutter/material.dart';

class CardsGroup extends StatelessWidget {
  const CardsGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardCheckPage(),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Your Payment Cards',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                PaymentCard(),
                PaymentCard(),
                PaymentCard(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

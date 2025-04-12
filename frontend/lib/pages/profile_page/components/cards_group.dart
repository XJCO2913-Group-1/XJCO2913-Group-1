import 'package:easy_scooter/components/payment_card.dart';
import 'package:easy_scooter/pages/profile_page/card_check_page.dart';

import 'package:flutter/material.dart';

class CardsGroup extends StatelessWidget {
  const CardsGroup({
    super.key,
  });

  static final List<String> cardNumbers = [
    '1234 5678 9012 3456',
    '6789 0123 4567 8901',
    '9012 3456 7890 1234'
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: PageView.builder(
                  itemCount: cardNumbers.length,
                  controller: PageController(viewportFraction: 0.95),
                  itemBuilder: (context, index) {
                    return PaymentCard(
                      cardNumber: cardNumbers[index],
                    );
                  },
                ),
              ),
              // Right side - Add New One button
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    // Handle add new card action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardCheckPage(),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue[800],
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add New One',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

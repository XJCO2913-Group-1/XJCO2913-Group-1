import 'package:easy_scooter/pages/profile_page/card_check_page.dart';
import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final String cardNumber;
  const PaymentCard({
    super.key,
    required this.cardNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8DC),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CardCheckPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 8),
                Text(
                  'BANK OF NINGBO',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCardNumber(cardNumber),
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Format card number to show only last 4 digits
  String formatCardNumber(String number) {
    if (number.length < 4) return number;
    // Create a masked string with X characters
    return "6224XXXXXXXXXXXX";
  }
}

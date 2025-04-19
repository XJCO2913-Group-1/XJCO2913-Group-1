import 'package:easy_scooter/models/payment_card.dart';
import 'package:flutter/material.dart';

class InformationSection extends StatelessWidget {
  final PaymentCard? card;
  final VoidCallback onDeleteCard;

  const InformationSection({
    Key? key,
    required this.card,
    required this.onDeleteCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReadOnlyField('Cardholder Name', card?.cardHolerName ?? ''),
            const SizedBox(height: 15),
            _buildReadOnlyField(
                'Card Number', '**** **** **** ${card?.cardNumberLast4 ?? ''}'),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildReadOnlyField(
                      'Expiration Month', card?.cardExpiryMonth ?? ''),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildReadOnlyField(
                      'Maturity Year', card?.cardExpiryYear ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildReadOnlyField('CVV', '***'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildReadOnlyField(
                      'Type Of Card', card?.cardType ?? 'Visa'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onDeleteCard,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Delete this card',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const Divider(),
      ],
    );
  }
}

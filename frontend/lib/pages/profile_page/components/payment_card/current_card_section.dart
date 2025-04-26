import 'package:easy_scooter/models/payment_card.dart';
import 'package:easy_scooter/pages/profile_page/components/payment_card/card_switch_dialog.dart';
import 'package:easy_scooter/services/payment_card_service.dart';
import 'package:flutter/material.dart';

class CurrentCardSection extends StatelessWidget {
  final PaymentCard? card;
  final bool isDefaultCard;
  final int cardId;
  final Function(bool) onDefaultChanged;

  const CurrentCardSection({
    Key? key,
    required this.card,
    required this.isDefaultCard,
    required this.cardId,
    required this.onDefaultChanged,
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
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildCardDisplay(),
                ),
                Expanded(
                  flex: 1,
                  child: _buildSwitchButton(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDefaultSwitch(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDisplay() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                card?.cardType ?? 'Visa',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Card Number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '**** **** **** ${card?.cardNumberLast4 ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Card Owner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  card?.cardHolerName ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchButton(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => showCardSwitchDialog(context, cardId),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.swap_horiz,
                size: 30,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Switch',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSwitch(BuildContext context) {
    return Row(
      children: [
        const Text('Set as default payment card'),
        const Spacer(),
        Switch(
          value: isDefaultCard,
          onChanged: (value) async {
            if (value) {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Set Default Payment Card'),
                  content: const Text(
                    'Are you sure you want to set this card as the default payment method? It may lead to the theft of funds.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => {
                        PaymentCardService().setDefault(cardId),
                        Navigator.pop(context, true),
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                onDefaultChanged(true);
              }
            } else {
              onDefaultChanged(false);
            }
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }
}

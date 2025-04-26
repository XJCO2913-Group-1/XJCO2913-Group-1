import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:easy_scooter/models/payment_card.dart';

class PaymentContent extends StatelessWidget {
  final PaymentCard? selectedCard;
  final Function(PaymentCard) onCardSelected;

  const PaymentContent({
    Key? key,
    required this.selectedCard,
    required this.onCardSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentCardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${provider.error}'),
            ),
          );
        }

        if (provider.paymentCards.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No payment cards. Please add a payment card first.'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Select Payment Card',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.paymentCards.length,
                itemBuilder: (context, index) {
                  final card = provider.paymentCards[index];
                  return RadioListTile<PaymentCard>(
                    title: Row(
                      children: [
                        // 使用不同图标区分默认卡和普通卡
                        Icon(
                          card.isDefault
                              ? Icons.credit_score // 默认卡使用这个图标
                              : Icons.credit_card, // 普通卡使用这个图标
                          color: card.isDefault
                              ? Colors.green // 默认卡图标使用绿色
                              : Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          card.cardNumberLast4 +
                              (card.isDefault ? ' (Default)' : ''),
                          style: TextStyle(
                            fontWeight: card.isDefault
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    value: card,
                    groupValue: selectedCard,
                    onChanged: (PaymentCard? value) {
                      if (value != null) {
                        onCardSelected(value);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:easy_scooter/pages/profile_page/card_check_page.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showCardSwitchDialog(BuildContext context, int currentCardId) async {
  final paymentCardProvider =
      Provider.of<PaymentCardProvider>(context, listen: false);

  if (paymentCardProvider.paymentCards.isEmpty) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Loading payment cards...")
            ],
          ),
        );
      },
    );

    await paymentCardProvider.fetchPaymentCards();
    Navigator.pop(context);
  }

  if (paymentCardProvider.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Error loading cards: ${paymentCardProvider.error}')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Payment Card'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Consumer<PaymentCardProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.paymentCards.isEmpty) {
                return const Center(child: Text("No payment cards found"));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.paymentCards.length,
                itemBuilder: (context, index) {
                  final card = provider.paymentCards[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.credit_card,
                        color: card.id == currentCardId
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text('**** **** **** ${card.cardNumberLast4}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card.cardHolerName),
                          Text(
                              'Expires: ${card.cardExpiryMonth}/${card.cardExpiryYear}'),
                        ],
                      ),
                      trailing: card.id == currentCardId
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (card.id != currentCardId) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CardCheckPage(cardId: card.id),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Add New Card'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

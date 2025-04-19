import 'package:flutter/material.dart';
import '../../pages/home_page/feedback/faq_page/page.dart';

class FAQCard extends StatelessWidget {
  final List<Map<String, String>> faqs;

  const FAQCard({Key? key, required this.faqs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: faqs
              .map((faq) => FAQItem(
                    question: faq['question']!,
                    answer: faq['answer']!,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FAQAnswerPage(question: question, answer: answer),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

// Pre-defined FAQ data for reuse
class FAQData {
  static List<Map<String, String>> getCommonFAQs() {
    return [
      {
        'question': 'How do I start a ride?',
        'answer':
            'To start a ride, scan the QR code on the scooter using the app, then follow the on-screen instructions to unlock it. Make sure the scooter has enough battery before starting. Once unlocked, the meter will begin and you\'ll be charged according to our pricing policy.'
      },
      {
        'question': 'What to do if the scooter isn\'t working?',
        'answer':
            'If the scooter isn\'t working, first check if it has enough battery. Try turning it off and on again. If the issue persists, please report it through the app by submitting feedback with the "Scooter Issue" category and choose another scooter nearby.'
      },
      {
        'question': 'How is the fare calculated?',
        'answer':
            'The fare consists of a base unlock fee plus a per-minute charge. Current rates are \$1 to unlock and \$0.15 per minute of riding. You can check your current charges during the ride from the app. Remember that parking in designated zones can provide discounts on your next ride.'
      },
      {
        'question': 'Payment methods not working?',
        'answer':
            'If your payment method isn\'t working, try adding a new payment method or updating your existing one. Check that your card hasn\'t expired and that you have sufficient funds. If problems persist, contact your bank or our customer support team at support@easyscooter.com.'
      },
      {
        'question': 'Where can I park the scooter?',
        'answer':
            'You should park the scooter in designated parking areas shown on the app map with green icons. Avoid blocking sidewalks, entrances, private property, or emergency access routes. Improper parking may result in additional fees.'
      },
    ];
  }
}

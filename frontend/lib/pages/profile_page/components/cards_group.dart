import 'package:easy_scooter/components/payment_card.dart';
import 'package:easy_scooter/pages/profile_page/card_check_page.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardsGroup extends StatefulWidget {
  const CardsGroup({super.key});

  @override
  State<CardsGroup> createState() => _CardsGroupState();
}

class _CardsGroupState extends State<CardsGroup> {
  @override
  void initState() {
    super.initState();
    // 在这里可以添加初始化代码，例如加载数据等
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentCardProvider>(context, listen: false)
          .fetchPaymentCards();
    });
  }

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
                child: Consumer<PaymentCardProvider>(
                    builder: (context, value, child) {
                  if (value.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 28, 49, 44),
                      ),
                    );
                  } else if (value.error != null) {
                    return Center(
                      child: Text(
                        '加载失败: ${value.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (value.paymentCards.isEmpty) {
                    return const Center(
                      child: Text(
                        '没有可用的支付卡数据',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return PageView.builder(
                      itemCount: value.paymentCards.length,
                      controller: PageController(viewportFraction: 0.95),
                      itemBuilder: (context, index) {
                        return PaymentCard(
                          cardNumber: value.paymentCards[index].cardNumberLast4,
                        );
                      },
                    );
                  }
                }),
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

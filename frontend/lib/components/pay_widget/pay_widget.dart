import 'package:easy_scooter/components/main_navigation.dart';
import 'package:easy_scooter/models/enums.dart';
import 'package:easy_scooter/models/new_rental.dart';
import 'package:easy_scooter/pages/home_page/page.dart';
import 'package:easy_scooter/services/rental_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:easy_scooter/models/payment_card.dart';

import 'payment_header.dart';
import 'payment_content.dart';
import 'payment_footer.dart';
import 'payment_logic.dart';

class PayWidget extends StatefulWidget {
  final NewRental newRental;
  final PayType payType;
  final int? rentalId;
  const PayWidget({
    Key? key,
    required this.newRental,
    required this.payType,
    this.rentalId,
  })  : assert(payType != PayType.editRental || rentalId != null,
            'rentalId must be provided when payType is editRental'),
        super(key: key);

  @override
  State<PayWidget> createState() => _PayWidgetState();
}

class _PayWidgetState extends State<PayWidget> {
  PaymentCard? _selectedCard;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // 初始化时加载支付卡数据
    Future.microtask(() async {
      final provider = Provider.of<PaymentCardProvider>(context, listen: false);
      await provider.fetchPaymentCards();

      // 选择默认支付卡
      if (provider.paymentCards.isNotEmpty) {
        setState(() {
          _selectedCard = PaymentLogic.getDefaultCard(provider.paymentCards);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 返回按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 头部：显示支付金额
              PaymentHeader(amount: widget.newRental.cost),
              const Divider(),

              // 内容：显示支付卡列表
              PaymentContent(
                selectedCard: _selectedCard,
                onCardSelected: (card) {
                  setState(() {
                    _selectedCard = card;
                  });
                },
              ),
              const Divider(),

              // 底部：确认支付按钮
              PaymentFooter(
                isProcessing: _isProcessing,
                onPaymentConfirmed: () {
                  PaymentLogic.processPayment(
                    context: context,
                    selectedCard: _selectedCard,
                    onPaymentStarted: () async {
                      setState(() {
                        _isProcessing = true;
                      });
                      debugPrint(
                          "rentalPeriod : ${widget.newRental.rentalPeriod}");
                      if (widget.payType == PayType.newRental) {
                        await RentalService().createRental(
                          scooterId: widget.newRental.scooterId,
                          rentalPeriod: widget.newRental.rentalPeriod,
                          startTime:
                              widget.newRental.startTime.toIso8601String(),
                          endTime: widget.newRental.endTime.toIso8601String(),
                          cost: widget.newRental.cost,
                          status: 'paid',
                        );
                      }
                    },
                    onPaymentCompleted: () {
                      setState(() {
                        _isProcessing = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Order added successfully! \nThe bill has been sent to your email, please check your email for details.'),
                        ),
                      );
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainNavigation()));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

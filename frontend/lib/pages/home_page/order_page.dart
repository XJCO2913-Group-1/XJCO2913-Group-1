import 'package:easy_scooter/components/scooter_card.dart';
import 'package:easy_scooter/providers/rentals_provider.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/rental_time_select_card.dart';

class OrderPage extends StatefulWidget {
  final int scooterId;
  const OrderPage({
    super.key,
    required this.scooterId,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final startTime = DateTime.now();
  final endTime = DateTime.now().add(const Duration(hours: 1));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Rental Time Selection",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                RentalTimeSelectCard(
                  startDate: startTime,
                  endDate: endTime,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                "The Nearest Vehicle",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              ScooterCard(
                id: widget.scooterId,
                name: 'City Scooter',
                status: 'Available',
                distance: 0.5,
                location: '北京市海淀区中关村大街1号',
                rating: 4.5,
                price: 15.0,
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
              child: CompositionCard(
            scooterId: widget.scooterId,
            startTime: startTime,
            endTime: endTime,
          ))
        ],
      ),
    ));
  }
}

class CompositionCard extends StatelessWidget {
  final int scooterId;
  final DateTime startTime;
  final DateTime endTime;
  const CompositionCard({
    super.key,
    required this.scooterId,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withAlpha(255),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 6.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Cost composition',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                )
              ],
            ),
          ),
          // 费用明细
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 电动车租赁费
                  _buildCostItem('Scooter rental and service fees', '¥ 288'),
                  const Spacer(),

                  // 保险费
                  _buildCostItem('Insurance costs', '¥ 8'),
                  const Spacer(),

                  // 折旧费
                  _buildCostItem('Scooter depreciation cost', '¥ 2'),
                  const Spacer(),
                  // 优惠券
                  _buildCostItem('Coupon', '- ¥ 20'),
                  const Spacer(),

                  // 订单金额和押金
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 押金
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Deposit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            '¥ 199(Refundable)',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                      // 订单金额
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'Order amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            '¥ 278',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 底部总价和支付按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 总价
                      Row(
                        children: const [
                          Text(
                            'Total price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '¥ 278',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                      // 支付按钮
                      ElevatedButton(
                        onPressed: () async {
                          // 处理支付逻辑
                          final rentalProvider = Provider.of<RentalsProvider>(
                            context,
                            listen: false,
                          );
                          final success = await rentalProvider.createRental(
                            scooterId: scooterId,
                            startTime: startTime.toString(),
                            status: "paid",
                            endTime: endTime.toString(),
                            rentalPeriod: "1hr",
                          );
                          if (!context.mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('订单添加成功')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('订单添加失败，请重试')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 13.0),
                        ),
                        child: const Text(
                          'To Pay',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建费用项
  Widget _buildCostItem(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}

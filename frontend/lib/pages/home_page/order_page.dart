import 'package:easy_scooter/components/scooter_card.dart';
import 'package:flutter/material.dart';
import 'components/rental_time_select_card.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  RentalTimeSelectCard(
                    startDate: DateTime(2023, 1, 1),
                    endDate: DateTime(2023, 1, 1),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  "The Nearest Vehicle",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                ScooterCard(
                  id: 'EB-2023-0001',
                  name: 'City Scooter',
                  distance: 0.5,
                  location: '北京市海淀区中关村大街1号',
                  rating: 4.5,
                  price: 15.0,
                ),
              ],
            ),
            Expanded(child: CompositionCard())
          ],
        ),
      ),
    );
  }
}

class CompositionCard extends StatelessWidget {
  const CompositionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF9FD661), // 绿色背景
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
              color: const Color(0xFF3A4A3F),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Cost composition',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A4A3F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 15.0),
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

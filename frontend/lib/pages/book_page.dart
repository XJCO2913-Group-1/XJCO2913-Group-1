import 'package:flutter/material.dart';
import '../components/order_card.dart';
import '../data/reservation_data.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // 搜索框
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  ),
                ),
              ),
              // 标签页
              TabBar(
                controller: _tabController,
                // isScrollable: true,
                labelPadding: EdgeInsets.zero,
                indicatorWeight: 3.0,
                tabs: const [
                  Tab(text: 'Reserved'), // 预定中
                  Tab(text: 'Waitlisted'), // 候补中
                  Tab(text: 'Renting'), // 租赁中
                  Tab(text: 'Completed'), // 已完成
                  Tab(text: 'Cancelled'), // 已取消
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 预定中
          ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            itemCount: ReservationData.getReservations().length,
            itemBuilder: (context, index) {
              final reservation = ReservationData.getReservations()[index];
              return OrderCard(
                orderId: reservation['orderId'],
                vehicleModel: reservation['vehicleModel'],
                vehicleId: reservation['vehicleId'],
                reservationTime: reservation['reservationTime'],
                startTime: reservation['startTime'],
                status: reservation['status'],
                location: reservation['location'],
                onTap: () {
                  // 处理点击事件
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('查看订单: ${reservation["orderId"]}')));
                },
              );
            },
          ),
          // 候补中
          Center(child: Text('候补中内容', style: TextStyle(fontSize: 20))),
          // 租赁中
          Center(child: Text('租赁中内容', style: TextStyle(fontSize: 20))),
          // 已完成
          Center(child: Text('已完成内容', style: TextStyle(fontSize: 20))),
          // 已取消
          Center(child: Text('已取消内容', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }
}

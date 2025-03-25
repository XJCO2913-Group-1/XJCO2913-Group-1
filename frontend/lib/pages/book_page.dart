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
                labelStyle: const TextStyle(fontSize: 12.0), // 设置标签文字大小

                tabs: const [
                  Tab(text: 'Reserved'), // Reserved
                  Tab(text: 'Waitlisted'), // Waitlisted
                  Tab(text: 'Renting'), // Renting
                  Tab(text: 'Completed'), // Completed
                  Tab(text: 'Cancelled'), // Cancelled
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Reserved
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
                      content: Text('View Order: ${reservation["orderId"]}')));
                },
              );
            },
          ),
          // Waitlisted
          Center(
              child:
                  Text('Waitlisted Content', style: TextStyle(fontSize: 20))),
          // Renting
          Center(
              child: Text('Renting Content', style: TextStyle(fontSize: 20))),
          // Completed
          Center(
              child: Text('Completed Content', style: TextStyle(fontSize: 20))),
          // Cancelled
          Center(
              child: Text('Cancelled Content', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }
}

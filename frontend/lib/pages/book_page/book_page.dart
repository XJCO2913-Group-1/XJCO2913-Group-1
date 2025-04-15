import 'package:easy_scooter/pages/book_page/edit_reservation_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/rental_card.dart';
import '../../providers/rentals_provider.dart';

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
    Future.microtask(() {
      if (mounted) {
        Provider.of<RentalsProvider>(context, listen: false).fetchRentals();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
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
            labelStyle: const TextStyle(fontSize: 13.0), // 设置标签文字大小

            tabs: const [
              Tab(text: 'Reserved'), // Reserved
              Tab(text: 'Waitlisted'), // Waitlisted
              Tab(text: 'Renting'), // Renting
              Tab(text: 'Completed'), // Completed
              Tab(text: 'Cancelled'), // Cancelled
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Reserved
                TabContent(
                  tab: 'Reserved',
                ),
                // Waitlisted
                TabContent(
                  tab: 'Waitlisted',
                ),
                // Renting
                TabContent(
                  tab: 'Renting',
                ),
                // Completed
                TabContent(
                  tab: 'Completed',
                ),
                // Cancelled
                TabContent(
                  tab: 'Cancelled',
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class TabContent extends StatelessWidget {
  final String tab;
  const TabContent({
    super.key,
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalsProvider>(
      builder: (context, rentalsProvider, child) {
        if (rentalsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (rentalsProvider.error != null) {
          return Center(
              child: Text('Error: ${rentalsProvider.error}',
                  style: TextStyle(color: Colors.red)));
        } else if (rentalsProvider.rentals.isEmpty) {
          return const Center(child: Text('No reservations found'));
        } else {
          final reservedRentals = rentalsProvider.rentals
              .where((rental) => rental.status.isNotEmpty)
              .toList();
          return RefreshIndicator(
            onRefresh: () => rentalsProvider.fetchRentals(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              itemCount: reservedRentals.length,
              itemBuilder: (context, index) {
                final rental = reservedRentals[index];
                return RentalCard(
                  rental: rental,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRentalPage(rental: rental),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
}

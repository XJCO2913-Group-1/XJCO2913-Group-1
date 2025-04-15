import 'package:easy_scooter/components/rental_card.dart';
import 'package:easy_scooter/models/rental.dart';
import 'package:easy_scooter/providers/rentals_provider.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewRentalInfoCard extends StatelessWidget {
  final Rental rental;
  const NewRentalInfoCard({
    super.key,
    required this.rental,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Your Order Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          RentalCard(
            rental: rental,
            onTap: null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "-Please check with it-",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton(
                  onPressed: () async {
                    final rentalsProvider =
                        Provider.of<RentalsProvider>(context, listen: false);
                    final success =
                        await rentalsProvider.deleteRental(rental.id);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('订单取消成功')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('订单取消失败，请重试')),
                      );
                    }
                  },
                  child: const Text(
                    "Cancel Order",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

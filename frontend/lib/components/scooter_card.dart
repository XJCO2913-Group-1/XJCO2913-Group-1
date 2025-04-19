import 'package:easy_scooter/pages/home_page/order_page.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class ScooterCard extends StatelessWidget {
  final int id;
  final String model;
  final double distance;
  final String location;
  final double rating;
  final String status;
  double? price;

  ScooterCard({
    super.key,
    required this.id,
    required this.model,
    required this.distance,
    required this.location,
    required this.rating,
    required this.status,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: status == 'available'
            ? secondaryColor.withAlpha(200)
            : secondaryColor.withAlpha(150),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (status == 'available') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OrderPage(scooterId: id, price: price)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scooter is not available'),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          model,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(188, 230, 114, 1),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // 评星显示，五颗星的容量，根据评分填充
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : index < rating
                                      ? Icons.star_half
                                      : Icons.star_border,
                              size: 16,
                              color: const Color.fromRGBO(188, 230, 114, 1),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.qr_code,
                        size: 16,
                        color: const Color.fromRGBO(188, 230, 114, 1)),
                    const SizedBox(width: 8),
                    Text(
                      'ID: $id',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color.fromRGBO(188, 230, 114, 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 价格显示，替换原来的Navigate按钮
                    Text(
                      '￡${price?.toStringAsFixed(2)} / h',
                      style: const TextStyle(
                        color: Color.fromRGBO(188, 230, 114, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:easy_scooter/models/rental.dart';
import 'package:flutter/material.dart';

class RentalCard extends StatelessWidget {
  final Rental rental;
  final VoidCallback? onTap;

  const RentalCard({
    super.key,
    required this.rental,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: rental.status != 'cancelled' ? onTap : null,
      child: Container(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 上半部分：电动车信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  // 电动车图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.electric_scooter,
                      color: Colors.black54,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ID和滑板车名称
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ID: ${rental.scooterId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 3,
                    child: Text(
                      rental.scooterName,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // 下半部分：时间、位置和价格信息
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey.shade200, width: 1.0),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  )),
              child: Column(
                children: [
                  // 时间信息
                  Row(
                    children: [
                      const Text(
                        'E-Track',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        ' ${_formatDate(rental.startTime)} ${_formatTime(
                          rental.startTime,
                        )}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 16),
                      Text(
                        _formatTime(
                          rental.endTime,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rental.rentalPeriod,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 第二个位置
                  Row(
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 价格信息
                      Text(
                        '￡ ${rental.cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 格式化日期：YYYY/MM/DD
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}/${_twoDigits(dateTime.month)}/${_twoDigits(dateTime.day)}';
  }

  // 格式化时间：HH:MM
  String _formatTime(DateTime dateTime) {
    return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  // 两位数格式化
  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}

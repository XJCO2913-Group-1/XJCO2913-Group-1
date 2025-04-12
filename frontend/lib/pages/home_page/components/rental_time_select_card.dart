import 'package:flutter/material.dart';

class RentalTimeSelectCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String timeLabel;

  const RentalTimeSelectCard({
    super.key,
    required this.startDate,
    required this.endDate,
    this.timeLabel = '24hour',
  });

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _getWeekday(DateTime date) {
    final weekdays = ['Mon.', 'Tue.', 'Wed.', 'Thu.', 'Fri.', 'Sat.', 'Sun.'];
    // DateTime weekday is 1-7 where 1 is Monday
    return weekdays[date.weekday - 1];
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF3A4A3F), // 深绿色背景
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.2,
            ),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 开始日期和时间
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(startDate),
                style: const TextStyle(
                  color: Color(0xFFB8D8A0), // 浅绿色文字
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_getWeekday(startDate)} ${_formatTime(startDate)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),

          // 中间的时间标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.5,
                ),
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              timeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
            ),
          ),

          // 结束日期和时间
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(endDate),
                style: const TextStyle(
                  color: Color(0xFFB8D8A0), // 浅绿色文字
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_getWeekday(endDate)} ${_formatTime(endDate)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

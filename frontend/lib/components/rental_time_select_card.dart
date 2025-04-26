import 'package:easy_scooter/models/enums.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';

class RentalTimeSelectCard extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final RentalPeriod period;
  final Function(
    DateTime startDate,
    DateTime endDate,
    RentalPeriod period,
  )? onTimeChanged;
  final Function(int)? callBack;

  const RentalTimeSelectCard({
    super.key,
    required this.startDate,
    required this.endDate,
    this.period = RentalPeriod.oneHour,
    this.onTimeChanged,
    this.callBack,
  });

  @override
  State<RentalTimeSelectCard> createState() => _RentalTimeSelectCardState();
}

class _RentalTimeSelectCardState extends State<RentalTimeSelectCard> {
  late DateTime _startDate;
  late DateTime _endDate;
  late RentalPeriod _period;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _period = widget.period;
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _getWeekday(DateTime date) {
    final weekdays = ['Mon.', 'Tue.', 'Wed.', 'Thu.', 'Fri.', 'Sat.', 'Sun.'];
    return weekdays[date.weekday - 1];
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );

      if (pickedTime != null) {
        final newStartTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _startDate = newStartTime;
          _updateEndDate();
        });

        if (widget.onTimeChanged != null) {
          widget.onTimeChanged!(newStartTime, _endDate, _period);
        }
      }
    }
  }

  void _selectDuration() async {
    final List<RentalPeriod> durations = [
      RentalPeriod.oneHour,
      RentalPeriod.fourHours,
      RentalPeriod.oneDay,
      RentalPeriod.oneWeek,
    ];

    RentalPeriod? selected = await showDialog<RentalPeriod>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Rental Duration'),
          children: durations.map((RentalPeriod period) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, period);
              },
              child: Text(period.value),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _period = selected;

        _updateEndDate();
      });

      if (widget.onTimeChanged != null) {
        widget.onTimeChanged!(_startDate, _endDate, _period);
      }
    }
  }

  void _updateEndDate() {
    _endDate = _startDate.add(Duration(hours: (_period.hour)));
    if (widget.callBack != null) widget.callBack!(_period.hour);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: secondaryColor,
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
          // Start date and time (clickable)
          InkWell(
            onTap: _selectStartDate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(_startDate),
                  style: const TextStyle(
                    color: Color(0xFFB8D8A0), // Light green text
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_getWeekday(_startDate)} ${_formatTime(_startDate)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),

          // Middle time label (clickable)
          InkWell(
            onTap: _selectDuration,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.5,
                  ),
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                _period.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),

          // End date and time (auto-calculated)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(_endDate),
                style: const TextStyle(
                  color: Color(0xFFB8D8A0), // Light green text
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_getWeekday(_endDate)} ${_formatTime(_endDate)}',
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

import 'package:flutter/material.dart';

class CostItem extends StatelessWidget {
  final String title;
  final String amount;
  final bool isHighlighted;

  const CostItem({
    super.key,
    required this.title,
    required this.amount,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
      color: isHighlighted ? Colors.red : null,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textStyle,
        ),
        Text(
          amount,
          style: textStyle,
        ),
      ],
    );
  }
}

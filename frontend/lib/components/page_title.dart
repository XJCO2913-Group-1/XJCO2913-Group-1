import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String title;
  final double lineWidth;
  final double lineHeight;
  final Color lineColor;

  const PageTitle({
    super.key,
    required this.title,
    this.lineWidth = 60,
    this.lineHeight = 3,
    this.lineColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Container(
              width: lineWidth,
              height: lineHeight,
              color: lineColor,
            ),
          ],
        ),
      ],
    );
  }
}

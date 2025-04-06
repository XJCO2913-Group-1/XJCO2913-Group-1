import 'package:flutter/material.dart';

class FunctionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color fontColor;
  final Function() func;

  const FunctionButton({
    super.key,
    required this.text,
    required this.color,
    required this.fontColor,
    required this.func,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: TextButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        onPressed: func,
        child: Text(text,
            style: TextStyle(
              color: fontColor,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TagButton extends StatelessWidget {
  const TagButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.green : Colors.grey[200],
          foregroundColor: isActive ? Colors.white : Colors.black87,
          elevation: isActive ? 2 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

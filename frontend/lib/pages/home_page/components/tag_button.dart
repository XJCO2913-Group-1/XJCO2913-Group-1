import 'package:easy_scooter/pages/home_page/scooters_page.dart';
import 'package:flutter/material.dart';

class TagButton extends StatelessWidget {
  const TagButton({
    super.key,
    required this.context,
    required this.label,
  });

  final BuildContext context;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScootersPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black87,
          elevation: 0,
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

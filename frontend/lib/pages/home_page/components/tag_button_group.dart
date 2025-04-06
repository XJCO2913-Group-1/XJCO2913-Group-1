import 'package:easy_scooter/pages/home_page/components/tag_button.dart';
import 'package:flutter/material.dart';

class TagButtonGroup extends StatelessWidget {
  const TagButtonGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TagButton(context: context, label: 'All'),
            TagButton(context: context, label: 'Nearby'),
            TagButton(context: context, label: 'Available'),
            TagButton(context: context, label: 'Discount'),
            TagButton(context: context, label: 'City Scooter'),
            TagButton(context: context, label: 'Mountain Scooter'),
            TagButton(context: context, label: 'Folding Scooter'),
            TagButton(context: context, label: 'Electric Scooter'),
            TagButton(context: context, label: 'Kids Scooter'),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

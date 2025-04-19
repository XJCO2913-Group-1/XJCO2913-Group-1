import 'package:easy_scooter/pages/home_page/components/tag_button.dart';
import 'package:easy_scooter/providers/scooters_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagButtonGroup extends StatefulWidget {
  final String currentModel;
  final Function(String) onModelChanged;

  const TagButtonGroup({
    super.key,
    required this.currentModel,
    required this.onModelChanged,
  });

  @override
  State<TagButtonGroup> createState() => _TagButtonGroupState();
}

class _TagButtonGroupState extends State<TagButtonGroup> {
  String get _activeTag =>
      widget.currentModel.isEmpty ? 'All' : widget.currentModel;

  void _onTagPressed(String tag) {
    widget.onModelChanged(tag);
  }

  @override
  Widget build(BuildContext context) {
    final scooterProvider = Provider.of<ScootersProvider>(context);
    final Set<String> uniqueModels = scooterProvider.scooters
        .map((scooter) => scooter.model ?? 'Unknown')
        .toSet();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TagButton(
              label: 'All',
              isActive: _activeTag == 'All',
              onPressed: () => _onTagPressed('All'),
            ),
            ...uniqueModels.map((model) => TagButton(
                  label: model,
                  isActive: _activeTag == model,
                  onPressed: () => _onTagPressed(model),
                )),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

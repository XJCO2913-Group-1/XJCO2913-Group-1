import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:easy_scooter/pages/home_page/scooters_page/page.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onResetMapView;

  const MapControls({
    Key? key,
    required this.onResetMapView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 滑板车列表按钮
        Positioned(
          top: 0,
          left: 5,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScootersPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: availableColor.withAlpha(204),
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.electric_scooter),
                SizedBox(width: 5),
                Text('Available Scooters'),
              ],
            ),
          ),
        ),

        // 地图重置按钮
        Positioned(
          top: 0,
          right: 10,
          child: FloatingActionButton(
            heroTag: 'resetMapButton',
            mini: true,
            backgroundColor: availableColor.withAlpha(204),
            foregroundColor: primaryColor,
            onPressed: onResetMapView,
            elevation: 3,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}

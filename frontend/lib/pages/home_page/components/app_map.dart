import 'package:easy_scooter/providers/scooters_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AppMap extends StatelessWidget {
  final List<Marker> markers;
  final MapController? mapController;

  const AppMap({
    Key? key,
    required this.markers,
    this.mapController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(30.76309138557076, 103.98528926875007),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://webrd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
          userAgentPackageName: 'com.example.easy_scooter"',
        ),
        MarkerLayer(
          markers: markers,
        ),
        RichAttributionWidget(
          attributions: [],
        ),
      ],
    );
  }
}

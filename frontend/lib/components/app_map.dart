import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AppMap extends StatefulWidget {
  const AppMap({super.key});
  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  final MapOptions mapOptions = MapOptions(
    initialCenter: LatLng(30.76309138557076, 103.98528926875007),
    initialZoom: 15,
  );
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: mapOptions,
      children: [
        TileLayer(
          urlTemplate:
              'https://webrd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
          userAgentPackageName: 'com.example.easy_scooter"',
        ),
        RichAttributionWidget(
          attributions: [],
        ),
      ],
    );
  }
}

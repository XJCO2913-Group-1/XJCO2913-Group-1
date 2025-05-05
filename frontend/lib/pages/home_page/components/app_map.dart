import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_scooter/models/bound.dart';

class AppMap extends StatelessWidget {
  final List<Marker> markers;
  final MapController? mapController;
  final List<Bound>? noParkingZones;

  const AppMap({
    Key? key,
    required this.markers,
    this.mapController,
    this.noParkingZones,
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
        // No-parking zones rectangles
        if (noParkingZones != null && noParkingZones!.isNotEmpty)
          PolygonLayer(
            polygons: noParkingZones!.map((zone) {
              return Polygon(
                points: [
                  LatLng(zone.northeast[0], zone.northeast[1]),
                  LatLng(zone.northeast[0], zone.southwest[1]),
                  LatLng(zone.southwest[0], zone.southwest[1]),
                  LatLng(zone.southwest[0], zone.northeast[1]),
                ],
                color: Colors.red.withOpacity(0.3),
                borderColor: Colors.red,
                borderStrokeWidth: 2.0,
              );
            }).toList(),
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

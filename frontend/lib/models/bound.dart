class Bound {
  final List<double> northeast;
  final List<double> southwest;

  const Bound({
    required this.northeast,
    required this.southwest,
  });

  factory Bound.fromJson(Map<String, dynamic> json) {
    return Bound(
      northeast: [
        json['coordinates'][0]['lat'].toDouble(),
        json['coordinates'][0]['lng'].toDouble(),
      ],
      southwest: [
        json['coordinates'][1]['lat'].toDouble(),
        json['coordinates'][1]['lng'].toDouble(),
      ],
    );
  }
}

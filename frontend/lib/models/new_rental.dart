class NewRental {
  final int scooterId;
  final DateTime startTime;
  final DateTime endTime;
  final double cost;
  final String rentalPeriod;

  NewRental({
    required this.scooterId,
    required this.startTime,
    required this.endTime,
    required this.cost,
    required this.rentalPeriod,
  });
}

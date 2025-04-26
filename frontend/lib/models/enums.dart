enum PayType {
  newRental,
  editRental,
}

enum RentalPeriod {
  oneHour(value: '1hr', hour: 1, discount: 1),
  fourHours(value: '4hrs', hour: 4, discount: 0.9),
  oneDay(value: '1day', hour: 24, discount: 0.8),
  oneWeek(value: '1week', hour: 24 * 7, discount: 0.7);

  final String value;
  final int hour;
  final double discount;

  const RentalPeriod(
      {required this.value, required this.hour, required this.discount});
  String get getValue => value;
  int get getHour => hour;
}

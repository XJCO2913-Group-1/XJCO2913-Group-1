class CardTransaction {
  final int id;
  final DateTime date;
  final double amount;
  final String currency;

  CardTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.currency,
  });
}

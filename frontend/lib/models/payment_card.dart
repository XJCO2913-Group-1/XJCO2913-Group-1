class PaymentCard {
  final int id;
  final String cardHolerName;
  final String cardNumberLast4;
  final String cardExpiryMonth;
  final String cardExpiryYear;
  final String cardType;
  final bool isDefault;
  const PaymentCard({
    required this.id,
    required this.cardHolerName,
    required this.cardNumberLast4,
    required this.cardExpiryMonth,
    required this.cardExpiryYear,
    required this.cardType,
    required this.isDefault,
  });
}

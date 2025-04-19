import 'package:easy_scooter/models/payment_card.dart';
import 'package:easy_scooter/utils/http_client.dart';

class PaymentCardService {
  PaymentCardService._internal();

  static final PaymentCardService _instance = PaymentCardService._internal();

  factory PaymentCardService() => _instance;

  final HttpClient _httpClient = HttpClient();

  final endpoint = '/payment-cards';

  Future<bool> addPaymentCard({
    required String holderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? cardType,
    bool? isDefault,
    bool? saveForFuture,
  }) async {
    final response = await _httpClient.post('$endpoint/', data: {
      "card_holder_name": holderName,
      "card_number": cardNumber,
      "card_expiry_month": expiryMonth,
      "card_expiry_year": expiryYear,
      "cvv": cvv,
      "card_type": cardType,
      "is_default": isDefault ?? false,
      "save_for_future": saveForFuture ?? false
    });
    return response.statusCode == 201;
  }

  PaymentCard parse(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      cardHolerName: json['card_holder_name'],
      cardNumberLast4: json['card_number_last4'],
      cardExpiryMonth: json['card_expiry_month'],
      cardExpiryYear: json['card_expiry_year'],
      cardType: json['card_type'],
      isDefault: json['is_default'],
    );
  }

  Future<List<PaymentCard>> getPaymentCards() async {
    final response = await _httpClient.get('$endpoint/');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => parse(e)).toList();
    } else {
      return [];
    }
  }

  Future<PaymentCard> getPaymentCardById(int id) async {
    final response = await _httpClient.get('$endpoint/$id');
    return parse(response.data);
  }

  Future<void> deletePaymentCard(int id) async {
    await _httpClient.delete('$endpoint/$id');
  }

  Future<void> setDefault(int id) async {
    await _httpClient.put('$endpoint/$id/set_default');
  }
}

// 示例预定订单数据
class ReservationData {
  static List<Map<String, dynamic>> getReservations() {
    return [
      {
        'orderId': 'ORD123456789',
        'vehicleModel': 'Electric Scooter Pro',
        'vehicleId': 'SC-2023-0001',
        'reservationTime': DateTime.now().subtract(const Duration(hours: 2)),
        'startTime': DateTime.now().add(const Duration(hours: 1)),
        'status': 'Reserved',
        'location': 'Station A - 123 Main Street',
      },
      {
        'orderId': 'ORD987654321',
        'vehicleModel': 'City E-Bike',
        'vehicleId': 'EB-2023-0042',
        'reservationTime': DateTime.now().subtract(const Duration(hours: 5)),
        'startTime': DateTime.now().add(const Duration(hours: 3)),
        'status': 'Reserved',
        'location': 'Station B - 456 Park Avenue',
      },
      {
        'orderId': 'ORD456789123',
        'vehicleModel': 'Mountain E-Bike',
        'vehicleId': 'EB-2023-0078',
        'reservationTime': DateTime.now().subtract(const Duration(hours: 1)),
        'startTime': DateTime.now().add(const Duration(hours: 4)),
        'status': 'Reserved',
        'location': 'Station C - 789 River Road',
      },
    ];
  }
}

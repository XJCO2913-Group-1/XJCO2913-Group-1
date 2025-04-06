// 预定订单数据模型
class Reservation {
  final String orderId;
  final String vehicleModel;
  final String vehicleId;
  final DateTime reservationTime;
  final DateTime startTime;
  final String status;
  final String location;

  const Reservation({
    required this.orderId,
    required this.vehicleModel,
    required this.vehicleId,
    required this.reservationTime,
    required this.startTime,
    required this.status,
    required this.location,
  });

  // 从Map创建Reservation对象
  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      orderId: map['orderId'],
      vehicleModel: map['vehicleModel'],
      vehicleId: map['vehicleId'],
      reservationTime: map['reservationTime'],
      startTime: map['startTime'],
      status: map['status'],
      location: map['location'],
    );
  }

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'vehicleModel': vehicleModel,
      'vehicleId': vehicleId,
      'reservationTime': reservationTime,
      'startTime': startTime,
      'status': status,
      'location': location,
    };
  }
}

// 示例预定订单数据
class ReservationData {
  static List<Map<String, dynamic>> getReservations() {
    return [
      {
        'orderId': 'ORD123456789',
        'vehicleModel': 'Electric Scooter Pro11111111111111111111',
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

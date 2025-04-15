// 预定订单数据模型
class Rental {
  final int id;
  final int scooterId;
  final String scooterName;
  // final DateTime reservationTime;
  final DateTime startTime;
  final DateTime endTime;
  final String rentalPeriod;
  final double cost;
  final String location;
  final String status;

  const Rental({
    required this.id,
    required this.scooterId,
    required this.scooterName,
    // required this.reservationTime,
    required this.startTime,
    required this.endTime,
    required this.rentalPeriod,
    required this.cost,
    required this.location,
    required this.status,
  });

  // // 从Map创建Reservation对象
  // factory Rental.fromMap(Map<String, dynamic> map) {
  //   return Rental(
  //     orderId: map['orderId'],
  //     vehicleModel: map['vehicleModel'],
  //     vehicleId: map['vehicleId'],
  //     reservationTime: map['reservationTime'],
  //     startTime: map['startTime'],
  //     status: map['status'],
  //     location: map['location'],
  //   );
  // }

  // // 转换为Map
  // Map<String, dynamic> toMap() {
  //   return {
  //     'orderId': orderId,
  //     'vehicleModel': vehicleModel,
  //     'vehicleId': vehicleId,
  //     'reservationTime': reservationTime,
  //     'startTime': startTime,
  //     'status': status,
  //     'location': location,
  //   };
  // }
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

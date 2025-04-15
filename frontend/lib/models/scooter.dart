// 滑板车信息数据模型
class ScooterInfo {
  final int id;
  final String name;
  final double distance;
  final String location;
  final double rating;
  final double price;
  final String status;

  const ScooterInfo({
    required this.id,
    required this.name,
    required this.distance,
    required this.location,
    required this.rating,
    required this.price,
    required this.status,
  });

//   // 从Map创建ScooterInfo对象
//   factory ScooterInfo.fromMap(Map<String, dynamic> map) {
//     return ScooterInfo(
//       id: map['id'],
//       name: map['name'],
//       distance: map['distance'],
//       location: map['location'],
//       rating: map['rating'],
//       price: map['price'],
//     );
//   }

//   // 转换为Map
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'distance': distance,
//       'location': location,
//       'rating': rating,
//       'price': price,
//     };
//   }
// }

// // 示例滑板车数据
// class ScooterData {
//   static List<ScooterInfo> getScooters() {
//     return [
//       ScooterInfo(
//         id: 'EB-2023-0001',
//         name: 'City Scooter',
//         distance: 0.5,
//         location: '北京市海淀区中关村大街1号',
//         rating: 4.5,
//         price: 15.0,
//       ),
//       ScooterInfo(
//         id: 'EB-2023-0002',
//         name: 'Mountain Scooter',
//         distance: 0.8,
//         location: '北京市海淀区学院路15号',
//         rating: 4.0,
//         price: 18.0,
//       ),
//       ScooterInfo(
//         id: 'EB-2023-0003',
//         name: 'Folding Scooter',
//         distance: 1.2,
//         location: '北京市朝阳区建国门外大街1号',
//         rating: 3.5,
//         price: 12.0,
//       ),
//       ScooterInfo(
//         id: 'EB-2023-0004',
//         name: 'City Scooter',
//         distance: 1.5,
//         location: '北京市西城区西单北大街120号',
//         rating: 5.0,
//         price: 20.0,
//       ),
//       ScooterInfo(
//         id: 'EB-2023-0005',
//         name: 'Mountain Scooter',
//         distance: 2.0,
//         location: '北京市东城区东单北大街1号',
//         rating: 4.2,
//         price: 16.5,
//       ),
//     ];
//   }

//   // 获取原始Map数据
//   static List<Map<String, dynamic>> getRawScooters() {
//     return [
//       {
//         'id': 'EB-2023-0001',
//         'name': 'City Scooter',
//         'distance': 0.5,
//         'location': '北京市海淀区中关村大街1号',
//         'rating': 4.5,
//         'price': 15.0,
//       },
//       {
//         'id': 'EB-2023-0002',
//         'name': 'Mountain Scooter',
//         'distance': 0.8,
//         'location': '北京市海淀区学院路15号',
//         'rating': 4.0,
//         'price': 18.0,
//       },
//       {
//         'id': 'EB-2023-0003',
//         'name': 'Folding Scooter',
//         'distance': 1.2,
//         'location': '北京市朝阳区建国门外大街1号',
//         'rating': 3.5,
//         'price': 12.0,
//       },
//       {
//         'id': 'EB-2023-0004',
//         'name': 'City Scooter',
//         'distance': 1.5,
//         'location': '北京市西城区西单北大街120号',
//         'rating': 5.0,
//         'price': 20.0,
//       },
//       {
//         'id': 'EB-2023-0005',
//         'name': 'Mountain Scooter',
//         'distance': 2.0,
//         'location': '北京市东城区东单北大街1号',
//         'rating': 4.2,
//         'price': 16.5,
//       },
//     ];
//   }
}

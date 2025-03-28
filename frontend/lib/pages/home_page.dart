import 'package:easy_scooter/components/app_map.dart';
import 'package:flutter/material.dart';

import '../components/bike_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 示例单车数据
  final List<Map<String, dynamic>> _bikesData = [
    {
      'bikeId': 'EB-2023-0001',
      'bikeModel': 'City Scooter',
      'distance': 0.5,
      'location': '北京市海淀区中关村大街1号',
    },
    {
      'bikeId': 'EB-2023-0002',
      'bikeModel': 'Mountain Scooter',
      'distance': 0.8,
      'location': '北京市海淀区学院路15号',
    },
    {
      'bikeId': 'EB-2023-0003',
      'bikeModel': 'Folding Scooter',
      'distance': 1.2,
      'location': '北京市朝阳区建国门外大街1号',
    },
    {
      'bikeId': 'EB-2023-0004',
      'bikeModel': 'City Scooter',
      'distance': 1.5,
      'location': '北京市西城区西单北大街120号',
    },
    {
      'bikeId': 'EB-2023-0005',
      'bikeModel': 'Mountain Scooter',
      'distance': 2.0,
      'location': '北京市东城区东单北大街1号',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.warning, color: Colors.amber),
                      iconSize: 30,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // 地图组件
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: AppMap(),
                ),
                // 底部可滑动卡片组件
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  height: 180,
                  child: PageView.builder(
                    itemCount: _bikesData.length,
                    controller: PageController(viewportFraction: 0.95),
                    itemBuilder: (context, index) {
                      final bike = _bikesData[index];
                      return BikeCard(
                        bikeId: bike['bikeId'],
                        bikeModel: bike['bikeModel'],
                        distance: bike['distance'],
                        location: bike['location'],
                        onTap: () {
                          // 处理卡片点击事件
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('选择了单车: ${bike['bikeId']}')));
                        },
                        onNavigate: () {
                          // 处理导航按钮点击事件
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('导航到单车: ${bike['bikeId']}')));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

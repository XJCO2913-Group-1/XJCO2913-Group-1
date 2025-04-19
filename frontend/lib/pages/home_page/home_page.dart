import 'package:easy_scooter/pages/home_page/components/app_map.dart';
import 'package:easy_scooter/pages/home_page/components/tag_button_group.dart';
import 'package:easy_scooter/pages/home_page/feedback/page.dart';
import 'package:easy_scooter/pages/home_page/scooters_page.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import '../../components/scooter_card.dart';
import '../../providers/scooters_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentModel = 'All'; // 添加当前型号状态变量
  final MapController _mapController = MapController(); // 添加地图控制器
  final PageController _pageController =
      PageController(viewportFraction: 0.95); // 添加PageController控制底部卡片

  @override
  void initState() {
    super.initState();
    // 使用Provider获取滑板车数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScootersProvider>(context, listen: false).fetchScooters();
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // 释放控制器资源
    super.dispose();
  }

  // 处理型号更改
  void _onModelChanged(String model) {
    setState(() {
      currentModel = model;
    });
  }

  // 添加处理marker点击的方法
  void _onMarkerTap(LatLng position, int index) {
    _mapController.move(position, 17.0); // 移动地图到标记位置并放大
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ); // 滚动到对应的卡片
  }

  // 添加重置地图视图的方法
  void _resetMapView() {
    // 如果有滑板车数据，将地图中心设置到第一个滑板车位置
    final scooters =
        Provider.of<ScootersProvider>(context, listen: false).scooters;
    if (scooters.isNotEmpty) {
      _mapController.move(scooters[0].latLng, 15.0);
    } else {
      // 如果没有滑板车数据，则移动到默认位置（可根据需要调整）
      _mapController.move(LatLng(39.9042, 116.4074), 15.0); // 默认位置示例
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 4.0,
                right: 4.0,
                bottom: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(128),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(1, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.warning, color: Colors.grey),
                          iconSize: 30,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FeedBackPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // 添加水平滚动的标签组
                    TagButtonGroup(
                      currentModel: currentModel,
                      onModelChanged: _onModelChanged,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // 地图组件
                  Consumer<ScootersProvider>(
                    builder: (context, value, child) => SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: AppMap(
                        mapController: _mapController, // 传递地图控制器
                        markers: Provider.of<ScootersProvider>(context,
                                listen: false)
                            .scooters
                            .asMap()
                            .entries
                            .map(
                          (entry) {
                            final index = entry.key;
                            final scooter = entry.value;
                            return Marker(
                              point: scooter.latLng,
                              key: ValueKey(scooter.id),
                              width: 80,
                              height: 80,
                              child: GestureDetector(
                                onTap: () =>
                                    _onMarkerTap(scooter.latLng, index),
                                child: Icon(
                                  Icons.electric_scooter,
                                  color: currentModel == "All" ||
                                          scooter.model == currentModel
                                      ? scooter.status == "available"
                                          ? Colors.red
                                          : Colors.blueGrey[400]
                                      : Colors.transparent,
                                  size: 30,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                  // 底部可滑动卡片组件
                  Positioned(
                    top: 0,
                    left: 5,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScootersPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: availableColor.withAlpha(204),
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.electric_scooter),
                          SizedBox(width: 5),
                          Text('Available Scooters'),
                        ],
                      ),
                    ),
                  ),
                  // 添加地图重置按钮到右上角
                  Positioned(
                    top: 0,
                    right: 10,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: availableColor.withAlpha(204),
                      foregroundColor: primaryColor,
                      onPressed: _resetMapView,
                      elevation: 3,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: Consumer<ScootersProvider>(
                      builder: (context, scootersProvider, child) {
                        if (scootersProvider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 28, 49, 44),
                            ),
                          );
                        } else if (scootersProvider.error != null) {
                          return Center(
                            child: Text(
                              '加载失败: ${scootersProvider.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (scootersProvider.scooters.isEmpty) {
                          return const Center(
                            child: Text('没有可用的滑板车'),
                          );
                        } else {
                          return PageView.builder(
                            itemCount: scootersProvider.scooters.length,
                            controller: _pageController, // 使用PageController
                            itemBuilder: (context, index) {
                              final bike = scootersProvider.scooters[index];
                              return ScooterCard(
                                id: bike.id,
                                model: bike.model,
                                status: bike.status,
                                distance: bike.distance,
                                location: bike.location,
                                rating: bike.rating,
                                price: bike.price ?? 10.0,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 创建标签按钮
}

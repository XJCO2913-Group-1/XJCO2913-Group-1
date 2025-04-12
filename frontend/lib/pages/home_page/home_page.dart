import 'package:easy_scooter/components/app_map.dart';

import 'package:easy_scooter/pages/home_page/components/tag_button_group.dart';
import 'package:easy_scooter/pages/home_page/feed_back_page.dart';

import 'package:flutter/material.dart';

import '../../components/scooter_card.dart';
import '../../models/scooter.dart';
import '../../services/scooter_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 滑板车数据列表
  List<ScooterInfo> _scooterData = [];
  // 加载状态
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 异步获取滑板车数据
    _fetchScooterData();
  }

  // 从ScooterService获取滑板车数据的异步函数
  Future<void> _fetchScooterData() async {
    try {
      final scooterService = ScooterService();
      final scooters = await scooterService.getScooters();
      setState(() {
        _scooterData = scooters;
        _isLoading = false;
      });
    } catch (e) {
      // 如果获取失败，使用本地数据作为备份
      setState(() {
        _scooterData = ScooterData.getScooters();
        _isLoading = false;
      });
      print('获取滑板车数据失败: $e');
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
                                  color: Colors.grey.withValues(
                                    alpha: 0.5,
                                  ),
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
                    TagButtonGroup(),
                  ],
                ),
              ),
            ),
            Expanded(
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
                    height: 140,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 28, 49, 44),
                            ),
                          )
                        : PageView.builder(
                            itemCount: _scooterData.length,
                            controller: PageController(viewportFraction: 0.95),
                            itemBuilder: (context, index) {
                              final bike = _scooterData[index];
                              return ScooterCard(
                                id: bike.id,
                                name: bike.name,
                                distance: bike.distance,
                                location: bike.location,
                                rating: bike.rating,
                                price: bike.price,
                              );
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

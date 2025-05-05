import 'package:easy_scooter/models/bound.dart';
import 'package:easy_scooter/pages/home_page/components/app_map.dart';
import 'package:easy_scooter/pages/home_page/components/bottom_scooter_cards.dart';
import 'package:easy_scooter/pages/home_page/components/map_controls.dart';
import 'package:easy_scooter/pages/home_page/components/search_bar.dart';
import 'package:easy_scooter/pages/home_page/components/tag_button_group.dart';
import 'package:easy_scooter/services/no_parking_zones_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/scooters_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentModel = 'All';
  final MapController _mapController = MapController();
  PageController? _pageController;
  List<Bound> noParkingZones = [];
  bool _isLoading = true;
  bool _isPageControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScootersProvider>(context, listen: false).fetchScooters();
      _fetchNoParkingZones();
    });
  }

  // 获取禁停区域数据
  Future<void> _fetchNoParkingZones() async {
    try {
      final zones = await NoParkingZonesService().getNoParkingZones();
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          noParkingZones = zones;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching no parking zones: $e');
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
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
    _pageController?.animateToPage(
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
    // 检测是否为桌面设备（Windows）
    final bool isDesktop =
        Theme.of(context).platform == TargetPlatform.windows ||
            Theme.of(context).platform == TargetPlatform.linux ||
            Theme.of(context).platform == TargetPlatform.macOS;

    // 根据设备类型调整卡片控制器的视口比例
    final double viewportFraction = isDesktop ? 0.6 : 0.95;

    // 确保正确初始化PageController
    if (_pageController == null) {
      _pageController = PageController(viewportFraction: viewportFraction);
      _isPageControllerInitialized = true;
    } else if (_pageController!.viewportFraction != viewportFraction) {
      // 如果视口比例需要调整
      final int currentPage = _pageController!.hasClients
          ? (_pageController!.page?.round() ?? 0)
          : 0;
      _pageController!.dispose();
      _pageController = PageController(
        viewportFraction: viewportFraction,
        initialPage: currentPage,
      );
    }

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
                    // 使用搜索栏组件
                    const SearchBarWidget(),
                    // 使用标签按钮组组件
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
                  Consumer<ScootersProvider>(builder: (context, value, child) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: AppMap(
                        mapController: _mapController,
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
                        noParkingZones: noParkingZones,
                      ),
                    );
                  }),

                  // 使用地图控件组件
                  MapControls(
                    onResetMapView: _resetMapView,
                  ),

                  // 使用底部滚动卡片组件
                  if (_pageController != null)
                    BottomScooterCards(
                      pageController: _pageController!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

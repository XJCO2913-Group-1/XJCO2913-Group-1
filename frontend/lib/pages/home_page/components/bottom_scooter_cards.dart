import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';

import '../../../components/scooter_card.dart';
import '../../../providers/scooters_provider.dart';

// 自定义滚动行为类，支持所有平台的拖动滚动
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // 添加鼠标支持
        ...super.dragDevices,
      };
}

class BottomScooterCards extends StatelessWidget {
  final PageController pageController;

  const BottomScooterCards({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
            return ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: PageView.builder(
                itemCount: scootersProvider.scooters.length,
                controller: pageController,
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
              ),
            );
          }
        },
      ),
    );
  }
}

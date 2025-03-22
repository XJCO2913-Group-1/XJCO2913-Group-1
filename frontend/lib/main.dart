import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io' show Platform;
import 'components/main_navigation.dart';
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart'; // AM

List<CameraDescription> cameras = [];

class ConstConfig {
  static const amapApiKeys = AMapApiKey(
    androidKey: 'd45d464c91163b1def65dfbcb295d33e',
    iosKey: 'd45d464c91163b1def65dfbcb295d33e',
  );

  static const amapPrivacyStatement = AMapPrivacyStatement(
    hasContains: true,
    hasShow: true,
    hasAgree: true,
  );
}

Future<void> main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 获取可用相机列表
  if (!Platform.isWindows) {
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      debugPrint('相机初始化错误: ${e.description}');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AMapInitializer.init(context, apiKey: ConstConfig.amapApiKeys);
    AMapInitializer.updatePrivacyAgree(ConstConfig.amapPrivacyStatement);
    return MaterialApp(
      title: 'easy_scooter_fe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 28, 49, 44)),
      ),
      home: const MainNavigation(),
    );
  }
}

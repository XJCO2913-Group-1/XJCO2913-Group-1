import 'package:easy_scooter/pages/welcome_page.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

import 'providers/user_provider.dart';
import 'providers/rentals_provider.dart';
import 'providers/scooters_provider.dart';

List<CameraDescription> cameras = [];

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => RentalsProvider()),
        ChangeNotifierProvider(create: (context) => ScootersProvider()),
        ChangeNotifierProvider(create: (context) => PaymentCardProvider()),
      ],
      child: MaterialApp(
        title: 'Easy Scooter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: backgroundColor,
          ),
          fontFamily: 'AlibabaSans',
        ),
        home: const WelcomePage(),
      ),
    );
  }
}

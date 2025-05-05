import 'package:easy_scooter/pages/welcome_page.dart';
import 'package:easy_scooter/providers/llm_provider.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:easy_scooter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'providers/user_provider.dart';
import 'providers/rentals_provider.dart';
import 'providers/scooters_provider.dart';

// List<CameraDescription> cameras = [];

Future<void> main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // // 获取可用相机列表
  // if (!Platform.isWindows) {
  //   try {
  //     cameras = await availableCameras();
  //   } on CameraException catch (e) {
  //     debugPrint('相机初始化错误: ${e.description}');
  //   }
  // }

  runApp(const MyApp());
}

// Helper function to check if the platform is a mobile device
bool get isMobileDevice {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
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
        ChangeNotifierProvider(create: (context) => LlmProvider()),
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
        builder: (context, child) {
          // For mobile devices, return the normal layout
          if (isMobileDevice) {
            return child!;
          }

          // For web or desktop, wrap the app content in a fixed-width container
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800, // 修改为800
                maxHeight: 700, // 修改为600
              ),
              child: child!,
            ),
          );
        },
        home: const WelcomePage(),
      ),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/main.dart';
import 'package:easy_scooter/components/main_navigation.dart';

void main() {
  group('共享电动车应用测试', () {
    testWidgets('应用启动测试', (WidgetTester tester) async {
      // 构建应用并触发一次帧
      await tester.pumpWidget(const MyApp());

      // 验证应用成功启动并显示主导航
      expect(find.byType(MainNavigation), findsOneWidget);
    });

    // 导航测试已在navigation_test.dart中实现
    // 客户界面输入测试已在client_input_test.dart中实现
  });
}

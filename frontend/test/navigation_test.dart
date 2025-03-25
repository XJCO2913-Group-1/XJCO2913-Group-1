import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/components/main_navigation.dart';

void main() {
  testWidgets('Navigation bar switches pages correctly',
      (WidgetTester tester) async {
    // 构建应用并触发一次帧
    await tester.pumpWidget(const MaterialApp(home: MainNavigation()));

    // 验证初始页面是首页
    expect(find.text('Home'), findsOneWidget);

    // 点击客户服务选项卡
    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle(); // 等待动画完成

    // 验证已切换到客户服务页面
    expect(find.text('客户服务'), findsOneWidget);

    // 点击扫码选项卡
    await tester.tap(find.byIcon(Icons.qr_code_scanner));
    await tester.pumpAndSettle();

    // 验证已切换到扫码页面
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);

    // 点击预订选项卡
    await tester.tap(find.byIcon(Icons.book_online));
    await tester.pumpAndSettle();

    // 验证已切换到预订页面
    expect(find.byIcon(Icons.book_online), findsOneWidget);

    // 验证已切换到个人中心页面
    expect(find.byIcon(Icons.person), findsOneWidget);

    // 返回首页
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    // 验证已返回首页
    expect(find.text('Home'), findsOneWidget);
  });
}

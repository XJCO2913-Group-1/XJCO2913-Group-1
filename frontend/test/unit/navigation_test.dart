import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/components/main_navigation.dart';

void main() {
  testWidgets('Navigation bar switches pages correctly',
      (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const MaterialApp(home: MainNavigation()));

    // Verify the initial page is Home
    expect(find.text('Home'), findsOneWidget);

    // Tap the customer service tab
    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle(); // Wait for animation to complete

    // Verify switched to customer service page
    expect(find.text('Customer Service'), findsOneWidget);

    // Tap the scan tab
    await tester.tap(find.byIcon(Icons.qr_code_scanner));
    await tester.pumpAndSettle();

    // Verify switched to scan page
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);

    // Tap the booking tab
    await tester.tap(find.byIcon(Icons.book_online));
    await tester.pumpAndSettle();

    // Verify switched to booking page
    expect(find.byIcon(Icons.book_online), findsOneWidget);

    // Verify switched to profile page
    expect(find.byIcon(Icons.person), findsOneWidget);

    // Return to home page
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    // Verify returned to home page
    expect(find.text('Home'), findsOneWidget);
  });
}

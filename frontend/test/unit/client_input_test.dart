import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/pages/client_page.dart';

void main() {
  testWidgets('Client page input functionality test',
      (WidgetTester tester) async {
    // Build the customer service page
    await tester.pumpWidget(const MaterialApp(home: ClientPage()));

    // Verify page title
    expect(find.text('Customer Service'), findsOneWidget);

    // Verify message input field exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify send button exists
    expect(find.byIcon(Icons.send), findsOneWidget);

    // Verify initial message list display
    expect(find.byType(ListView), findsOneWidget);

    // Input a test message
    await tester.enterText(find.byType(TextField), 'This is a test message');
    expect(find.text('This is a test message'), findsOneWidget);

    // Click send button
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(); // Trigger a frame refresh

    // Wait for simulated customer service reply
    await tester.pump(const Duration(seconds: 2));

    // Verify message has been sent and displayed in message list
    expect(
        find.text(
            'Thank you for your inquiry. Our customer service team will respond shortly.'),
        findsOneWidget);

    // Test scroll functionality
    final listViewFinder = find.byType(ListView);
    await tester.drag(listViewFinder, const Offset(0, -300));
    await tester.pumpAndSettle();

    // Verify historical messages can be viewed by scrolling
    expect(
        find.text(
            'Hello! Welcome to the shared e-bike service. How may I help you?'),
        findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easy_scooter/pages/auth/loading_page.dart';
import 'package:easy_scooter/pages/auth/login_page.dart';
import 'package:easy_scooter/pages/auth/sign_up_page.dart';
import 'package:easy_scooter/pages/auth/verification_code_page.dart';
import 'package:easy_scooter/pages/auth/forgot_password_page.dart';

void main() {
  group('Authentication Page Navigation Tests', () {
    testWidgets('Auto navigate from welcome page to login page',
        (WidgetTester tester) async {
      // Arrange - Build welcome page
      await tester.pumpWidget(const MaterialApp(home: LoadingPage()));

      // Verify welcome page is loaded
      expect(find.text('Welcome To E-Scooter'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Wait for 2 seconds delay
      await tester.pump(const Duration(seconds: 2));
      // Wait for page transition animation to complete
      await tester.pumpAndSettle();

      // Assert - Verify navigation to login page
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Welcome To E-Scooter'),
          findsOneWidget); // Login page title
    });

    // 注意：由于LoadingPage现在自动跳转到LoginPage，不再有注册按钮，所以从LoginPage测试导航到SignUpPage
    testWidgets('Navigate from login page to sign up page',
        (WidgetTester tester) async {
      // Arrange - Build login page
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Verify login page is loaded
      expect(find.text('Welcome To E-Scooter'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      // Act - Find and tap the sign up link
      final signUpLinkFinder =
          find.text('No account yet? Sign up'); // Use correct link text
      expect(signUpLinkFinder, findsOneWidget);
      await tester.tap(signUpLinkFinder);
      await tester.pumpAndSettle(); // Wait for animation to complete

      // Assert - Verify navigation to sign up page
      expect(find.byType(SignUpPage), findsOneWidget);
      // Use more specific finder to find title in AppBar
      expect(find.widgetWithText(AppBar, 'Sign Up'),
          findsOneWidget); // Sign up page title
    });

    testWidgets('Navigate from login page to verification code page',
        (WidgetTester tester) async {
      // Arrange - Build login page
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Verify login page is loaded
      expect(find.text('Welcome To E-Scooter'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      // Act - Find and tap verification code login link
      // Use widgetPredicate to find TextButton containing verification code login
      final codeLoginFinder = find.byWidgetPredicate(
          (widget) =>
              widget is TextButton &&
              widget.child is RichText &&
              (widget.onPressed != null),
          description:
              'TextButton with RichText child (verification code login)');
      expect(codeLoginFinder, findsOneWidget);
      await tester.tap(codeLoginFinder);
      await tester.pumpAndSettle(); // Wait for animation to complete

      // Assert - Verify navigation to verification code page
      expect(find.byType(VerificationCodePage), findsOneWidget);
      expect(find.text('Verification Code Login'),
          findsOneWidget); // Verification code page title
    });

    testWidgets('Navigate from login page to forgot password page',
        (WidgetTester tester) async {
      // Arrange - Build login page
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Verify login page is loaded
      expect(find.text('Welcome To E-Scooter'), findsOneWidget);

      // Act - Find and tap forgot password link
      final forgotPasswordFinder = find.text('Forgot password?');
      expect(forgotPasswordFinder, findsOneWidget);
      await tester.tap(forgotPasswordFinder);
      await tester.pumpAndSettle(); // Wait for animation to complete

      // Assert - Verify navigation to forgot password page
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.text('Forgot Password'),
          findsOneWidget); // Forgot password page title
    });

    testWidgets('Test back button functionality', (WidgetTester tester) async {
      // Arrange - Build login page
      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      // Verify login page is loaded
      expect(find.text('Welcome To E-Scooter'), findsOneWidget);

      // Act - Find and tap back button
      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);
      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle(); // Wait for animation to complete

      // Assert - Verify return to previous page
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('Login page form validation test', (WidgetTester tester) async {
      // Arrange - Build login page
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Verify login page is loaded
      expect(find.text('Welcome To E-Scooter'), findsOneWidget);

      // Act - Enter invalid email and password
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(
          find.byType(TextFormField).at(1), '123'); // Short password

      // Click login button - Use ElevatedButton finder since button text might have multiple matches
      final loginButton = find.widgetWithText(ElevatedButton, 'Log In');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pump(); // Refresh interface

      // Assert - Verify form validation error message
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });
}

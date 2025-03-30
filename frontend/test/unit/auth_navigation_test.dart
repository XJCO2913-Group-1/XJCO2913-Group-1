import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easy_scooter/pages/auth/loading_page.dart';
import 'package:easy_scooter/pages/auth/login_page.dart';
import 'package:easy_scooter/pages/auth/sign_up_page.dart';
import 'package:easy_scooter/pages/auth/verification_code_page.dart';
import 'package:easy_scooter/pages/auth/forgot_password_page.dart';

void main() {
  group('Login Page Navigation Tests', () {
    testWidgets('Navigate from Welcome Page to Login Page',
        (WidgetTester tester) async {
      // Build welcome page
      await tester.pumpWidget(const MaterialApp(home: LoadingPage()));

      // Find and click login button
      final loginButtonFinder = find.text('Log In');
      expect(loginButtonFinder, findsOneWidget);
      await tester.tap(loginButtonFinder);
      await tester.pumpAndSettle();

      // Verify navigation to login page
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Navigate from Welcome Page to Sign Up Page',
        (WidgetTester tester) async {
      // Build welcome page
      await tester.pumpWidget(const MaterialApp(home: LoadingPage()));

      // Find and click sign up button
      final signUpButtonFinder = find.text('Sign Up');
      expect(signUpButtonFinder, findsOneWidget);
      await tester.tap(signUpButtonFinder);
      await tester.pumpAndSettle();

      // Verify navigation to sign up page
      expect(find.byType(SignUpPage), findsOneWidget);
    });

    testWidgets('Navigate from Login Page to Verification Code Page',
        (WidgetTester tester) async {
      // Build login page
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Find and click verification code login link
      final codeLoginFinder = find.text('code');
      expect(codeLoginFinder, findsOneWidget);
      await tester.tap(codeLoginFinder);
      await tester.pumpAndSettle();

      // Verify navigation to verification code page
      expect(find.byType(VerificationCodePage), findsOneWidget);
    });

    testWidgets('Navigate from Login Page to Forgot Password Page',
        (WidgetTester tester) async {
      // Build login page
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Find and click forgot password link
      final forgotPasswordFinder = find.text('Forgot password?');
      expect(forgotPasswordFinder, findsOneWidget);
      await tester.tap(forgotPasswordFinder);
      await tester.pumpAndSettle();

      // Verify navigation to forgot password page
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });

    testWidgets('Test Back Button Functionality', (WidgetTester tester) async {
      // Build login page
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Find and click back button
      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);
      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle();

      // Verify returned to previous page
      expect(find.byType(LoginPage), findsNothing);
    });
  });
}

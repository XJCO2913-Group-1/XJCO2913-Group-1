import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_scooter/pages/welcome_page.dart';
import 'package:easy_scooter/pages/auth/login_page.dart';
import 'package:easy_scooter/pages/auth/sign_up_page.dart';
import 'package:easy_scooter/pages/auth/verification_code_page.dart';
import 'package:easy_scooter/pages/auth/forgot_password_page.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:easy_scooter/models/token.dart';
import 'package:easy_scooter/models/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future? cancelFuture) async {
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override
  Token? get token => Token(
    accessToken: 'mock_token',
    tokenType: 'Bearer',
  );

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  User? get user => User(
    id: 1,
    name: '测试用户',
    email: 'test@example.com',
  );

  @override
  bool get isLoggedIn => false;

  @override
  Future<void> syncFromPrefs() async {
    notifyListeners();
  }

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    notifyListeners();
    return {
      'token': 'mock_token',
      'user': {
        'id': 1,
        'name': '测试用户',
        'email': email,
      }
    };
  }

  @override
  Future<void> register(String name, String email, String password) async {
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    notifyListeners();
  }

  @override
  Future<void> forgotPassword(String email) async {
    notifyListeners();
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    notifyListeners();
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    notifyListeners();
  }

  @override
  Future<void> sendVerificationCode(String email) async {
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    dio = Dio();
    dio.httpClientAdapter = FakeAdapter();
  });

  group('Authentication Page Navigation Tests', () {
    testWidgets('Auto navigate from welcome page to login page',
        (WidgetTester tester) async {
      final mockUserProvider = MockUserProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: mockUserProvider,
            child: const WelcomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on the login page
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Navigate from login to register page',
        (WidgetTester tester) async {
      final mockUserProvider = MockUserProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: mockUserProvider,
            child: const LoginPage(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap the register button - 使用更灵活的查找方式
      final registerButton = find.byWidgetPredicate(
        (widget) => widget is TextButton && 
                    widget.child is Text && 
                    (widget.child as Text).data?.contains('Sign Up') == true,
        description: 'TextButton with text containing "Sign Up"',
      );
      expect(registerButton, findsOneWidget);
      await tester.tap(registerButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on the register page
      expect(find.byType(SignUpPage), findsOneWidget);
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

    testWidgets('Test back button functionality',
        (WidgetTester tester) async {
      final mockUserProvider = MockUserProvider();

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => ChangeNotifierProvider<UserProvider>.value(
                  value: mockUserProvider,
                  child: const LoginPage(),
                ),
            '/signup': (context) => ChangeNotifierProvider<UserProvider>.value(
                  value: mockUserProvider,
                  child: const SignUpPage(),
                ),
          },
          initialRoute: '/signup',
        ),
      );

      await tester.pumpAndSettle();

      // 确保我们在注册页面
      expect(find.byType(SignUpPage), findsOneWidget);

      // 点击返回按钮
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 验证我们回到了登录页面
      expect(find.byType(LoginPage), findsOneWidget);
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

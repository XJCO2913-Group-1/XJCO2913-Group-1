import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:easy_scooter/models/user.dart';
import 'package:easy_scooter/models/token.dart';
import 'package:flutter/material.dart';

class MockUserProvider extends ChangeNotifier implements UserProvider {
  User? _user;
  bool _isLoggedIn = false;
  Token? _token;
  bool _isLoading = false;
  String? _error;

  @override
  User? get user => _user;
  
  @override
  bool get isLoggedIn => _isLoggedIn;
  
  @override
  Token? get token => _token;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception('邮箱不能为空');
      }
      if (password.isEmpty) {
        throw Exception('密码不能为空');
      }

      // 模拟登录成功
      _user = User(
        id: 1,
        email: email,
        name: '测试用户',
        avatar: 'https://example.com/avatar.jpg',
        school: '测试学校',
        age: 20,
      );
      _token = Token(
        accessToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        tokenType: 'Bearer',
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': '登录成功'};
    } catch (e) {
      _isLoading = false;
      _error = '登录失败: ${e.toString()}';
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  @override
  void logout() {
    _user = null;
    _isLoggedIn = false;
    _token = null;
    _error = null;
    notifyListeners();
  }

  @override
  Future<void> fetchUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_isLoggedIn) {
        throw Exception('用户未登录');
      }

      // 模拟获取用户信息
      _user = User(
        id: 1,
        email: 'test@example.com',
        name: '测试用户',
        avatar: 'https://example.com/avatar.jpg',
        school: '测试学校',
        age: 20,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '获取用户信息失败: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  Future<void> syncFromPrefs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟从本地存储同步
      _token = Token(
        accessToken: 'mock_token_from_preferences',
        tokenType: 'Bearer',
      );
      _isLoggedIn = true;
      _user = User(
        id: 1,
        email: 'test@example.com',
        name: '测试用户',
        avatar: 'https://example.com/avatar.jpg',
        school: '测试学校',
        age: 20,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '同步失败: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('MockUserProvider 测试', () {
    late MockUserProvider provider;

    setUp(() {
      provider = MockUserProvider();
    });

    test('基本属性', () {
      expect(provider.user, null);
      expect(provider.isLoggedIn, false);
      expect(provider.token, null);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('login 成功', () async {
      final result = await provider.login(
        email: 'test@example.com',
        password: 'password123',
      );
      
      expect(result['success'], true);
      expect(provider.user, isNotNull);
      expect(provider.user!.email, 'test@example.com');
      expect(provider.user!.name, '测试用户');
      expect(provider.user!.school, '测试学校');
      expect(provider.user!.age, 20);
      expect(provider.isLoggedIn, true);
      expect(provider.token, isNotNull);
      expect(provider.token!.accessToken, isNotNull);
      expect(provider.token!.tokenType, 'Bearer');
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('login 失败 - 空邮箱', () async {
      final result = await provider.login(
        email: '',
        password: 'password123',
      );
      
      expect(result['success'], false);
      expect(provider.user, null);
      expect(provider.isLoggedIn, false);
      expect(provider.token, null);
      expect(provider.error, isNotNull);
    });

    test('login 失败 - 空密码', () async {
      final result = await provider.login(
        email: 'test@example.com',
        password: '',
      );
      
      expect(result['success'], false);
      expect(provider.user, null);
      expect(provider.isLoggedIn, false);
      expect(provider.token, null);
      expect(provider.error, isNotNull);
    });

    test('logout 成功', () async {
      await provider.login(
        email: 'test@example.com',
        password: 'password123',
      );
      provider.logout();
      
      expect(provider.user, null);
      expect(provider.isLoggedIn, false);
      expect(provider.token, null);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('fetchUser 成功', () async {
      await provider.login(
        email: 'test@example.com',
        password: 'password123',
      );
      await provider.fetchUser();
      
      expect(provider.user, isNotNull);
      expect(provider.user!.email, 'test@example.com');
      expect(provider.user!.name, '测试用户');
      expect(provider.user!.school, '测试学校');
      expect(provider.user!.age, 20);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('fetchUser 失败 - 未登录', () async {
      await provider.fetchUser();
      
      expect(provider.user, null);
      expect(provider.error, isNotNull);
    });

    test('syncFromPrefs 成功', () async {
      await provider.syncFromPrefs();
      
      expect(provider.user, isNotNull);
      expect(provider.user!.email, 'test@example.com');
      expect(provider.user!.name, '测试用户');
      expect(provider.user!.school, '测试学校');
      expect(provider.user!.age, 20);
      expect(provider.isLoggedIn, true);
      expect(provider.token, isNotNull);
      expect(provider.token!.accessToken, 'mock_token_from_preferences');
      expect(provider.token!.tokenType, 'Bearer');
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });
  });
} 
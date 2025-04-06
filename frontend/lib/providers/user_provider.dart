import 'package:easy_scooter/models/token.dart';
import 'package:easy_scooter/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  // 私有构造函数
  UserProvider._internal();
  // 单例实例
  static final UserProvider _instance = UserProvider._internal();
  // 工厂构造函数
  factory UserProvider() => _instance;

  // 用户信息
  User? _user;
  // 登录状态
  bool _isLoggedIn = false;

  // Token
  Token? _token;
  // 加载状态
  bool _isLoading = false;
  // 错误信息
  String? _error;

  // 认证服务
  final AuthService _authService = AuthService();

  final UserService _userService = UserService();
  // Getters
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  Token? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 登录方法
  Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 调用AuthService的登录方法获取Token
      _token = await _authService.login(
        email: email,
        password: password,
      );

      // 登录成功，更新状态
      _isLoggedIn = true;

      notifyListeners();
      _user = await _userService.getCurrentUser();
      notifyListeners();

      // 保存Token到本地存储
      UserPrefs().setToken(_token!);

      return {'success': true, 'message': '登录成功'};
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      UserPrefs().removeToken();

      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 登出方法
  void logout() async {
    _user = null;
    _isLoggedIn = false;
    _token = null;
    _error = null;
    notifyListeners();
    UserPrefs().removeToken();
  }

  Future<void> syncFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = Token(
      accessToken: prefs.getString('accessToken') ?? '',
      tokenType: prefs.getString('tokenType') ?? '',
    );
    if (_token!.accessToken.isNotEmpty) {
      notifyListeners();
      try {
        _user = await _userService.getCurrentUser();
        _isLoggedIn = true;
      } catch (e) {
        _error = e.toString();
        logout();
        return;
      }
    }
    notifyListeners();
  }
}

class UserPrefs {
  UserPrefs._internal();
  static final UserPrefs _instance = UserPrefs._internal();
  factory UserPrefs() => _instance;

  static const String _accessToken = 'accessToken';
  static const String _tokenType = 'tokenType';

  void setToken(Token token) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(_accessToken, token.accessToken);
    preferences.setString(_tokenType, token.tokenType);
  }

  void removeToken() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.remove(_accessToken);
    preferences.remove(_tokenType);
  }
}

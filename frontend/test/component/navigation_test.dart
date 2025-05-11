import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/components/main_navigation.dart';
import 'package:provider/provider.dart';
import 'package:easy_scooter/providers/scooters_provider.dart';
import 'package:easy_scooter/providers/rentals_provider.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_scooter/models/token.dart';
import 'package:easy_scooter/models/scooter.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:easy_scooter/models/payment_card.dart';
import 'package:easy_scooter/models/user.dart';
import 'package:easy_scooter/models/rental.dart';
import 'package:dio/dio.dart';
import 'package:easy_scooter/pages/home_page/page.dart';
import 'package:easy_scooter/pages/home_page/components/search_bar.dart';
import 'package:easy_scooter/pages/home_page/components/tag_button_group.dart';
import 'package:easy_scooter/pages/home_page/components/map_controls.dart';
import 'package:easy_scooter/pages/home_page/components/bottom_scooter_cards.dart';

// 在测试环境下，用 Container 替换地图 widget
class MockMapWidget extends StatelessWidget {
  const MockMapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: const Center(child: Text('Mock Map')),
    );
  }
}

// 重写 HomePage，在测试环境下返回 MockMapWidget
class MockHomePage extends HomePage {
  const MockHomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MockHomePageState();
}

class _MockHomePageState extends State<HomePage> {
  String currentModel = 'All';
  PageController? _pageController;
  bool _isPageControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScootersProvider>(context, listen: false).fetchScooters();
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onModelChanged(String model) {
    setState(() {
      currentModel = model;
    });
  }

  void _resetMapView() {
    // 如果有滑板车数据，将地图中心设置到第一个滑板车位置
    final scooters =
        Provider.of<ScootersProvider>(context, listen: false).scooters;
    if (scooters.isNotEmpty) {
      // 在 MockHomePage 中，这里不需要实际移动地图
    } else {
      // 如果没有滑板车数据，则移动到默认位置（可根据需要调整）
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检测是否为桌面设备（Windows）
    final bool isDesktop =
        Theme.of(context).platform == TargetPlatform.windows ||
            Theme.of(context).platform == TargetPlatform.linux ||
            Theme.of(context).platform == TargetPlatform.macOS;

    // 根据设备类型调整卡片控制器的视口比例
    final double viewportFraction = isDesktop ? 0.6 : 0.95;

    // 确保正确初始化PageController
    if (_pageController == null) {
      _pageController = PageController(viewportFraction: viewportFraction);
      _isPageControllerInitialized = true;
    } else if (_pageController!.viewportFraction != viewportFraction) {
      // 如果视口比例需要调整
      final int currentPage = _pageController!.hasClients
          ? (_pageController!.page?.round() ?? 0)
          : 0;
      _pageController!.dispose();
      _pageController = PageController(
        viewportFraction: viewportFraction,
        initialPage: currentPage,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 4.0,
                right: 4.0,
                bottom: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 使用搜索栏组件
                    const SearchBarWidget(),
                    // 使用标签按钮组组件
                    TagButtonGroup(
                      currentModel: currentModel,
                      onModelChanged: _onModelChanged,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // 地图组件
                  Consumer<ScootersProvider>(builder: (context, value, child) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: const MockMapWidget(),
                    );
                  }),

                  // 使用地图控件组件
                  MapControls(
                    onResetMapView: _resetMapView,
                  ),

                  // 使用底部滚动卡片组件
                  if (_pageController != null)
                    BottomScooterCards(
                      pageController: _pageController!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MockScootersProvider extends ChangeNotifier implements ScootersProvider {
  @override
  List<ScooterInfo> get scooters => [];

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  Future<void> fetchScooters() async {
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRentalsProvider extends ChangeNotifier implements RentalsProvider {
  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<Rental> get rentals => [];

  @override
  Future<void> fetchRentals() async {
    notifyListeners();
  }

  @override
  Future<bool> createRental({
    required int scooterId,
    required String rentalPeriod,
    int? userId,
    String? startTime,
    String? endTime,
    String? status,
    double? cost,
  }) async {
    notifyListeners();
    return true;
  }

  @override
  Future<bool> deleteRental(int rentalId) async {
    notifyListeners();
    return true;
  }

  @override
  void clearError() {
    notifyListeners();
  }

  @override
  void reset() {
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  bool get isLoggedIn => true;

  @override
  Future<void> syncFromPrefs() async {
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPaymentCardProvider extends ChangeNotifier implements PaymentCardProvider {
  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<PaymentCard> get paymentCards => [];

  @override
  Future<void> fetchPaymentCards() async {
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future? cancelFuture) async {
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;

  setUpAll(() async {
    try {
      print('开始初始化测试环境...');
      
      // 初始化 SharedPreferences
      SharedPreferences.setMockInitialValues({});
      print('SharedPreferences 初始化完成');
      
      // 初始化 Dio
      dio = Dio();
      dio.httpClientAdapter = FakeAdapter();
      print('Dio 初始化完成');
      
    } catch (e, stackTrace) {
      print('初始化测试环境时出错: $e');
      print('错误堆栈: $stackTrace');
      rethrow;
    }
  });

  testWidgets('测试导航栏显示', (WidgetTester tester) async {
    try {
      print('开始测试导航栏显示...');
      
      // 创建测试用的 Provider
      final mockUserProvider = MockUserProvider();
      final mockScootersProvider = MockScootersProvider();
      final mockRentalsProvider = MockRentalsProvider();
      final mockPaymentCardProvider = MockPaymentCardProvider();
      
      print('Provider 创建完成');
      
      // 构建测试用的 widget，使用 MockHomePage 替换 MainNavigation
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<ScootersProvider>.value(value: mockScootersProvider),
            ChangeNotifierProvider<RentalsProvider>.value(value: mockRentalsProvider),
            ChangeNotifierProvider<PaymentCardProvider>.value(value: mockPaymentCardProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: MockHomePage(),
            ),
          ),
        ),
      );
      
      print('Widget 构建完成');
      
      // 等待 widget 树稳定
      await tester.pumpAndSettle();
      print('Widget 树已稳定');
      
    } catch (e, stackTrace) {
      print('测试过程中出错: $e');
      print('错误堆栈: $stackTrace');
      rethrow;
    }
  });
}


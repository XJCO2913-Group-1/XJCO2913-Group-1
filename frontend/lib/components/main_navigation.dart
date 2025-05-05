import 'package:flutter/material.dart';
import '../pages/home_page/page.dart';
import '../pages/client_page/page.dart';
import '../pages/scanner_page/page.dart';
import '../pages/book_page/book_page.dart';
import '../pages/profile_page/page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Helper function to check if the platform is a mobile device
bool get isMobileDevice {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    ClientPage(),
    ScannerPage(),
    BookPage(),
    ProfilePage(),
  ];

  static const List<String> _pageLabels = <String>[
    'Home',
    'Client',
    'Scan',
    'Book',
    'Me',
  ];

  static const List<IconData> _pageIcons = <IconData>[
    Icons.home,
    Icons.people,
    Icons.qr_code_scanner,
    Icons.book_online,
    Icons.person,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // For mobile devices, use bottom navigation
    if (isMobileDevice) {
      return Scaffold(
        body: _pages.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Client',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Me',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      );
    }
    
    // For desktop/web, use sidebar navigation
    return Scaffold(
      body: Row(
        children: [
          // Left sidebar navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            destinations: List.generate(
              _pageLabels.length,
              (index) => NavigationRailDestination(
                icon: Icon(_pageIcons[index]),
                label: Text(_pageLabels[index]),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Vertical divider
          const VerticalDivider(thickness: 1, width: 1),
          // Main content area
          Expanded(
            child: _pages.elementAt(_selectedIndex),
          ),
        ],
      ),
    );
  }
}

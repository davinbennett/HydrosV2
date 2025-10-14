import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/presentation/screens/home_screen.dart';
import 'package:frontend/presentation/screens/pair_device_screen.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final Map<int, Widget> _pageCache = {};

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: "Home",
      page: HomeScreen(),
    ),
    _NavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: "History",
      page: Center(child: Text("History Page")),
    ),
    _NavItem(
      icon: Icons.tap_and_play_outlined,
      activeIcon: Icons.tap_and_play,
      label: "Pair Device",
      page: PairDeviceScreen(),
    ),
    _NavItem(
      icon: Icons.settings_input_antenna_outlined,
      activeIcon: Icons.settings_input_antenna,
      label: "Service",
      page: Center(child: Text("Service Page")),
    ),
    _NavItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
      label: "Profile",
      page: Center(child: Text("Profile Page")),
    ),
  ];

  Widget _getPage(int index) {
    if (_pageCache.containsKey(index)) {
      return _pageCache[index]!;
    }
    final page = _navItems[index].page;
    _pageCache[index] = page;
    return page;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            mq.isPortrait ? AppColors.primary : AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            context.pushNamed('pair-device');
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
        items:
            _navItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon),
                    label: item.label,
                  ),
                )
                .toList(),
        backgroundColor: AppColors.primary,
        unselectedItemColor: const Color.fromARGB(103, 90, 90, 90),
        selectedItemColor: AppColors.gray,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}

/// router
final appRoutes = <GoRoute>[
  GoRoute(
    name: 'home',
    path: '/home',
    builder: (context, state) => const BottomNavBar(),
  ),
  GoRoute(
    name: 'profile',
    path: '/profile',
    builder: (context, state) => const BottomNavBar(),
  ),
  GoRoute(
    name: 'pair-device',
    path: '/pair-device',
    builder: (context, state) => const PairDeviceScreen(),
  ),
];

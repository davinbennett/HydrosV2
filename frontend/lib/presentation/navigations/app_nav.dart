import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/providers/device_provider.dart';
import 'package:frontend/presentation/screens/history_screen.dart';
import 'package:frontend/presentation/screens/home_screen.dart';
import 'package:frontend/presentation/screens/pair_device_screen.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:frontend/presentation/states/device_state.dart';
import 'package:go_router/go_router.dart';

import '../screens/alarm_screen.dart';
import '../screens/service_screen.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
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
      page: HistoryScreen(),
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
      page: ServiceScreen(),
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

    ref.listen<AsyncValue<AuthState>>(authProvider, (prev, next) {
      final state = next.value;
      if (state is AuthSessionExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (_) => AlertDialog(
                  title: Text("Session expired"),
                  content: Text(
                    "Your session has expired. Please login again.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        final deviceId = await SecureStorage.getDeviceId();
                        ref.read(authProvider.notifier).logout();
                        ref.read(deviceProvider.notifier).setUnpaired(deviceId!);
                        context.go('/login');
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
          );
        });
      }
    });

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
          final deviceState = ref.read(deviceProvider);

          if (index == 2 && !deviceState.hasPairedDevice) {
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
  GoRoute(
    name: 'alarm',
    path: '/alarm',
    builder: (context, state) => const AlarmScreen(),
  ),
];

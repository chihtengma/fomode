/// Main Navigation - Wraps all screens with bottom navigation
///
/// Features:
/// - Bottom navigation bar with floating center button
/// - Screen switching
/// - Maintains state across navigation
library;

import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'focus_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  NavItem _currentIndex = NavItem.home;
  bool _isFocusActive = false;

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case NavItem.home:
        return HomeScreen(
          onNavigate: (NavItem item) {
            _onNavItemTapped(item);
          },
        );
      case NavItem.goals:
        return CalendarScreen(
          onNavigate: (NavItem item) {
            _onNavItemTapped(item);
          },
        );
      case NavItem.focus:
        return FocusScreen(
          onFocusStateChanged: (isActive) {
            setState(() {
              _isFocusActive = isActive;
            });
          },
        );
      case NavItem.stats:
        return StatsScreen(
          onNavigate: (NavItem item) {
            _onNavItemTapped(item);
          },
        );
      case NavItem.profile:
        return const ProfileScreen();
    }
  }

  void _onNavItemTapped(NavItem item) {
    setState(() {
      _currentIndex = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Current screen with padding for bottom nav
          Positioned.fill(
            child: _getCurrentScreen(),
          ),

          // Bottom Navigation Bar - hide when focus is active
          if (!_isFocusActive)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onNavItemTapped,
              ),
            ),
        ],
      ),
    );
  }
}

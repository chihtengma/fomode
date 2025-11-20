/// Bottom Navigation Bar Widget with Floating Center Button
///
/// Features:
/// - 4 navigation items: Home, Goals, Stats, Profile
/// - Floating center "Focus" button
/// - Active state with blue color
/// - Light and Dark mode support
/// - Smooth animations
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum NavItem { home, goals, focus, stats, profile }

class BottomNavBar extends StatelessWidget {
  final NavItem currentIndex;
  final Function(NavItem) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Get safe area bottom padding for devices with home indicator
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 65 + bottomPadding,
      child: Stack(
        children: [
          // Bottom bar background
          Positioned(
            left: 0,
            right: 0,
            top: 11,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          ),

          // Navigation items
          Positioned(
            left: 0,
            right: 0,
            top: 16,
            height: 60, // Fixed height for nav items
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left group
                  Row(
                    children: [
                      _buildNavItem(
                        context: context,
                        item: NavItem.home,
                        label: 'Home',
                      ),
                      const SizedBox(width: 18),
                      _buildNavItem(
                        context: context,
                        item: NavItem.goals,
                        label: 'Calendar',
                      ),
                    ],
                  ),

                  // Spacer for center button
                  const SizedBox(width: 54),

                  // Right group
                  Row(
                    children: [
                      _buildNavItem(
                        context: context,
                        item: NavItem.stats,
                        label: 'Stats',
                      ),
                      const SizedBox(width: 18),
                      _buildNavItem(
                        context: context,
                        item: NavItem.profile,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating center button
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(NavItem.focus),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF613EEA),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF613EEA).withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedTarget02,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required NavItem item,
    required String label,
  }) {
    final isActive = currentIndex == item;
    final activeColor = const Color(0xFF386BF6);
    final inactiveColor = const Color(0xFF9DB2CE);

    // Get the appropriate HugeIcon
    IconData iconData;
    switch (item) {
      case NavItem.home:
        iconData = HugeIcons.strokeRoundedHome04;
        break;
      case NavItem.goals:
        iconData = HugeIcons.strokeRoundedCalendar03;
        break;
      case NavItem.stats:
        iconData = HugeIcons.strokeRoundedAnalytics01;
        break;
      case NavItem.profile:
        iconData = HugeIcons.strokeRoundedUserSquare;
        break;
      case NavItem.focus:
        iconData = HugeIcons.strokeRoundedTarget02;
        break;
    }

    return GestureDetector(
      onTap: () => onTap(item),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 24,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

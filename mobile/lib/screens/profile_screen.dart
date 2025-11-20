/// Profile Screen - User profile and settings
///
/// Features:
/// - Display user information
/// - Stats cards (Daily Goals, Progress)
/// - App settings
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _userEmail = '';
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      
      if (userData != null) {
        setState(() {
          _userEmail = userData['email'] ?? 'user@fomode.com';
          _userName = userData['full_name'] ?? _userEmail.split('@')[0];
          _isLoading = false;
        });
      } else {
        // Fallback to stored email if API fails
        final email = await _authService.getUserEmail();
        setState(() {
          _userEmail = email ?? 'user@fomode.com';
          _userName = _userEmail.split('@')[0];
          // Capitalize first letter
          if (_userName.isNotEmpty) {
            _userName = _userName[0].toUpperCase() + _userName.substring(1);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback on error
      final email = await _authService.getUserEmail();
      setState(() {
        _userEmail = email ?? 'user@fomode.com';
        _userName = _userEmail.split('@')[0];
        if (_userName.isNotEmpty) {
          _userName = _userName[0].toUpperCase() + _userName.substring(1);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF3B30),
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF141414),
                ),
              ),
              const SizedBox(height: 8),
              // Message
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: isDark 
                            ? const Color(0xFF3A3A3C) 
                            : const Color(0xFFF2F2F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF141414),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Logout button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFFF3B30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout == true && mounted) {
      await _authService.signOut();
      // Navigate back to login
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_seen_onboarding');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding reset! Restart app to see it again.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Profile Card with gradient background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF613EEA),
                        Color(0xFF7C5FEE),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF613EEA).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture on the left
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Name and Email on the right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    // Daily Goals Card
                    Expanded(
                      child: _buildStatCard(
                        isDark: isDark,
                        icon: Icons.list_alt_rounded,
                        title: 'Daily Goals',
                        value: '8',
                        subtitle: 'Goals',
                        backgroundColor: const Color(0xFF613EEA),
                        accentColor: const Color(0xFFFED132),
                        isRotated: false,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Progress Card
                    Expanded(
                      child: _buildStatCard(
                        isDark: isDark,
                        icon: Icons.pie_chart_rounded,
                        title: 'Progress',
                        value: '3/8',
                        subtitle: 'Goals',
                        backgroundColor: const Color(0xFF2D4FC6),
                        accentColor: const Color(0xFFFF6641),
                        isRotated: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Settings Section
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                      width: 1.5,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedUserSquare,
                        title: 'Account',
                        textColor: textColor,
                        iconColor: const Color(0xFF613EEA),
                      ),
                      _buildSettingsDivider(isDark),
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedNotification02,
                        title: 'Notifications',
                        textColor: textColor,
                        iconColor: const Color(0xFFFF9800),
                      ),
                      _buildSettingsDivider(isDark),
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedSettings02,
                        title: 'General',
                        textColor: textColor,
                        iconColor: const Color(0xFF2196F3),
                      ),
                      _buildSettingsDivider(isDark),
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedMoon02,
                        title: 'Theme',
                        textColor: textColor,
                        iconColor: const Color(0xFF9C27B0),
                      ),
                      _buildSettingsDivider(isDark),
                      // TEMP: Reset Onboarding
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedRefresh,
                        title: 'Reset Onboarding (TEMP)',
                        textColor: const Color(0xFFFF9800),
                        iconColor: const Color(0xFFFF9800),
                        onTap: _resetOnboarding,
                      ),
                      _buildSettingsDivider(isDark),
                      // Logout button
                      _buildSettingsItem(
                        icon: HugeIcons.strokeRoundedLogout01,
                        title: 'Logout',
                        textColor: const Color(0xFFFF3B30),
                        iconColor: const Color(0xFFFF3B30),
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color backgroundColor,
    required Color accentColor,
    required bool isRotated,
  }) {
    final textColor = Colors.white; // White text on colored background
    final iconColor = Colors.white.withOpacity(0.8);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative accent element (bottom corner)
            Positioned(
              right: isRotated ? null : 0,
              left: isRotated ? 0 : null,
              bottom: -31,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: isRotated
                      ? const BorderRadius.only(
                          topRight: Radius.circular(98.4),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(98.4),
                        ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: iconColor,
                    ),
                  ),

                  // Value and label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.9),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.9),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Color textColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {
        // Handle navigation to settings pages
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Icon
            Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            // Chevron
            Icon(
              HugeIcons.strokeRoundedArrowRight01,
              size: 24,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
    );
  }
}


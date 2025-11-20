/// Focus Screen - Timer and focus session management
///
/// Features:
/// - Setup view for starting new focus sessions
/// - Active timer view for ongoing sessions
/// - Pause/Resume/End controls
/// - Recent sessions display
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/notification_service.dart';

class FocusScreen extends StatefulWidget {
  final Function(bool)? onFocusStateChanged;

  const FocusScreen({super.key, this.onFocusStateChanged});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with WidgetsBindingObserver {
  // State variables
  bool _isFocusActive = false;
  bool _isPaused = false;
  bool _isOnBreak = false;
  String? _selectedGoal;
  int _selectedDuration = 25; // in minutes
  int _selectedPauseDuration = 5; // in minutes
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  int _breakRemainingSeconds = 0;
  int _breakTotalSeconds = 0;
  Timer? _timer;
  bool _isBlockedAppsExpanded = false;
  final ExpansionTileController _expansionController = ExpansionTileController();
  final ExpansionTileController _pauseExpansionController = ExpansionTileController();

  // App lifecycle tracking
  bool _showInterceptionOverlay = false;
  int _focusBreakCount = 0;
  DateTime? _lastPausedTime;

  // Notification service
  final NotificationService _notificationService = NotificationService();

  // Mock data - Available goals
  final List<String> _availableGoals = [
    'Market Research & Analysis',
    'Complete project proposal',
    'Team meeting preparation',
    'Code review for feature branch',
    'Update documentation',
  ];

  // Mock data - Blocked apps
  final List<Map<String, dynamic>> _blockedApps = [
    {
      'name': 'TikTok',
      'icon': HugeIcons.strokeRoundedTiktok,
      'iconUrl': 'https://logo.clearbit.com/tiktok.com',
      'color': const Color(0xFF000000),
      'isActive': true,
    },
    {
      'name': 'Instagram',
      'icon': HugeIcons.strokeRoundedInstagram,
      'iconUrl': 'https://logo.clearbit.com/instagram.com',
      'color': const Color(0xFFE4405F),
      'isActive': true,
    },
    {
      'name': 'YouTube',
      'icon': HugeIcons.strokeRoundedYoutube,
      'iconUrl': 'https://logo.clearbit.com/youtube.com',
      'color': const Color(0xFFFF0000),
      'isActive': true,
    },
    {
      'name': 'Twitter',
      'icon': HugeIcons.strokeRoundedNewTwitter,
      'iconUrl': 'https://logo.clearbit.com/x.com',
      'color': const Color(0xFF000000),
      'isActive': true,
    },
    {
      'name': 'Reddit',
      'icon': HugeIcons.strokeRoundedReddit,
      'iconUrl': 'https://logo.clearbit.com/reddit.com',
      'color': const Color(0xFFFF4500),
      'isActive': true,
    },
    {
      'name': 'Facebook',
      'icon': HugeIcons.strokeRoundedFacebook02,
      'iconUrl': 'https://logo.clearbit.com/facebook.com',
      'color': const Color(0xFF0866FF),
      'isActive': true,
    },
    {
      'name': 'Snapchat',
      'icon': HugeIcons.strokeRoundedSnapchat,
      'iconUrl': 'https://logo.clearbit.com/snapchat.com',
      'color': const Color(0xFFFFFC00),
      'isActive': false,
    },
    {
      'name': 'WhatsApp',
      'icon': HugeIcons.strokeRoundedWhatsapp,
      'iconUrl': 'https://logo.clearbit.com/whatsapp.com',
      'color': const Color(0xFF25D366),
      'isActive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only intercept if focus is active and not on break
    if (_isFocusActive && !_isOnBreak) {
      switch (state) {
        case AppLifecycleState.paused:
          // User left the app or switched to another app
          _lastPausedTime = DateTime.now();

          // Send motivational notification when they leave
          _notificationService.sendBlockedAppReminder(
            appName: 'another app',
            goalName: _selectedGoal ?? 'your goal',
            timeRemaining: _formatTime(_remainingSeconds),
          );
          break;
        case AppLifecycleState.resumed:
          // User came back to the app
          if (_lastPausedTime != null) {
            final timeAway = DateTime.now().difference(_lastPausedTime!).inSeconds;
            // If they were away for more than 3 seconds, show interception
            if (timeAway > 3) {
              setState(() {
                _showInterceptionOverlay = true;
                _focusBreakCount++;
              });
            }
          }
          break;
        default:
          break;
      }
    }
  }

  void _startTimer() {
    setState(() {
      _isFocusActive = true;
      _isPaused = false;
      _totalSeconds = _selectedDuration * 60;
      _remainingSeconds = _totalSeconds;
    });

    widget.onFocusStateChanged?.call(true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _endSession();
      }
    });
  }

  void _pauseSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF141414);

        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Take a Break?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          content: Text(
            'Do you want to take a $_selectedPauseDuration minute break? The timer will pause.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: textColor.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.15),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Take Break',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _timer?.cancel();
      setState(() {
        _isPaused = true;
        _isOnBreak = true;
        _breakTotalSeconds = _selectedPauseDuration * 60;
        _breakRemainingSeconds = _breakTotalSeconds;
      });

      // Start break countdown
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_breakRemainingSeconds > 0) {
          setState(() {
            _breakRemainingSeconds--;
          });
        } else {
          // Break is over, resume focus session
          _resumeFromBreak();
        }
      });
    }
  }

  void _resumeFromBreak() {
    _timer?.cancel();
    setState(() {
      _isPaused = false;
      _isOnBreak = false;
      _breakRemainingSeconds = 0;
    });

    // Resume focus timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _endSession();
      }
    });
  }

  void _resumeSession() {
    _resumeFromBreak();
  }

  void _endSession() {
    _timer?.cancel();
    setState(() {
      _isFocusActive = false;
      _isPaused = false;
      _remainingSeconds = 0;
      _focusBreakCount = 0; // Reset break count for next session
    });
    widget.onFocusStateChanged?.call(false);

    // Clear all notifications when session ends
    _notificationService.cancelAll();

    // TODO: Save session to backend
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            _isFocusActive
                ? (_isOnBreak ? _buildBreakView(isDark) : _buildActiveSessionView(isDark))
                : _buildSetupView(isDark),

            // Interception overlay (shown when user returns after leaving during focus)
            if (_showInterceptionOverlay)
              _buildInterceptionOverlay(isDark),
          ],
        ),
      ),
    );
  }

  // Setup view - shown when no session is active
  Widget _buildSetupView(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header Card with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedTarget02,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Focus Session',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    'Set up your focus session to stay productive',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Goal Section Label
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'SELECT GOAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: subtextColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Goal Selector Dropdown
            Container(
              decoration: BoxDecoration(
                color: cardColor,
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
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  controller: _expansionController,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF613EEA),
                          Color(0xFF7C5FEE),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF613EEA).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _selectedGoal ?? 'Choose a goal to focus on',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _selectedGoal != null ? textColor : subtextColor,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    color: subtextColor,
                  ),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: _availableGoals.map((goal) {
                          final isSelected = _selectedGoal == goal;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedGoal = goal;
                              });
                              _expansionController.collapse();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF613EEA).withOpacity(0.1)
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF3A3A3C)
                                        : const Color(0xFFE5E5EA),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 56), // Align with title
                                  Expanded(
                                    child: Text(
                                      goal,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected
                                            ? const Color(0xFF613EEA)
                                            : textColor,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF613EEA),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Duration Section Label
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'FOCUS DURATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: subtextColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Duration Selection
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Duration Input Field
                Container(
                  width: 100,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '$_selectedDuration',
                            hintStyle: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            final intValue = int.tryParse(value);
                            if (intValue != null && intValue >= 5 && intValue <= 120) {
                              setState(() {
                                _selectedDuration = intValue;
                              });
                            }
                          },
                          onSubmitted: (value) {
                            final intValue = int.tryParse(value);
                            if (intValue != null) {
                              setState(() {
                                if (intValue < 5) {
                                  _selectedDuration = 5;
                                } else if (intValue > 120) {
                                  _selectedDuration = 120;
                                } else {
                                  _selectedDuration = intValue;
                                }
                              });
                            }
                          },
                        ),
                      ),
                      Text(
                        'min',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Slider with Balloon Popup
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: const Color(0xFF613EEA),
                  inactiveTrackColor: isDark
                      ? const Color(0xFF3A3A3C)
                      : const Color(0xFFE5E5EA),
                  thumbColor: const Color(0xFF613EEA),
                  overlayColor: Colors.transparent,
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14,
                    elevation: 2,
                  ),
                  valueIndicatorShape: const _BalloonSliderValueIndicatorShape(),
                  valueIndicatorColor: const Color(0xFF613EEA),
                  valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: Slider(
                  value: _selectedDuration.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 115,
                  label: '$_selectedDuration',
                  onChanged: (value) {
                    setState(() {
                      _selectedDuration = value.toInt();
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Pause Duration Section Label
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'BREAK SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: subtextColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Pause Duration Selection
            Container(
              decoration: BoxDecoration(
                color: cardColor,
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
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  controller: _pauseExpansionController,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF9800),
                          Color(0xFFFFB74D),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pause_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pause Duration',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '$_selectedPauseDuration min break time',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    color: subtextColor,
                  ),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [5, 10, 15].map((minutes) {
                          final isSelected = _selectedPauseDuration == minutes;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPauseDuration = minutes;
                              });
                              _pauseExpansionController.collapse();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFF9800).withOpacity(0.1)
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF3A3A3C)
                                        : const Color(0xFFE5E5EA),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 56), // Align with title
                                  Expanded(
                                    child: Text(
                                      '$minutes minutes',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected
                                            ? const Color(0xFFFF9800)
                                            : textColor,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFFF9800),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Blocked Apps Section Label
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'BLOCKED APPS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: subtextColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Blocked Apps Section - Collapsible
            GestureDetector(
              onTap: () {
                setState(() {
                  _isBlockedAppsExpanded = !_isBlockedAppsExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
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
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF5252),
                                Color(0xFFFF6B6B),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5252).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            HugeIcons.strokeRoundedCancelCircle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Blocked Apps',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_blockedApps.where((app) => app['isActive'] == true).length} apps will be blocked',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isBlockedAppsExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: subtextColor,
                          size: 24,
                        ),
                      ],
                    ),

                    // Expandable Grid
                    if (_isBlockedAppsExpanded) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: _blockedApps.length,
                          itemBuilder: (context, index) {
                            return _buildBlockedAppIcon(
                              app: _blockedApps[index],
                              isDark: isDark,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to manage blocked apps
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Manage Apps',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF613EEA),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Color(0xFF613EEA),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Start Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: _selectedGoal != null
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF613EEA),
                          Color(0xFF7C5FEE),
                          Color(0xFF8A6FF0),
                        ],
                      )
                    : null,
                color: _selectedGoal == null
                    ? (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA))
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _selectedGoal != null
                    ? [
                        BoxShadow(
                          color: const Color(0xFF613EEA).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: _selectedGoal != null ? _startTimer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _selectedGoal != null
                        ? Colors.white
                        : (isDark ? const Color(0xFF5E5E60) : const Color(0xFFAAAAAA)),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // Active session view - shown during focus session
  Widget _buildActiveSessionView(bool isDark) {
    final elapsedSeconds = _totalSeconds - _remainingSeconds;
    final progress = _totalSeconds > 0 ? elapsedSeconds / _totalSeconds : 0.0;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999);
    final circleBackgroundColor = isDark
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFF613EEA).withOpacity(0.1);
    final progressColor = const Color(0xFF613EEA);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // "Let's focus for" text
            Text(
              "Let's focus for",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: textColor.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 80),

            // Large circular timer
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 20,
                      valueColor: AlwaysStoppedAnimation<Color>(circleBackgroundColor),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 20,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      backgroundColor: Colors.transparent,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Timer text in center
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w300,
                      color: textColor,
                      letterSpacing: -2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Pause button
            Container(
              width: 200,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: progressColor,
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isPaused ? _resumeSession : _pauseSession,
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    child: Text(
                      _isPaused ? 'RESUME' : 'PAUSE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: progressColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Break view - shown during break time
  Widget _buildBreakView(bool isDark) {
    final elapsedSeconds = _breakTotalSeconds - _breakRemainingSeconds;
    final progress = _breakTotalSeconds > 0 ? elapsedSeconds / _breakTotalSeconds : 0.0;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final circleBackgroundColor = isDark
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFFFF6B6B).withOpacity(0.1);
    final progressColor = const Color(0xFFFF6B6B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // "Break Time" text
            Text(
              "Take a Break",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: textColor.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            // Break duration subtitle
            Text(
              "${_selectedPauseDuration} minute break",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: progressColor,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 64),

            // Large circular timer
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 20,
                      valueColor: AlwaysStoppedAnimation<Color>(circleBackgroundColor),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 20,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      backgroundColor: Colors.transparent,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Timer text in center
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_breakRemainingSeconds),
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w300,
                          color: textColor,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "remaining",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor.withOpacity(0.6),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 64),

            // Info text
            Text(
              "You'll resume focus when break ends",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.5),
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Interception overlay - shown when user returns after leaving during focus
  Widget _buildInterceptionOverlay(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);

    return Container(
      color: backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Warning Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 60,
                ),
              ),

              const SizedBox(height: 40),

              // Main message
              Text(
                "Wait!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "You left your focus session",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.8),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Stats
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.exit_to_app_rounded,
                      color: const Color(0xFFFF6B6B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Focus breaks: $_focusBreakCount",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Motivational message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF613EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF613EEA).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "You're working on:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedGoal ?? "Your goal",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF613EEA),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Stay focused! ${_formatTime(_remainingSeconds)} remaining",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Action buttons
              Column(
                children: [
                  // Return to Focus button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF613EEA),
                          Color(0xFF7C5FEE),
                          Color(0xFF8A6FF0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF613EEA).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showInterceptionOverlay = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Return to Focus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // End Session button
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              'End Focus Session?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            content: Text(
                              'You still have ${_formatTime(_remainingSeconds)} remaining. Are you sure you want to end this session?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Keep Focusing',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF613EEA),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.15),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'End Session',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF6B6B),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true) {
                        setState(() {
                          _showInterceptionOverlay = false;
                        });
                        _endSession();
                      }
                    },
                    child: Text(
                      'End Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF6B6B),
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
  }

  Widget _buildBlockedAppIcon({
    required Map<String, dynamic> app,
    required bool isDark,
  }) {
    final bool isActive = app['isActive'] as bool;
    final Color appColor = app['color'] as Color;
    final String? iconUrl = app['iconUrl'] as String?;
    final IconData appIcon = app['icon'] as IconData;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? appColor.withOpacity(0.2)
                  : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: appColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: iconUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          iconUrl,
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          color: isActive ? null : (isDark ? const Color(0xFF5E5E60) : const Color(0xFFAAAAAA)),
                          colorBlendMode: isActive ? null : BlendMode.saturation,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            appIcon,
                            color: isActive
                                ? appColor
                                : (isDark ? const Color(0xFF5E5E60) : const Color(0xFFAAAAAA)),
                            size: 28,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 32,
                              height: 32,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(appColor),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(
                        appIcon,
                        color: isActive
                            ? appColor
                            : (isDark ? const Color(0xFF5E5E60) : const Color(0xFFAAAAAA)),
                        size: 28,
                      ),
              ),
              if (isActive)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            app['name'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? (isDark ? Colors.white : const Color(0xFF141414))
                  : (isDark ? const Color(0xFF5E5E60) : const Color(0xFFAAAAAA)),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Custom Balloon-shaped value indicator for slider
class _BalloonSliderValueIndicatorShape extends SliderComponentShape {
  const _BalloonSliderValueIndicatorShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(60, 70);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final double scale = activationAnimation.value;

    if (scale == 0.0) return;

    // Balloon parameters
    final double balloonRadius = 28.0 * scale;
    final double tailHeight = 12.0 * scale;
    final Offset balloonCenter = Offset(center.dx, center.dy - balloonRadius - tailHeight - 14);

    // Draw balloon body (circle)
    final Paint balloonPaint = Paint()
      ..color = sliderTheme.valueIndicatorColor ?? const Color(0xFF613EEA)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(balloonCenter, balloonRadius, balloonPaint);

    // Draw balloon tail (triangle/teardrop shape)
    final Path tailPath = Path();
    final double tailWidth = 10.0 * scale;

    tailPath.moveTo(balloonCenter.dx - tailWidth / 2, balloonCenter.dy + balloonRadius - 5);
    tailPath.quadraticBezierTo(
      balloonCenter.dx,
      balloonCenter.dy + balloonRadius + tailHeight,
      balloonCenter.dx + tailWidth / 2,
      balloonCenter.dy + balloonRadius - 5,
    );
    tailPath.close();

    canvas.drawPath(tailPath, balloonPaint);

    // Draw text
    final TextSpan textSpan = TextSpan(
      text: labelPainter.text?.toPlainText() ?? '',
      style: sliderTheme.valueIndicatorTextStyle,
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );

    textPainter.layout();

    final Offset textCenter = Offset(
      balloonCenter.dx - (textPainter.width / 2),
      balloonCenter.dy - (textPainter.height / 2),
    );

    textPainter.paint(canvas, textCenter);
  }
}

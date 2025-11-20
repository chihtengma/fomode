/// Notification Service - Handles all local push notifications
///
/// Features:
/// - Initialize notification system
/// - Request permissions
/// - Send focus reminders
/// - Send motivational messages
library;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions (especially for iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    // For iOS
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // For Android 13+
    final bool? androidResult = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return result ?? androidResult ?? true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Handle notification tap - navigate to focus screen
    print('Notification tapped: ${response.payload}');
  }

  /// Send a focus reminder notification
  Future<void> sendFocusReminder({
    required String goalName,
    required String timeRemaining,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final messages = [
      "Stay focused on: $goalName",
      "You're doing great! Keep working on: $goalName",
      "Almost there! $timeRemaining left on: $goalName",
      "Remember your goal: $goalName",
      "You've got this! Focus on: $goalName",
    ];

    final message = messages[Random().nextInt(messages.length)];

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'focus_reminders',
      'Focus Reminders',
      channelDescription: 'Notifications to help you stay focused on your goals',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF613EEA),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0, // Notification ID
      'Focus Mode Active 🎯',
      message,
      details,
      payload: 'focus_reminder',
    );
  }

  /// Send motivational message when user opens blocked app
  Future<void> sendBlockedAppReminder({
    required String appName,
    required String goalName,
    required String timeRemaining,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final messages = [
      "Hey! You're focusing on: $goalName. Come back! ✨",
      "Remember your goal: $goalName. You've got $timeRemaining left! 💪",
      "Almost done! $timeRemaining remaining on: $goalName 🎯",
      "Stay strong! You're working on: $goalName 🌟",
      "You can do this! Get back to: $goalName 🚀",
      "Don't give up! $timeRemaining left on: $goalName ⏰",
    ];

    final message = messages[Random().nextInt(messages.length)];

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'blocked_app_reminders',
      'App Block Reminders',
      channelDescription: 'Friendly reminders when you try to open blocked apps',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF6B6B),
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1, // Different ID for blocked app notifications
      'Focus Mode Active 🎯',
      message,
      details,
      payload: 'blocked_app',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}

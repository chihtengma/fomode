/// App Constants
///
/// This file contains all configuration values used throughout the app.
library;

class AppConstants {
  // Private constructor - prevents creating instances of this class
  // This is a utility class that only holds static values
  AppConstants._();

  // ============================================
  // API Configuration
  // ============================================

  /// Base URL for the backend API
  ///
  /// For iOS Simulator: use 'localhost' or '127.0.0.1'
  /// For Android Emulator: use '10.0.2.2' (maps to host machine's localhost)
  /// For Real Device: use your computer's IP (e.g., '192.168.1.100')
  static const String baseUrl = 'http://localhost:8000';

  /// API Endpoints (paths)
  static const String goalsEndpoint = '/goals';
  static const String trackingEndpoint = '/tracking';
  static const String focusEndpoint = '/focus';

  // ============================================
  // App Settings
  // ============================================

  /// Default user ID (hardcoded for MVP)
  /// Will be replaced with real authentication later
  static const int defaultUserId = 1;

  /// How long to wait for API responses before timing out
  static const Duration requestTimeout = Duration(seconds: 30);

  /// How many items to fetch per page (pagination)
  static const int paginationLimit = 50;

  // ============================================
  // UI Constants
  // ============================================

  /// Spacing values (padding and margins)
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  /// Border radius for rounded corners
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
}

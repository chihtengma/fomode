import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/goal_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  runApp(const FomodeApp());
}

/// Main App Widget
///
/// Sets up:
/// - Provider for state management
/// - App theme
/// - Home screen as entry point
class FomodeApp extends StatelessWidget {
  const FomodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Goal Provider - manages goal state
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        // TODO: Add more providers as needed
        // - UsageProvider (for app usage tracking)
        // - FocusProvider (for focus sessions)
      ],
      child: MaterialApp(
        title: 'Fomode',
        debugShowCheckedModeBanner: false,

        // App theme - Material Design 3 with warm, rounded aesthetic
        theme: ThemeData(
          // Use a calm blue for focus/productivity
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3), // Blue
            brightness: Brightness.light,
            surface: const Color(0xFFF7F3EA), // Warm cream background
            onSurface: const Color(0xFF1A1A1A), // Dark text
          ),
          useMaterial3: true,

          // Scaffold background
          scaffoldBackgroundColor: const Color(0xFFF7F3EA),

          // Card theme - more rounded, subtle elevation
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white.withOpacity(0.8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            shadowColor: Colors.black.withOpacity(0.05),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
          ),

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F3EA),
            elevation: 0,
            centerTitle: true,
            foregroundColor: Color(0xFF1A1A1A),
          ),

          // Floating Action Button theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
        ),

        // Dark theme (optional - for users who prefer dark mode)
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF613EEA),
            brightness: Brightness.dark,
            surface: const Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
          useMaterial3: true,

          // Scaffold background
          scaffoldBackgroundColor: const Color(0xFF121212),

          // Card theme
          cardTheme: CardThemeData(
            elevation: 0,
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            shadowColor: Colors.black.withOpacity(0.3),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
          ),

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
            centerTitle: true,
            foregroundColor: Colors.white,
          ),

          // Floating Action Button theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
        ),

        // Use system theme mode (light/dark)
        themeMode: ThemeMode.system,

        // Authentication wrapper - checks if user is logged in
        home: const AuthWrapper(),
        
        // Named routes
        routes: {
          '/home': (context) => const MainNavigation(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

/// Auth Wrapper - Checks authentication status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        // Show loading while checking auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show login or home based on auth status
        if (snapshot.data == true) {
          return const MainNavigation();
        } else {
          // Check if first time user
          return FutureBuilder<bool>(
            future: _isFirstTime(),
            builder: (context, firstTimeSnapshot) {
              if (firstTimeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (firstTimeSnapshot.data == true) {
                return const OnboardingScreen();
              } else {
                return const LoginScreen();
              }
            },
          );
        }
      },
    );
  }

  Future<bool> _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    if (!hasSeenOnboarding) {
      await prefs.setBool('has_seen_onboarding', true);
      return true;
    }
    return false;
  }
}

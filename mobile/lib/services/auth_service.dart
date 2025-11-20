import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  // Secure storage for JWT token
  final _storage = const FlutterSecureStorage();
  
  // Google Sign-In configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '31506097260-8j5b13icgmj5fok1b89qi1ghog4r45i2.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // Backend API URL - Update this to your backend URL
  final String _baseUrl = 'http://localhost:8000';

  // Storage keys
  static const String _tokenKey = 'jwt_token';
  static const String _emailKey = 'user_email';

  /// Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      // Send credentials to backend as form data (OAuth2 format)
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String accessToken = data['access_token'];
        
        // Save token and email
        await _storage.write(key: _tokenKey, value: accessToken);
        await _storage.write(key: _emailKey, value: email);

        return {
          'success': true,
          'email': email,
        };
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Sign up with email, password, and full name
  Future<Map<String, dynamic>> signUpWithFullName(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // Send signup request to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );

      if (response.statusCode == 200) {
        // Signup successful, now login to get token
        return await signInWithEmailPassword(email, password);
      } else {
        // Try to parse error message
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['detail'] ?? 'Sign up failed');
        } catch (_) {
          throw Exception('Sign up failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Sign up with email and password (legacy - uses email prefix as name)
  Future<Map<String, dynamic>> signUp(
    String email,
    String password,
  ) async {
    return signUpWithFullName(email, password, email.split('@')[0]);
  }

  /// Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // Send ID token to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String accessToken = data['access_token'];
        
        // Save token and email
        await _storage.write(key: _tokenKey, value: accessToken);
        await _storage.write(key: _emailKey, value: googleUser.email);

        return {
          'success': true,
          'email': googleUser.email,
          'name': googleUser.displayName,
        };
      } else {
        throw Exception('Backend authentication failed: ${response.body}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Sign in with Apple (iOS only)
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      if (!Platform.isIOS) {
        throw Exception('Apple Sign-In is only available on iOS');
      }

      // Request Apple Sign-In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? idToken = credential.identityToken;
      final String? authCode = credential.authorizationCode;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Apple');
      }

      // Send ID token to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/apple'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'code': authCode ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String accessToken = data['access_token'];
        
        // Save token and email (if available)
        await _storage.write(key: _tokenKey, value: accessToken);
        if (credential.email != null) {
          await _storage.write(key: _emailKey, value: credential.email!);
        }

        return {
          'success': true,
          'email': credential.email,
          'name': credential.givenName,
        };
      } else {
        throw Exception('Backend authentication failed: ${response.body}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Sign out
  Future<void> signOut() async {
    // Sign out from Google
    await _googleSignIn.signOut();
    
    // Clear stored tokens
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _emailKey);
  }

  /// Get current user data from backend
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

import 'package:kiliride/services/refresh_token.service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
  
/// Helper class to initialize the refresh token service in your app
class TokenServiceInitializer {
  /// Call this method in your app's main initialization process
  ///
  /// This method now handles 401 errors during startup by automatically
  /// logging out the user and clearing all tokens.
  ///
  /// Example usage in main.dart or wrapper.dart:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   _initializeTokenService();
  /// }
  ///
  /// Future<void> _initializeTokenService() async {
  ///   final result = await TokenServiceInitializer.initialize();
  ///   if (result.needsLogin) {
  ///     // Redirect to login
  ///   } else {
  ///     // User is authenticated, proceed with app
  ///   }
  /// }
  /// ```
  static Future<TokenInitResult> initialize() async {
    try {
      // Check if user is already authenticated with Firebase
      //REPLACE WITH BACKEND AUTH LOGIC
      // final currentUser = FirebaseAuth.instance.currentUser;

      // if (currentUser == null) {
      //   // No Firebase user, definitely need to login
      //   return TokenInitResult(
      //     success: false,
      //     needsLogin: true,
      //     message: 'No Firebase user found',
      //   );
      // }

      // Initialize the refresh token service
      final hasValidTokens = await RefreshTokenService.instance.init();

      return TokenInitResult(
        success: hasValidTokens,
        needsLogin: !hasValidTokens,
        message: hasValidTokens
            ? 'Token service initialized successfully'
            : 'No valid tokens found, login required',
      );
    } catch (e) {
      print('Error initializing token service: $e');
      return TokenInitResult(
        success: false,
        needsLogin: true,
        message: 'Token initialization failed: $e',
      );
    }
  }

  /// Call this after successful authentication to start token management
  static Future<bool> startTokenManagement() async {
    try {
      return await RefreshTokenService.instance.init();
    } catch (e) {
      print('Error starting token management: $e');
      return false;
    }
  }

  /// Call this during logout to cleanup token service
  static Future<void> cleanup() async {
    try {
      await RefreshTokenService.instance.clearTokens();
    } catch (e) {
      print('Error during token service cleanup: $e');
    }
  }

  /// Force a token refresh - useful for testing or manual refresh
  static Future<bool> forceRefresh() async {
    try {
      return await RefreshTokenService.instance.forceRefresh();
    } catch (e) {
      print('Error forcing token refresh: $e');
      return false;
    }
  }

  /// Check if the user has valid tokens without initializing the service
  static Future<bool> hasValidTokens() async {
    try {
      return await RefreshTokenService.instance.hasValidTokens();
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }
}

/// Result of token service initialization
class TokenInitResult {
  final bool success;
  final bool needsLogin;
  final String message;

  const TokenInitResult({
    required this.success,
    required this.needsLogin,
    required this.message,
  });

  @override
  String toString() {
    return 'TokenInitResult(success: $success, needsLogin: $needsLogin, message: $message)';
  }
}

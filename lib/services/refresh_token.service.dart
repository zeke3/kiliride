import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kiliride/shared/constants.dart';

/// Service responsible for managing token refresh operations
/// Handles automatic token refresh, expiry checking, and background token updates
class RefreshTokenService {
  // --- Singleton Setup ---
  static final RefreshTokenService instance = RefreshTokenService._internal();
  factory RefreshTokenService() => instance;
  RefreshTokenService._internal();

  // --- Core Dependencies ---
  // final FlutterAppAuth appAuth = const FlutterAppAuth();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  // --- Private Variables ---
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // --- Callback for authentication failure ---
  Function? onAuthenticationFailure;

  /// Initializes the token service and checks token validity
  /// Returns true if tokens are valid or can be refreshed, false if login is required
  /// If 401 error occurs during startup, automatically logs out the user
  Future<bool> init() async {
    // Quick check if we have valid tokens without network call
    final tokenExpiryTime = await _getStoredExpiryTime();
    final currentAccessToken = await secureStorage.read(key: ACCESS_TOKEN_KEY);

    // If we have tokens and they're still valid for more than 5 minutes, start quickly
    if (tokenExpiryTime != null &&
        currentAccessToken != null &&
        tokenExpiryTime.isAfter(
          DateTime.now().add(const Duration(minutes: 5)),
        )) {
      print('Token valid for 5+ minutes, starting app quickly');
      startTokenRefreshTimer();
      return true;
    }

    // If tokens are expiring soon or missing, try to refresh
    if (tokenExpiryTime != null && currentAccessToken != null) {
      print('Token expiring soon, attempting refresh during startup');

      // Try to refresh the token during startup
      final refreshResult = await checkAndRefreshTokenIfNeeded();
      if (refreshResult) {
        startTokenRefreshTimer();
        return true;
      } else {
        // Refresh failed, likely due to 401 - logout user
        print('Token refresh failed during startup, logging out user');
        await _handleAuthenticationFailure();
        return false;
      }
    }

    // No tokens at all, user needs to login
    print('No tokens found, user needs to login');
    return false;
  }

  /// Handles authentication failure by clearing tokens and signing out
  Future<void> _handleAuthenticationFailure() async {
    try {
      print('🚨 Handling authentication failure - clearing all tokens');

      // Clear all tokens from secure storage
      await secureStorage.delete(key: ACCESS_TOKEN_KEY);
      await secureStorage.delete(key: REFRESH_TOKEN_KEY);
      await secureStorage.delete(key: EXPIRY_TIME_KEY);

      // Stop the refresh timer
      stopTokenRefreshTimer();

      // Clear all secure storage (this will force re-authentication)
      await secureStorage.deleteAll();

      print('🔓 All tokens cleared - user will need to re-authenticate');

      // Notify the app about authentication failure (if callback is set)
      if (onAuthenticationFailure != null) {
        print('📢 Calling authentication failure callback');
        onAuthenticationFailure!();
      }
    } catch (e) {
      print('❌ Error during authentication failure handling: $e');
      // Even if cleanup fails, clear tokens
      await clearTokens();

      // Still try to notify the app
      if (onAuthenticationFailure != null) {
        onAuthenticationFailure!();
      }
    }
  }

  /// Starts the periodic token refresh timer
  /// Checks and refreshes tokens every 5 minutes
  void startTokenRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await checkAndRefreshTokenIfNeeded();
    });
  }

  /// Stops the token refresh timer
  void stopTokenRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Retrieves the stored token expiry time
  Future<DateTime?> _getStoredExpiryTime() async {
    final expiryStr = await secureStorage.read(key: EXPIRY_TIME_KEY);
    if (expiryStr != null) {
      try {
        return DateTime.parse(expiryStr);
      } catch (e) {
        print('Error parsing stored expiry time: $e');
        return null;
      }
    }
    return null;
  }

  /// Stores the token expiry time in secure storage
  Future<void> _storeExpiryTime(DateTime expiryTime) async {
    try {
      await secureStorage.write(
        key: EXPIRY_TIME_KEY,
        value: expiryTime.toIso8601String(),
      );
    } catch (e) {
      print('Error storing expiry time: $e');
    }
  }

  /// Checks network connectivity status
  Future<bool> _checkNetworkConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      return !connectivityResults.contains(ConnectivityResult.none);
    } catch (e) {
      print('Error checking connectivity: $e');
      return false; // Assume no connectivity if check fails
    }
  }

  /// Main method to check and refresh tokens if needed
  /// Returns true if tokens are valid/refreshed, false if login is required
  Future<bool> checkAndRefreshTokenIfNeeded() async {
    print('\n=== Starting Token Refresh Check ===');

    if (_isRefreshing) {
      print('Token refresh already in progress, skipping');
      return true;
    }

    // Check network connectivity first
    final hasConnectivity = await _checkNetworkConnectivity();
    if (!hasConnectivity) {
      print('No network connectivity, deferring token refresh');
      return true; // Return true to avoid forcing logout due to network issues
    }

    final tokenExpiryTime = await _getStoredExpiryTime();
    final currentAccessToken = await secureStorage.read(key: ACCESS_TOKEN_KEY);

    print('Current time: ${DateTime.now()}');
    print('Token expiry time: $tokenExpiryTime');
    print('Has access token: ${currentAccessToken != null}');

    if (tokenExpiryTime == null || currentAccessToken == null) {
      print('No expiry time or access token found, refresh needed');
      return false;
    }

    if (tokenExpiryTime.isAfter(
      DateTime.now().add(const Duration(minutes: 5)),
    )) {
      print('Token still valid for more than 5 minutes, no refresh needed');
      print(
        'Time until expiry: ${tokenExpiryTime.difference(DateTime.now()).inMinutes} minutes',
      );
      return true;
    }

    print('Token expired or expiring soon (within 5 minutes), starting refresh process');

    _isRefreshing = true;
    try {
      final storedRefreshToken = await secureStorage.read(
        key: REFRESH_TOKEN_KEY,
      );
      if (storedRefreshToken == null) {
        print('No refresh token found in storage');
        return false;
      }

      print('Attempting to refresh token with stored refresh token');

      try {
        final refreshUrl = '$baseUrl/auth/refresh/';
        final resp = await _dio.post(
          refreshUrl,
          data: {'refresh': storedRefreshToken},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          final respData = resp.data;
          if (respData['data'] != null) {
            final data = respData['data'];

            // Update access token
            if (data['access'] != null) {
              await secureStorage.write(
                key: ACCESS_TOKEN_KEY,
                value: data['access'],
              );
              print('Access token updated successfully');
            } else {
              print('No access token in refresh response');
              return false;
            }

            // Update refresh token if provided
            if (data['refresh'] != null) {
              await secureStorage.write(
                key: REFRESH_TOKEN_KEY,
                value: data['refresh'],
              );
              print('Refresh token updated successfully');
            }

            // Parse expiry from access JWT and store it
            try {
              final parts = (data['access'] ?? '').split('.');
              if (parts.length >= 2) {
                final payload = parts[1];
                String normalized = base64Url.normalize(payload);
                final decoded = utf8.decode(base64Url.decode(normalized));
                final Map<String, dynamic> payloadMap = jsonDecode(decoded);
                if (payloadMap.containsKey('exp')) {
                  final exp = payloadMap['exp'];
                  DateTime expiryTime;
                  if (exp is int) {
                    expiryTime = DateTime.fromMillisecondsSinceEpoch(
                      exp * 1000,
                    );
                  } else if (exp is String) {
                    final e = int.tryParse(exp);
                    expiryTime = e != null
                        ? DateTime.fromMillisecondsSinceEpoch(e * 1000)
                        : DateTime.now().add(const Duration(hours: 1));
                  } else {
                    expiryTime = DateTime.now().add(const Duration(hours: 1));
                  }
                  await _storeExpiryTime(expiryTime);
                  print('Token expiry updated: $expiryTime');
                } else {
                  await _storeExpiryTime(
                    DateTime.now().add(const Duration(hours: 1)),
                  );
                }
              }
            } catch (e) {
              if (kDebugMode) print('Failed to parse new token expiry: $e');
              await _storeExpiryTime(
                DateTime.now().add(const Duration(hours: 1)),
              );
            }

            return true;
          } else {
            print('No data in refresh response');
            return false;
          }
        } else if (resp.statusCode == 401) {
          print('Refresh endpoint returned 401 - clearing auth');
          await _handleAuthenticationFailure();
          return false;
        } else {
          print('Refresh endpoint returned status ${resp.statusCode}');
          return false;
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          print('Token refresh timed out: $e');
          return true; // defer logout due to timeout/network
        }
        print('DioException during token refresh: $e');
        if (e.response?.statusCode == 401) {
          await _handleAuthenticationFailure();
          return false;
        }
        return true; // don't force logout on generic errors
      } catch (e) {
        print('Error while calling refresh endpoint: $e');
        if (e.toString().contains('401') ||
            e.toString().contains('unauthorized')) {
          await _handleAuthenticationFailure();
          return false;
        }
        return true; // don't force logout on generic errors
      }
    } catch (e) {
      print('Error during token refresh: $e');
      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized') ||
          e.toString().contains('invalid_grant') ||
          e.toString().contains('invalid_token')) {
        print('401/Authentication error detected - tokens are invalid');
        await _handleAuthenticationFailure();
        return false;
      }

      if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('discovery_failed')) {
        print('Network-related error detected, deferring token refresh');
        return true; // Return true to avoid logout due to network issues
      }

      return false;
    } finally {
      _isRefreshing = false;
      print('=== Token Refresh Check Completed ===\n');
    }
  }

  /// Manually triggers a token refresh
  /// Useful for forcing a refresh when needed
  Future<bool> forceRefresh() async {
    return await checkAndRefreshTokenIfNeeded();
  }

  /// Checks if tokens exist in storage
  Future<bool> hasValidTokens() async {
    final accessToken = await secureStorage.read(key: ACCESS_TOKEN_KEY);
    final refreshToken = await secureStorage.read(key: REFRESH_TOKEN_KEY);
    final expiryTime = await _getStoredExpiryTime();

    return accessToken != null &&
        refreshToken != null &&
        expiryTime != null &&
        expiryTime.isAfter(DateTime.now());
  }

  /// Gets the current access token
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: ACCESS_TOKEN_KEY);
  }

  /// Gets the current refresh token
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: REFRESH_TOKEN_KEY);
  }

  /// Gets the token expiry time
  Future<DateTime?> getTokenExpiryTime() async {
    return await _getStoredExpiryTime();
  }

  /// Clears all stored tokens and stops the refresh timer
  Future<void> clearTokens() async {
    stopTokenRefreshTimer();
    await secureStorage.delete(key: ACCESS_TOKEN_KEY);
    await secureStorage.delete(key: REFRESH_TOKEN_KEY);
    await secureStorage.delete(key: EXPIRY_TIME_KEY);
    print('All tokens cleared');
  }

  /// Disposes of the service and cleans up resources
  void dispose() {
    stopTokenRefreshTimer();
  }
}

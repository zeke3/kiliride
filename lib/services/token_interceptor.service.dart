import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kiliride/controllers/notification_handler.dart';
import 'package:kiliride/services/refresh_token.service.dart';
import 'package:kiliride/shared/constants.dart';

/// Generic token interceptor that handles 401 errors and automatically refreshes tokens
/// Works with any Dio instance and service
class TokenInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Track retry attempts to prevent infinite loops
  static const int _maxRetries = 3;
  static bool _isRefreshing = false;
  static int _refreshAttempts = 0;
  static DateTime? _lastRefreshTime;

  TokenInterceptor(this._dio);

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Check if this request has already been retried
      final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

      if (retryCount >= _maxRetries) {
        if (kDebugMode) {
          print('❌ TokenInterceptor: Max retries reached, failing request');
        }
        return handler.next(err);
      }

      // Prevent concurrent refresh attempts
      if (_isRefreshing) {
        if (kDebugMode) {
          print('⏳ TokenInterceptor: Token refresh already in progress, waiting...');
        }

        // Wait for the ongoing refresh to complete (max 10 seconds)
        int waitCount = 0;
        while (_isRefreshing && waitCount < 20) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        // After waiting, try the request again with (hopefully) new token
        final newToken = await _secureStorage.read(key: ACCESS_TOKEN_KEY);
        if (newToken != null) {
          return _retryRequest(err, handler, newToken, retryCount);
        }
        return handler.next(err);
      }

      if (kDebugMode) {
        print('🔄 TokenInterceptor: 401 detected, attempting token refresh...');
      }

      _isRefreshing = true;
      try {
        final newToken = await _refreshAccessToken();

        if (newToken != null) {
          return _retryRequest(err, handler, newToken, retryCount);
        } else {
          if (kDebugMode) print('❌ TokenInterceptor: Token refresh failed');
          return handler.next(err);
        }
      } finally {
        _isRefreshing = false;
      }
    }
    return handler.next(err);
  }

  /// Retries the failed request with a new token
  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
    String newToken,
    int retryCount,
  ) async {
    // Update the failed request with new token
    err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      if (kDebugMode) {
        print('🔄 TokenInterceptor: Retrying request with new token (attempt ${retryCount + 1})...');
        print('📍 Request URL: ${err.requestOptions.method} ${err.requestOptions.path}');
        print('🔑 New token (first 20 chars): ${newToken.substring(0, 20)}...');
      }

      // Create a new Dio instance to avoid interceptor recursion
      final retryDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
      ));

      // Retry the failed request with new token
      final cloneReq = await retryDio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
        ),
      );

      if (kDebugMode) {
        print('✅ TokenInterceptor: Retry successful! Status: ${cloneReq.statusCode}');
      }
      return handler.resolve(cloneReq);
    } catch (e) {
      if (kDebugMode) {
        print('❌ TokenInterceptor: Retry failed - $e');
        if (e is DioException && e.response != null) {
          print('❌ Retry failed with status: ${e.response?.statusCode}');
          print('❌ Response data: ${e.response?.data}');
        }
      }

      // If retry also failed with 401, it means refresh token is invalid
      if (e is DioException && e.response?.statusCode == 401) {
        if (kDebugMode) {
          print('❌ TokenInterceptor: Refresh token invalid, user needs to re-authenticate');
        }
        await RefreshTokenService.instance.clearTokens();

        // Navigate to GetStarted screen
        final navigatorContext = CustomNotificationHandler.navigatorKey.currentContext;
        if (navigatorContext != null) {
          CustomNotificationHandler.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/getstarted',
            (route) => false,
          );
        }
      }

      return handler.next(err);
    }
  }

  /// Helper method to refresh access token using RefreshTokenService
  Future<String?> _refreshAccessToken() async {
    try {
      if (kDebugMode) {
        print('🔄 TokenInterceptor: Forcing token refresh due to 401...');
      }

      // Get the old token for comparison
      final oldAccessToken = await _secureStorage.read(key: ACCESS_TOKEN_KEY);
      if (kDebugMode && oldAccessToken != null) {
        print('🔑 Old token (first 20 chars): ${oldAccessToken.substring(0, oldAccessToken.length > 20 ? 20 : oldAccessToken.length)}...');
      }

      // FORCE refresh regardless of expiry time since we got a 401
      final refreshSuccess = await _forceTokenRefresh();

      if (refreshSuccess) {
        final newAccessToken = await _secureStorage.read(key: ACCESS_TOKEN_KEY);

        // Verify we actually got a new token
        if (newAccessToken != null && newAccessToken != oldAccessToken) {
          if (kDebugMode) {
            print('✅ TokenInterceptor: Access token refreshed successfully');
            print('🔑 New token (first 20 chars): ${newAccessToken.substring(0, newAccessToken.length > 20 ? 20 : newAccessToken.length)}...');
            print('✅ Token changed: ${oldAccessToken?.substring(0, 10) != newAccessToken.substring(0, 10)}');
          }
          return newAccessToken;
        } else {
          if (kDebugMode) {
            print('❌ TokenInterceptor: Token refresh did not provide new token');
            print('❌ Old token == New token: ${oldAccessToken == newAccessToken}');
          }
          return null;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ TokenInterceptor: Error refreshing token - $e');
      }
      return null;
    }
  }

  /// Forces a token refresh regardless of expiry time
  Future<bool> _forceTokenRefresh() async {
    try {
      // Prevent rapid successive refresh attempts (within 2 seconds)
      if (_lastRefreshTime != null &&
          DateTime.now().difference(_lastRefreshTime!) < const Duration(seconds: 2)) {
        if (kDebugMode) {
          print('⏸️ Skipping refresh - last refresh was ${DateTime.now().difference(_lastRefreshTime!).inSeconds}s ago');
        }
        return true; // Return true to avoid logout, token should be fresh
      }

      _refreshAttempts++;
      _lastRefreshTime = DateTime.now();

      if (kDebugMode) {
        print('🔄 Refresh attempt #$_refreshAttempts');
      }

      // Reset counter if it gets too high (prevents overflow)
      if (_refreshAttempts > 100) {
        _refreshAttempts = 1;
      }

      final refreshToken = await _secureStorage.read(key: REFRESH_TOKEN_KEY);
      if (refreshToken == null) {
        if (kDebugMode) {
          print('❌ No refresh token found');
        }
        return false;
      }

      if (kDebugMode) {
        print('📡 Calling refresh endpoint: $baseUrl/auth/refresh/');
        print('🔑 Refresh token (first 20 chars): ${refreshToken.substring(0, refreshToken.length > 20 ? 20 : refreshToken.length)}...');
      }

      // Call the backend refresh endpoint directly
      final refreshUrl = '$baseUrl/auth/refresh/';
      final response = await Dio().post(
        refreshUrl,
        data: {'refresh': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      if (kDebugMode) {
        print('📥 Refresh response status: ${response.statusCode}');
        print('📥 Refresh response data keys: ${response.data?.keys}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respData = response.data;
        if (respData['data'] != null && respData['data']['access'] != null) {
          final newAccessToken = respData['data']['access'] as String;

          if (kDebugMode) {
            print('💾 Storing new access token (first 20 chars): ${newAccessToken.substring(0, newAccessToken.length > 20 ? 20 : newAccessToken.length)}...');
          }

          await _secureStorage.write(
            key: ACCESS_TOKEN_KEY,
            value: newAccessToken,
          );

          if (kDebugMode) {
            print('✅ Forced token refresh successful');
          }
          return true;
        } else {
          if (kDebugMode) {
            print('❌ Response missing data.access field');
            print('❌ Response data: $respData');
          }
        }
      }

      if (kDebugMode) {
        print('❌ Token refresh failed with status: ${response.statusCode}');
        print('❌ Response: ${response.data}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during forced token refresh: $e');
        if (e is DioException) {
          print('❌ DioException type: ${e.type}');
          print('❌ DioException response: ${e.response?.data}');
          print('❌ DioException status: ${e.response?.statusCode}');
        }
      }
      return false;
    }
  }
}

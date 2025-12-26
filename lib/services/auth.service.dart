import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kiliride/models/user.model.dart';
import 'package:kiliride/providers/providers.dart';
import 'package:kiliride/services/db.service.dart';
import 'package:kiliride/services/refresh_token.service.dart';
import 'package:kiliride/services/token_interceptor.service.dart';
import 'package:kiliride/shared/constants.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';

// --- Credentials for Google Play Console testing ---
const String DUMMY_PHONE_NUMBER = '+255678778998';
const String DUMMY_STATIC_OTP = '123456';
// ---------------------------------------------------

class AuthService {
  // --- Singleton Setup ---
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;
  AuthService._internal() {
    _dio.interceptors.add(TokenInterceptor(_dio));
  }

  // --- Core Dependencies ---

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  // --- Public Properties ---

  String? idToken;
  String? auth0AccessToken;

  // --- Getters ---

  // --- Main Public Methods ---

  /// Signs out the user from Firebase and clears local tokens.
  // Future<void> signOut() async {
  //   final String? uid = _auth.currentUser?.uid;

  //   // Stop token refresh timer and clear tokens
  //   RefreshTokenService.instance.dispose();

  //   await _auth.signOut();
  //   await _secureStorage.deleteAll();
  //   if (uid != null) {
  //     try {
  //       DbService().usersRef.doc(uid).update({'notifToken': null});
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print("Error nullifying notifToken during logout: $e");
  //       }
  //     }
  //   }
  // }

  Future<void> signInWithEmail() async {
    try {
      final String? fcmToken = await Funcs.getFCMToken();

      final String nonce = _generateNonce();
      final String nonceHash = _sha256ofString(nonce);
      // REPLACE WITH BACKEND AUTH LOGIC
      // final authorizationTokenRequest = AuthorizationTokenRequest(
      //   oidcClientId,
      //   foodOidcRedirectUri,
      //   issuer: oidcIssuerUrl,
      //   clientSecret: oidcClientSecret,
      //   promptValues: ['login'],
      //   scopes: ['openid', 'profile', 'email', 'offline_access', 'user_id'],
      //   nonce: nonceHash,
      // );
      // final AuthorizationTokenResponse? result = await _appAuth
      //     .authorizeAndExchangeCode(authorizationTokenRequest);

      // if (result == null) {
      //   throw Exception('Login was cancelled or failed.');
      // }

      // await _signInToFirebaseWithOidc(
      //   idToken: result.idToken!,
      //   accessToken: result.accessToken!,
      //   nonce: nonce,
      //   phone: profile?.phoneNumber,
      //   fcmToken: fcmToken,
      // );

      // final String tokenResult = await _setLocalVariables(result);
      // if (tokenResult != SUCCESS_MESSAGE) {
      //   throw Exception('Failed to store tokens: $tokenResult');
      // }

      // Start the refresh token service after successful login
      await _startRefreshTokenService();
    } catch (e) {
      // This will catch all other errors (network issues, configuration problems, etc.)
      if (kDebugMode) print("An unexpected sign-in error occurred: $e");
      // Re-throw the original error's message for more context.
      throw Exception('Authentication failed: Please try again later.');
    }
  }

  /// Logs in a user using username (email) and password.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required WidgetRef ref,
  }) async {
    final String loginUrl = '$baseUrl/auth/login/';

    try {
      final response = await _dio.post(
        loginUrl,
        data: {'username': username, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final responseData = response.data;
      print("RESPONSE DATA: $responseData");
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['data'] != null) {
          final data = responseData['data'];

          if (responseData['data'] != null &&
              responseData['data']['user'] != null) {
            try {
              final userData = responseData['data']['user'];
              print("USER TYPE: ${responseData['data']['user']['user_type']}");
              final user = UserModel.fromJson(userData);
              ref.read(userInfoProvider).setUser(user);
              print('✅ User data stored in provider: ${user.email}');
            } catch (e) {
              print('❌ Error storing user data in provider: $e');
            }
          }

          // Save access token
          auth0AccessToken = data['access'];
          if (data['access'] != null) {
            await _secureStorage.write(
              key: ACCESS_TOKEN_KEY,
              value: data['access'],
            );
          }

          // Save refresh token if provided
          if (data['refresh'] != null) {
            await _secureStorage.write(
              key: REFRESH_TOKEN_KEY,
              value: data['refresh'],
            );
          }

          // Try to extract expiry from JWT access token, fallback to 1 hour
          DateTime expiryTime = DateTime.now().add(const Duration(hours: 1));
          try {
            final parts = (data['access'] ?? '').split('.');
            if (parts.length >= 2) {
              final payload = parts[1];
              // base64url decode (normalize padding)
              String normalized = base64Url.normalize(payload);
              final decoded = utf8.decode(base64Url.decode(normalized));
              final Map<String, dynamic> payloadMap = jsonDecode(decoded);
              if (payloadMap.containsKey('exp')) {
                final exp = payloadMap['exp'];
                if (exp is int) {
                  expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
                } else if (exp is String) {
                  final e = int.tryParse(exp);
                  if (e != null)
                    expiryTime = DateTime.fromMillisecondsSinceEpoch(e * 1000);
                }
              }
            }
          } catch (e) {
            if (kDebugMode) print('Failed to parse token expiry: $e');
          }

          await _secureStorage.write(
            key: EXPIRY_TIME_KEY,
            value: expiryTime.toIso8601String(),
          );

          // Optionally store user info in secure storage
          try {
            if (data['user'] != null) {
              await _secureStorage.write(
                key: 'user',
                value: jsonEncode(data['user']),
              );
            }
          } catch (e) {
            if (kDebugMode) print('Failed to store user info: $e');
          }

          // Start refresh token service
          await _startRefreshTokenService();
        }

        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'Login successful',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      if (e is DioException) {
        print('DioException Type: ${e.type}');
        print('DioException Message: ${e.message}');

        if (e.response != null) {
          print('Error Response Status: ${e.response?.statusCode}');
          print('Error Response Data: ${e.response?.data}');
          print('Error Response Headers: ${e.response?.headers}');
        }

        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('Connection timeout - Check internet connection');
            break;
          case DioExceptionType.sendTimeout:
            print('Send timeout - Request took too long to send');
            break;
          case DioExceptionType.receiveTimeout:
            print('Receive timeout - Server took too long to respond');
            break;
          case DioExceptionType.badResponse:
            print('Bad response from server');
            if (e.response?.data != null) {
              print('Server error details: ${e.response?.data}');
            }
            break;
          case DioExceptionType.cancel:
            print('Request was cancelled');
            break;
          case DioExceptionType.unknown:
            print('Unknown network error - possibly no internet connection');
            break;
          default:
            print('Other Dio error occurred');
            break;
        }
      } else {
        print('Non-Dio error: $e');
        print('Error type: ${e.runtimeType}');
      }
      return {
        'success': false,
        'message': 'Failed to login. Please check your network connection.',
      };
    }
  }

  /// Logs out the current user by notifying the backend and clearing local tokens.
  Future<Map<String, dynamic>> logout() async {
    final String logoutUrl = '$baseUrl/auth/logout/';

    try {
      final String? accessToken = await _secureStorage.read(
        key: ACCESS_TOKEN_KEY,
      );
      final String? refreshToken = await _secureStorage.read(
        key: REFRESH_TOKEN_KEY,
      );

      final headers = {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

      final response = await _dio.post(
        logoutUrl,
        data: {'refresh': refreshToken ?? ''},
        options: Options(headers: headers),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Stop refresh service and clear stored tokens
        try {
          RefreshTokenService.instance.dispose();
        } catch (e) {
          if (kDebugMode) print('Error disposing refresh service: $e');
        }

        try {
          await _secureStorage.delete(key: ACCESS_TOKEN_KEY);
          await _secureStorage.delete(key: REFRESH_TOKEN_KEY);
          await _secureStorage.delete(key: EXPIRY_TIME_KEY);
          await _secureStorage.delete(key: 'user');
        } catch (e) {
          if (kDebugMode)
            print('Error clearing secure storage during logout: $e');
        }

        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'Logout successful',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Logout failed',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print('Logout error: $e');
      if (e is DioException) {
        print('DioException Type: ${e.type}');
        print('DioException Message: ${e.message}');

        if (e.response != null) {
          print('Error Response Status: ${e.response?.statusCode}');
          print('Error Response Data: ${e.response?.data}');
          print('Error Response Headers: ${e.response?.headers}');
        }

        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('Connection timeout - Check internet connection');
            break;
          case DioExceptionType.sendTimeout:
            print('Send timeout - Request took too long to send');
            break;
          case DioExceptionType.receiveTimeout:
            print('Receive timeout - Server took too long to respond');
            break;
          case DioExceptionType.badResponse:
            print('Bad response from server');
            if (e.response?.data != null) {
              print('Server error details: ${e.response?.data}');
            }
            break;
          case DioExceptionType.cancel:
            print('Request was cancelled');
            break;
          case DioExceptionType.unknown:
            print('Unknown network error - possibly no internet connection');
            break;
          default:
            print('Other Dio error occurred');
            break;
        }
      } else {
        print('Non-Dio error: $e');
        print('Error type: ${e.runtimeType}');
      }

      return {
        'success': false,
        'message': 'Failed to logout. Please check your network connection.',
      };
    }
  }

  /// Registers a new user with the backend API.
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final String registerUrl = '$baseUrl/auth/register/';
    print("REGISTER URL: $registerUrl");
    try {
      final response = await _dio.post(
        registerUrl,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print("REGISTER RESPONSE STATUS: ${response.statusCode}");

      final responseData = response.data;
      print("REGISTER RESPONSE: $responseData");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (e is DioException) {
        // Handle bad response (400, 401, etc.)
        if (e.type == DioExceptionType.badResponse) {
          final responseData = e.response?.data;
          final statusCode = e.response?.statusCode;

          if (kDebugMode) {
            print('Bad response: $statusCode - $responseData');
          }

          // Handle validation errors (400)
          if (statusCode == 400 && responseData != null) {
            String errorMessage =
                responseData['message'] ?? 'Registration failed';

            // Extract specific field errors if available
            if (responseData['errors'] != null) {
              final errors = responseData['errors'] as Map<String, dynamic>;
              List<String> errorMessages = [];

              errors.forEach((field, messages) {
                if (messages is List && messages.isNotEmpty) {
                  errorMessages.add(messages[0].toString());
                }
              });

              if (errorMessages.isNotEmpty) {
                errorMessage = errorMessages.join('\n');
              }
            }

            return {
              'success': false,
              'message': errorMessage,
              'status_code': statusCode,
              'errors': responseData['errors'],
            };
          }

          // Handle other bad responses
          return {
            'success': false,
            'message': responseData?['message'] ?? 'Registration failed',
            'status_code': statusCode,
          };
        }

        // Handle timeout errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          if (kDebugMode) print('Timeout error: ${e.message}');
          return {
            'success': false,
            'message': 'Request timed out. Please try again.',
          };
        }

        // Handle cancelled requests
        if (e.type == DioExceptionType.cancel) {
          if (kDebugMode) print('Request was cancelled: ${e.message}');
          return {'success': false, 'message': 'Request was cancelled.'};
        }

        // Handle unknown/network errors
        if (kDebugMode) print('Dio error: ${e.type} - ${e.message}');
        return {
          'success': false,
          'message':
              'Failed to register. Please check your network connection.',
        };
      }

      // Handle non-Dio exceptions
      if (kDebugMode) print("Registration error: $e");
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  /// Sends an OTP to the given phone number.
  Future<Map<String, dynamic>> sendPhoneOtp({
    required String phone,
    required String type,
    bool isRegister = false,
  }) async {
    // If the dummy number is used, return success immediately without sending an SMS.
    if (phone == DUMMY_PHONE_NUMBER) {
      return {'sent': true, 'expiry': 300};
    }

    // final String baseUrl = Uri.parse(oidcIssuerUrl).origin; // REPLACE WITH BACKEND AUTH LOGIC
    final String baseUrl = Uri.parse('oidcIssuerUrl').origin;
    Response resp;

    try {
      const String regUrl = "https://auth.sanalogistic.com/request-otp";
      var body = {
        'phone_number': phone,
        if (type == 'whatsapp') 'type': 'whatsapp',
      };

      resp = await _dio.post(
        regUrl,
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final json = resp.data;
      if (resp.statusCode == 200) {
        return {'sent': true, 'expiry': json['expires_in']};
      } else {
        throw Exception(json['message'] ?? 'Failed to send OTP.');
      }
    } catch (e) {
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('Connection timeout error: ${e.message}');
            break;
          case DioExceptionType.sendTimeout:
            print('Send timeout error: ${e.message}');
            break;
          case DioExceptionType.receiveTimeout:
            print('Receive timeout error: ${e.message}');
            break;
          case DioExceptionType.badResponse:
            print(
              'Bad response: ${e.response?.statusCode} - ${e.response?.data}',
            );
            break;
          case DioExceptionType.cancel:
            print('Request was cancelled: ${e.message}');
            break;
          case DioExceptionType.unknown:
            print('Unknown error occurred: ${e.message}');
            break;
          default:
            print('An unexpected Dio error occurred: ${e.message}');
            break;
        }
      } else {
        print('An unexpected error occurred sending phone otp: $e');
      }
      if (kDebugMode) print("Send OTP error: $e");
      throw Exception("Failed to send OTP. Please check your network.");
    }
  }

  /// Verifies OTP for email or phone number and signs the user in.
  Future<Map<String, dynamic>> verifyOtp({
    required String emailOrPhone,
    required String otpCode,
    String? verificationType,
    bool isRegistration = false,
  }) async {
    String verifyUrl;

    if (isRegistration) {
      verifyUrl = '$baseUrl/auth/verify-otp/';
    } else {
      verifyUrl = '$baseUrl/auth/otp-login/';
    }
    // final String verifyUrl = '$baseUrl/auth/verify-otp/';
    // final String verifyUrl = '$baseUrl/auth/otp-login/';

    try {
      final Map<String, dynamic> body = {
        'email_or_phone': emailOrPhone,
        'otp_code': otpCode,
      };

      if (verificationType != null) {
        body['verification_type'] = verificationType;
      }

      final response = await _dio.post(
        verifyUrl,
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store tokens
        if (responseData['data'] != null) {
          final data = responseData['data'];
          auth0AccessToken = data['access'];

          await _secureStorage.write(
            key: ACCESS_TOKEN_KEY,
            value: data['access'],
          );

          if (data['refresh'] != null) {
            await _secureStorage.write(
              key: REFRESH_TOKEN_KEY,
              value: data['refresh'],
            );
          }

          // Store token expiry time (default to 1 hour for JWT tokens)
          final expiryTime = DateTime.now().add(const Duration(hours: 1));
          await _secureStorage.write(
            key: EXPIRY_TIME_KEY,
            value: expiryTime.toIso8601String(),
          );

          // Start the refresh token service
          await _startRefreshTokenService();
        }

        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'OTP verified successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'OTP verification failed',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Verify OTP error: $e");
      if (e is DioException) {
        print('DioException Type: ${e.type}');
        print('DioException Message: ${e.message}');

        if (e.response != null) {
          print('Error Response Status: ${e.response?.statusCode}');
          print('Error Response Data: ${e.response?.data}');
          print('Error Response Headers: ${e.response?.headers}');
        }

        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('Connection timeout - Check internet connection');
            break;
          case DioExceptionType.sendTimeout:
            print('Send timeout - Request took too long to send');
            break;
          case DioExceptionType.receiveTimeout:
            print('Receive timeout - Server took too long to respond');
            break;
          case DioExceptionType.badResponse:
            print('Bad response from server');
            if (e.response?.data != null) {
              print('Server error details: ${e.response?.data}');
            }
            break;
          case DioExceptionType.cancel:
            print('Request was cancelled');
            break;
          case DioExceptionType.unknown:
            print('Unknown network error - possibly no internet connection');
            break;
          default:
            print('Other Dio error occurred');
            break;
        }
      } else {
        print('Non-Dio error: $e');
        print('Error type: ${e.runtimeType}');
      }

      return {
        'success': false,
        'message':
            'Failed to verify OTP. Please check your network connection.',
      };
    }
  }

  /// Resends OTP to email or phone number.
  Future<Map<String, dynamic>> resendOtp({
    required String emailOrPhone,
    required String deliveryMethod,
  }) async {
    final String resendUrl = '$baseUrl/auth/resend-otp/';

    try {
      final response = await _dio.post(
        resendUrl,
        data: {
          'email_or_phone': emailOrPhone,
          'delivery_method': deliveryMethod,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'OTP resent successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to resend OTP',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Resend OTP error: $e");
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('Connection timeout error: ${e.message}');
            break;
          case DioExceptionType.sendTimeout:
            print('Send timeout error: ${e.message}');
            break;
          case DioExceptionType.receiveTimeout:
            print('Receive timeout error: ${e.message}');
            break;
          case DioExceptionType.badResponse:
            print(
              'Bad response: ${e.response?.statusCode} - ${e.response?.data}',
            );
            break;
          case DioExceptionType.cancel:
            print('Request was cancelled: ${e.message}');
            break;
          case DioExceptionType.unknown:
            print('Unknown error occurred: ${e.message}');
            break;
          default:
            print('An unexpected Dio error occurred: ${e.message}');
            break;
        }
      } else {
        print('An unexpected error occurred resending otp: $e');
      }
      return {
        'success': false,
        'message':
            'Failed to resend OTP. Please check your network connection.',
      };
    }
  }

  /// Requests OTP for login to email or phone number.
  ///
  /// [emailOrPhone] can be either an email address (e.g., "j1997ames@gmail.com")
  /// or a phone number (e.g., "+255742892731").
  ///
  /// [deliveryMethod] must be either "email" or "sms" to specify how the OTP should be delivered.
  ///
  /// Returns a Map with the following structure:
  /// - success: bool - Whether the request was successful
  /// - status: String - Status from the backend (if available)
  /// - message: String - User-friendly message
  /// - data: Map - Additional data from the backend with the following fields:
  ///   - email: String - User's email address
  ///   - phone_number: String - User's phone number
  ///   - delivery_method: String - How the OTP was delivered (email/sms)
  ///   - otp_sent: bool - Whether OTP was sent successfully
  /// - status_code: int - HTTP status code (if request failed)
  Future<Map<String, dynamic>> requestOtpLogin({
    required String emailOrPhone,
    required String deliveryMethod,
  }) async {
    final String requestOtpLoginUrl = '$baseUrl/auth/request-otp-login/';

    try {
      // Validate delivery method
      if (deliveryMethod != 'email' && deliveryMethod != 'sms') {
        return {
          'success': false,
          'message': 'Invalid delivery method. Must be "email" or "sms".',
        };
      }

      final response = await _dio.post(
        requestOtpLoginUrl,
        data: {
          'email_or_phone': emailOrPhone,
          'delivery_method': deliveryMethod,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'Login code sent successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send login code',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Request OTP login error: $e");
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('Connection timeout error: ${e.message}');
            break;
          case DioExceptionType.sendTimeout:
            print('Send timeout error: ${e.message}');
            break;
          case DioExceptionType.receiveTimeout:
            print('Receive timeout error: ${e.message}');
            break;
          case DioExceptionType.badResponse:
            print(
              'Bad response: ${e.response?.statusCode} - ${e.response?.data}',
            );
            // Extract error message from response if available
            if (e.response?.data != null) {
              final errorData = e.response!.data;
              return {
                'success': false,
                'message': errorData['message'] ?? 'Failed to send login code',
                'status_code': e.response?.statusCode,
              };
            }
            break;
          case DioExceptionType.cancel:
            print('Request was cancelled: ${e.message}');
            break;
          case DioExceptionType.unknown:
            print('Unknown error occurred: ${e.message}');
            break;
          default:
            print('An unexpected Dio error occurred: ${e.message}');
            break;
        }
      } else {
        print('An unexpected error occurred requesting OTP login: $e');
      }
      return {
        'success': false,
        'message':
            'Failed to send login code. Please check your network connection.',
      };
    }
  }

  /// Sends OTP for password reset to email or phone number.
  ///
  /// [emailOrPhone] can be either an email address (e.g., "john.doe@example.com")
  /// or a phone number (e.g., "+255712345678").
  ///
  /// [deliveryMethod] must be either "email" or "sms" to specify how the OTP should be delivered.
  ///
  /// Returns a Map with the following structure:
  /// - success: bool - Whether the request was successful
  /// - status: String - Status from the backend (if available)
  /// - message: String - User-friendly message
  /// - data: Map - Additional data from the backend (if available)
  /// - status_code: int - HTTP status code (if request failed)
  Future<Map<String, dynamic>> forgotPassword({
    required String emailOrPhone,
    required String deliveryMethod,
  }) async {
    final String forgotPasswordUrl = '$baseUrl/auth/forgot-password/';

    try {
      // Validate delivery method
      if (deliveryMethod != 'email' && deliveryMethod != 'sms') {
        return {
          'success': false,
          'message': 'Invalid delivery method. Must be "email" or "sms".',
        };
      }

      final response = await _dio.post(
        forgotPasswordUrl,
        data: {
          'email_or_phone': emailOrPhone,
          'delivery_method': deliveryMethod,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message':
              responseData['message'] ?? 'Password reset OTP sent successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to send password reset OTP',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Forgot password error: $e");
      return {
        'success': false,
        'message':
            'Failed to send password reset OTP. Please check your network connection.',
      };
    }
  }

  /// Verifies the OTP code sent for password reset.
  ///
  /// [emailOrPhone] can be either an email address (e.g., "john.doe@example.com")
  /// or a phone number (e.g., "+255712345678").
  ///
  /// [otpCode] is the OTP code received via email or SMS.
  ///
  /// Returns a Map with the following structure:
  /// - success: bool - Whether the OTP verification was successful
  /// - status: String - Status from the backend (if available)
  /// - message: String - User-friendly message
  /// - data: Map - Additional data from the backend (e.g., reset token)
  /// - status_code: int - HTTP status code (if request failed)
  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String emailOrPhone,
    required String otpCode,
  }) async {
    final String verifyUrl = '$baseUrl/auth/verify-password-reset-otp/';

    try {
      final response = await _dio.post(
        verifyUrl,
        data: {'email_or_phone': emailOrPhone, 'otp_code': otpCode},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'OTP verified successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid or expired OTP',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Verify password reset OTP error: $e");
      return {
        'success': false,
        'message':
            'Failed to verify OTP. Please check your network connection.',
      };
    }
  }

  /// Resets the user's password with a new password after OTP verification.
  ///
  /// [emailOrPhone] can be either an email address (e.g., "john.doe@example.com")
  /// or a phone number (e.g., "+255712345678").
  ///
  /// [otpCode] is the OTP code that was verified.
  ///
  /// [newPassword] is the new password to set for the user.
  ///
  /// Returns a Map with the following structure:
  /// - success: bool - Whether the password reset was successful
  /// - status: String - Status from the backend (if available)
  /// - message: String - User-friendly message
  /// - data: Map - Additional data from the backend (if available)
  /// - status_code: int - HTTP status code (if request failed)
  Future<Map<String, dynamic>> resetPassword({
    required String emailOrPhone,
    required String otpCode,
    required String newPassword,
  }) async {
    final String resetPasswordUrl = '$baseUrl/auth/reset-password/';

    try {
      // Basic password validation
      if (newPassword.isEmpty || newPassword.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters long.',
        };
      }

      final response = await _dio.post(
        resetPasswordUrl,
        data: {
          'email_or_phone': emailOrPhone,
          'otp_code': otpCode,
          'new_password': newPassword,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'Password reset successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to reset password',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Reset password error: $e");
      return {
        'success': false,
        'message':
            'Failed to reset password. Please check your network connection.',
      };
    }
  }

  /// Completes the user's profile as an individual client.
  ///
  /// This method requires the user to be authenticated (have a valid access token).
  ///
  /// Parameters:
  /// - [gender]: User's gender (e.g., "Male", "Female")
  /// - [dateOfBirth]: Date of birth in format "YYYY-MM-DD" (e.g., "1990-01-01")
  /// - [idNumber]: National ID number
  /// - [tinNumber]: Tax Identification Number (TIN)
  /// - [phoneNumber]: Phone number with country code (e.g., "+255742892731")
  /// - [postalAddress]: Postal address (e.g., "P.O. Box 123, Dar es Salaam")
  /// - [physicalAddress]: Physical address (e.g., "123 Main St, Dar es Salaam")
  /// - [sourceOfFunds]: Source of funds (e.g., "SALARY", "BUSINESS", "INVESTMENT")
  /// - [otherSourceOfFunds]: Other source of funds description (optional, required if sourceOfFunds is "OTHER")
  ///
  /// Returns a Map with the following structure:
  /// - success: bool - Whether the request was successful
  /// - status: String - Status from the backend
  /// - message: String - User-friendly message
  /// - data: Map - Profile completion data with the following fields:
  ///   - client_code: String (e.g., "AIT/IND/2025/000003")
  ///   - client_type: String (e.g., "INDIVIDUAL")
  ///   - status: String (e.g., "ACTIVE")
  /// - status_code: int - HTTP status code (if request failed)
  Future<Map<String, dynamic>> completeIndividualProfile({
    required String gender,
    required String dateOfBirth,
    required String idNumber,
    required String tinNumber,
    required String phoneNumber,
    required String postalAddress,
    required String physicalAddress,
    required String sourceOfFunds,
    String? otherSourceOfFunds,
  }) async {
    final String completeProfileUrl =
        '$baseUrl/auth/complete-profile/individual/';

    try {
      // Get access token for authentication
      final String? accessToken = await _secureStorage.read(
        key: ACCESS_TOKEN_KEY,
      );

      if (accessToken == null) {
        return {
          'success': false,
          'message': 'You must be logged in to complete your profile.',
        };
      }

      // Build request body
      final Map<String, dynamic> requestBody = {
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'id_number': idNumber,
        'tin_number': tinNumber,
        'phone_number': phoneNumber,
        'postal_address': postalAddress,
        'physical_address': physicalAddress,
        'source_of_funds': sourceOfFunds,
        'other_source_of_funds': otherSourceOfFunds ?? '',
      };

      final response = await _dio.post(
        completeProfileUrl,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message':
              responseData['message'] ?? 'Profile completed successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to complete profile',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Complete individual profile error: $e");
      return {
        'success': false,
        'message':
            'Failed to complete profile. Please check your network connection.',
      };
    }
  }

  /// Completes the user's profile as a corporate client.
  ///
  /// This method requires the user to be authenticated (have a valid access token).
  ///
  /// Parameters:
  /// - [companyName]: Official company name
  /// - [tinNumber]: Tax Identification Number (TIN)
  /// - [businessLicenseNo]: Business license number
  /// - [businessType]: Type of business (e.g., "Technology", "Manufacturing")
  /// - [postalAddress]: Company postal address (e.g., "P.O. Box 456, Dar es Salaam")
  /// - [physicalAddress]: Company physical address
  /// - [phoneNumber]: Company phone number with country code
  /// - [email]: Company email address
  /// - [contactPersonName]: Name of the contact person
  /// - [contactPersonPosition]: Position of the contact person
  /// - [contactPersonPhone]: Contact person's phone number
  /// - [contactPersonEmail]: Contact person's email address
  /// - [numStaffDeclared]: Number of staff declared
  /// - [numDependantsDeclared]: Number of dependants declared
  /// - [sourceOfFunds]: Source of funds (e.g., "BUSINESS_INCOME", "INVESTMENT")
  /// - [otherSourceOfFunds]: Other source of funds description (optional)
  /// - [politicallyExposed]: Whether the company is politically exposed
  ///
  /// Returns a Map with the following structure:
  /// - success: bool - Whether the request was successful
  /// - status: String - Status from the backend
  /// - message: String - User-friendly message
  /// - data: Map - Profile completion data with the following fields:
  ///   - client_code: String (e.g., "AIT/CO/2025/000003")
  ///   - client_type: String (e.g., "CORPORATE")
  ///   - status: String (e.g., "ACTIVE")
  /// - status_code: int - HTTP status code (if request failed)
  Future<Map<String, dynamic>> completeCorporateProfile({
    required String companyName,
    required String tinNumber,
    required String businessLicenseNo,
    required String businessType,
    required String postalAddress,
    required String physicalAddress,
    required String phoneNumber,
    required String email,
    required String contactPersonName,
    required String contactPersonPosition,
    required String contactPersonPhone,
    required String contactPersonEmail,
    required int numStaffDeclared,
    required int numDependantsDeclared,
    required String sourceOfFunds,
    String? otherSourceOfFunds,
    required bool politicallyExposed,
  }) async {
    final String completeProfileUrl =
        '$baseUrl/auth/complete-profile/corporate/';

    try {
      // Get access token for authentication
      final String? accessToken = await _secureStorage.read(
        key: ACCESS_TOKEN_KEY,
      );

      if (accessToken == null) {
        return {
          'success': false,
          'message': 'You must be logged in to complete your profile.',
        };
      }

      // Build request body
      final Map<String, dynamic> requestBody = {
        'company_name': companyName,
        'tin_number': tinNumber,
        'business_license_no': businessLicenseNo,
        'business_type': businessType,
        'postal_address': postalAddress,
        'physical_address': physicalAddress,
        'phone_number': phoneNumber,
        'email': email,
        'contact_person_name': contactPersonName,
        'contact_person_position': contactPersonPosition,
        'contact_person_phone': contactPersonPhone,
        'contact_person_email': contactPersonEmail,
        'num_staff_declared': numStaffDeclared,
        'num_dependants_declared': numDependantsDeclared,
        'source_of_funds': sourceOfFunds,
        'other_source_of_funds': otherSourceOfFunds ?? '',
        'politically_exposed': politicallyExposed,
      };

      final response = await _dio.post(
        completeProfileUrl,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message':
              responseData['message'] ?? 'Profile completed successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to complete profile',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Complete corporate profile error: $e");
      return {
        'success': false,
        'message':
            'Failed to complete profile. Please check your network connection.',
      };
    }
  }

  /// Retrieves the authenticated user's profile information.
  ///
  /// This method requires the user to be authenticated (have a valid access token).
  ///
  /// Returns a Map with the following structure:
  /// - success: bool - Whether the request was successful
  /// - status: String - Status from the backend (if available)
  /// - message: String - User-friendly message
  /// - data: Map - User profile data with the following fields:
  ///   - user_id: int
  ///   - first_name: String
  ///   - last_name: String
  ///   - email: String
  ///   - phone_number: String
  ///   - is_verified: bool
  ///   - verification_channel: String
  ///   - client_type: String?
  ///   - profile_completed: bool
  ///   - created_at: String (ISO 8601 format)
  /// - status_code: int - HTTP status code (if request failed)
  Future<Map<String, dynamic>> getMyProfile({required WidgetRef ref}) async {
    final String myProfileUrl = '$baseUrl/auth/my-profile/';

    try {
      // Get access token for authentication
      final String? accessToken = await _secureStorage.read(
        key: ACCESS_TOKEN_KEY,
      );

      if (accessToken == null) {
        return {
          'success': false,
          'message': 'You must be logged in to view your profile.',
        };
      }

      final response = await _dio.get(
        myProfileUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final responseData = response.data;

      if (response.statusCode == 200) {
        if (responseData['data'] != null) {
          try {
            final userData = responseData['data'];
            final user = UserModel.fromJson(userData);
            ref.read(userInfoProvider).setUser(user);
            print('✅ User data stored in provider: ${user.email}');
          } catch (e) {
            print('❌ Error storing user data in provider: $e');
          }
        }

        return {
          'success': true,
          'status': responseData['status'],
          'message': 'Profile retrieved successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to retrieve profile',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Get profile error: $e");
      return {
        'success': false,
        'message':
            'Failed to retrieve profile. Please check your network connection.',
      };
    }
  }

  /// Changes the user's password when they are already authenticated.
  ///
  /// [oldPassword] is the user's current password for verification.
  ///
  /// [newPassword] is the new password to set.
  ///
  /// This method requires the user to be authenticated (have a valid access token).
  ///
  /// Returns a Map with the following structure:
  /// - success: bool - Whether the password change was successful
  /// - status: String - Status from the backend (if available)
  /// - message: String - User-friendly message
  /// - data: Map - Additional data from the backend (if available)
  /// - status_code: int - HTTP status code (if request failed)
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final String changePasswordUrl = '$baseUrl/auth/change-password/';

    try {
      // Basic password validation
      if (newPassword.isEmpty || newPassword.length < 6) {
        return {
          'success': false,
          'message': 'New password must be at least 6 characters long.',
        };
      }

      if (oldPassword == newPassword) {
        return {
          'success': false,
          'message': 'New password must be different from the old password.',
        };
      }

      // Get access token for authentication
      final String? accessToken = await _secureStorage.read(
        key: ACCESS_TOKEN_KEY,
      );

      if (accessToken == null) {
        return {
          'success': false,
          'message': 'You must be logged in to change your password.',
        };
      }

      final response = await _dio.post(
        changePasswordUrl,
        data: {'old_password': oldPassword, 'new_password': newPassword},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'status': responseData['status'],
          'message': responseData['message'] ?? 'Password changed successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to change password',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) print("Change password error: $e");
      return {
        'success': false,
        'message':
            'Failed to change password. Please check your network connection.',
      };
    }
  }

  /// Starts the refresh token service after successful authentication
  Future<void> _startRefreshTokenService() async {
    try {
      print('🔄 Starting refresh token service after login...');
      await RefreshTokenService.instance.init();
      print('✅ Refresh token service started successfully');
    } catch (e) {
      print('❌ Error starting refresh token service: $e');
      // Don't throw error as login was successful, just log the issue
    }
  }

  // --- Cryptography Helpers ---
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

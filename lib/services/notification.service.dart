import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

class NotificationService {
  static const String relativeServiceAccountPath =
      'assets/files/thinking-digit-368121-firebase-adminsdk-sq1ok-2ca881ca44.json';
  static const List<String> scopes = [
    'https://www.googleapis.com/auth/firebase.messaging'
  ];
  static const String _accessTokenKey = 'firebase_access_token';
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Get the stored token or fetch a new one if it doesn't exist
  static Future<String> getAccessToken() async {
    // Check if we have a stored token
    String? storedToken = await _secureStorage.read(key: _accessTokenKey);
    if (storedToken != null) {
      return storedToken;
    }

    // If no stored token, generate a new one
    return await _refreshAccessToken();
  }

  // Refresh the token and store it
  static Future<String> _refreshAccessToken() async {
    // Use rootBundle to load the JSON file from assets
    final serviceAccountJson =
    await rootBundle.loadString(relativeServiceAccountPath);
    final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
    final client = http.Client();

    try {
      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        credentials,
        scopes,
        client,
      );

      // Store the new token
      await _secureStorage.write(
          key: _accessTokenKey, value: accessCredentials.accessToken.data);
      return accessCredentials.accessToken.data;
    } finally {
      client.close();
    }
  }

  // Manually trigger token refresh
  static Future<String> refreshToken() async {
    return await _refreshAccessToken();
  }
}

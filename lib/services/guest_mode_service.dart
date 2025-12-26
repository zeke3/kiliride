import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GuestModeService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _guestModeKey = 'is_guest_mode';

  static bool _isGuestMode = false;

  /// Initialize guest mode state on app start
  static Future<void> initGuestMode() async {
    try {
      final String? guestModeValue = await _storage.read(key: _guestModeKey);
      _isGuestMode = guestModeValue == 'true';
    } catch (e) {
      debugPrint('Error reading guest mode state: $e');
      _isGuestMode = false;
    }
  }

  /// Enable guest mode
  static Future<void> enableGuestMode() async {
    try {
      _isGuestMode = true;
      await _storage.write(key: _guestModeKey, value: 'true');
      debugPrint('Guest mode enabled');
    } catch (e) {
      debugPrint('Error enabling guest mode: $e');
    }
  }

  /// Disable guest mode (when user logs in)
  static Future<void> disableGuestMode() async {
    try {
      _isGuestMode = false;
      await _storage.delete(key: _guestModeKey);
      debugPrint('Guest mode disabled');
    } catch (e) {
      debugPrint('Error disabling guest mode: $e');
    }
  }

  /// Check if app is in guest mode
  static bool get isGuestMode => _isGuestMode;

  /// Check if user is authenticated (not guest and has current user)
  static bool get isAuthenticated => !_isGuestMode;

  /// Set guest mode state directly (useful for testing)
  static void setGuestMode(bool value) {
    _isGuestMode = value;
  }

  /// Reset guest mode state completely (clears both memory and storage)
  static Future<void> resetGuestMode() async {
    try {
      _isGuestMode = false;
      await _storage.delete(key: _guestModeKey);
      debugPrint('Guest mode reset completely');
    } catch (e) {
      debugPrint('Error resetting guest mode: $e');
    }
  }
}

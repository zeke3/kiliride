import 'package:flutter/foundation.dart';
import 'package:kiliride/models/user.model.dart';

/// User state provider to manage user data using ChangeNotifier
class UserProvider with ChangeNotifier {
  UserModel? _user;

  /// Get current user
  UserModel? get user => _user;

  /// Set user data
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// Update user data with copyWith
  void updateUser({
    String? id,
    String? firstName,
    String? lastName,
    String? avatarURL,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    String? ageGroup,
    String? notifToken,
    String? role,
    String? userType,
    DateTime? lastSeen,
    String? status,
    String? authType,
    CurrencyData? currency,
    String? bio,
    CountryData? country,
    String? deviceUniqueId,
    bool? isUserVerified,
    bool? isProfileCompleted,
    bool? isActive,
    bool? isStaff,
    int? numberOfPostedJobsByUser,
    DateTime? dateAdded,
    DateTime? dateUpdated,
    List<String>? fcmTokens,
    bool? isProduction,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        id: id,
        firstName: firstName,
        lastName: lastName,
        avatarURL: avatarURL,
        email: email,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        gender: gender,
        ageGroup: ageGroup,
        notifToken: notifToken,
        role: role,
        userType: userType,
        lastSeen: lastSeen,
        status: status,
        authType: authType,
        currency: currency,
        bio: bio,
        country: country,
        deviceUniqueId: deviceUniqueId,
        isUserVerified: isUserVerified,
        isProfileCompleted: isProfileCompleted,
        isActive: isActive,
        isStaff: isStaff,
        numberOfPostedJobsByUser: numberOfPostedJobsByUser,
        dateAdded: dateAdded,
        dateUpdated: dateUpdated,
        fcmTokens: fcmTokens,
        isProduction: isProduction,
      );
      notifyListeners();
    }
  }
  /// Check if user is logged in
  bool get isLoggedIn => _user != null;

  /// Check if profile is completed
  bool get isProfileCompleted => _user?.isProfileCompleted ?? false;

  /// Get user ID
  String? get userId => _user?.id;

  /// Get user email
  String? get userEmail => _user?.email;

  /// Get user phone number
  String? get userPhoneNumber => _user?.phoneNumber;

  /// Get user full name
  String get userFullName {
    if (_user == null) return '';
    final firstName = _user!.firstName ?? '';
    final lastName = _user!.lastName ?? '';
    return '$firstName $lastName'.trim();
  }

  /// Get user first name
  String get userFirstName => _user?.firstName ?? '';

  /// Get user last name
  String get userLastName => _user?.lastName ?? '';

  /// Get user avatar URL
  String? get userAvatarURL => _user?.avatarURL;

  /// Get user role
  String? get userRole => _user?.role;

  /// Get user type
  String? get userType => _user?.userType;

  /// Check if user is active
  bool get isActive => _user?.isActive ?? false;

  /// Check if user is staff
  bool get isStaff => _user?.isStaff ?? false;

  /// Check if user is verified
  bool get isVerified => _user?.isVerified ?? false;


}

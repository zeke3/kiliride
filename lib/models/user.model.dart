import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Custom class for Country data
class CountryData {
  final String code;
  final String name;

  CountryData({required this.code, required this.name});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(code: json['code'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name};
  }

  @override
  String toString() => name;
}

// Custom class for Currency data
class CurrencyData {
  final String code;
  final String name;
  final String symbol;

  CurrencyData({required this.code, required this.name, required this.symbol});

  factory CurrencyData.fromJson(Map<String, dynamic> json) {
    return CurrencyData(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'symbol': symbol};
  }

  @override
  String toString() => '$name ($symbol)';
}

class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? avatarURL;
  final String? email;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final String? ageGroup; // New field for age group
  final String? notifToken;
  final String? role;
  final String? userType;
  final DateTime? lastSeen;
  final String? status;
  final String? authType;
  final CurrencyData? currency; // Changed to CurrencyData
  final String? bio;
  final CountryData? country; // Changed to CountryData
  final String? deviceUniqueId;
  final bool? isVerified;
  final int? numberOfPostedJobs;
  final DateTime? dateAdded;
  final DateTime? dateUpdated;
  final List<String>? fcmTokens; // New field for FCM tokens
  final bool isProfileCompleted;
  final bool isActive;
  final bool isStaff;
  final String? clientType;
  final bool
  isProduction; // New field for development/production data differentiation

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.avatarURL,
    this.email,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.ageGroup, // Add ageGroup parameter
    this.bio,
    this.notifToken,
    this.role,
    this.currency,
    this.lastSeen,
    this.status,
    this.country,
    this.userType,
    this.authType,
    this.deviceUniqueId,
    this.isVerified,
    this.numberOfPostedJobs,
    this.dateAdded,
    this.dateUpdated,
    this.fcmTokens,
    this.clientType,
    this.isProfileCompleted = false,
    this.isActive = true,
    this.isStaff = false,
    this.isProduction = false, // Default to false for development
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("DATE ADDED: ${json['dateAdded']}");

    // Handle id conversion - API returns int, but we store as String
    String? idString;
    if (json['id'] != null) {
      idString = json['id'].toString();
    }

    // Convert lastSeen from Timestamp to DateTime
    DateTime? lastSeenDateTime;
    if (json['lastSeen'] != null) {
      if (json['lastSeen'] is Timestamp) {
        lastSeenDateTime = (json['lastSeen'] as Timestamp).toDate();
      } else if (json['lastSeen'] is String) {
        try {
          lastSeenDateTime = DateTime.parse(json['lastSeen']);
        } catch (e) {
          // Invalid date string, leave as null
        }
      }
    }

    // Convert country data
    CountryData? countryData;
    if (json['country'] != null && json['country'] is Map) {
      try {
        countryData = CountryData.fromJson(
          Map<String, dynamic>.from(json['country']),
        );
      } catch (e) {
        print("Error parsing country data: $e");
      }
    }

    // Convert currency data
    CurrencyData? currencyData;
    if (json['currency'] != null && json['currency'] is Map) {
      try {
        currencyData = CurrencyData.fromJson(
          Map<String, dynamic>.from(json['currency']),
        );
      } catch (e) {
        print("Error parsing currency data: $e");
      }
    }

    //Convert dateAdded and dateUpdated from Timestamp to DateTime
    DateTime? dateAdded;
    if (json['dateAdded'] != null) {
      if (json['dateAdded'] is Timestamp) {
        dateAdded = (json['dateAdded'] as Timestamp).toDate();
      } else if (json['dateAdded'] is String) {
        try {
          dateAdded = DateTime.parse(json['dateAdded']);
        } catch (e) {
          // Invalid date string, leave as null
          print("Error parsing dateAdded: $e");
        }
      }
    }
    DateTime? dateUpdated;
    if (json['dateUpdated'] != null) {
      if (json['dateUpdated'] is Timestamp) {
        dateUpdated = (json['dateUpdated'] as Timestamp).toDate();
      } else if (json['dateUpdated'] is String) {
        try {
          dateUpdated = DateTime.parse(json['dateUpdated']);
        } catch (e) {
          // Invalid date string, leave as null
          print("Error parsing dateUpdated: $e");
        }
      }
    }

    // Convert birthDate from Timestamp or String to DateTime
    DateTime? birthDate;
    if (json['birthDate'] != null) {
      if (json['birthDate'] is Timestamp) {
        birthDate = (json['birthDate'] as Timestamp).toDate();
      } else if (json['birthDate'] is String) {
        try {
          birthDate = DateTime.parse(json['birthDate']);
        } catch (e) {
          // Invalid date string, leave as null
          print("Error parsing birth date: $e");
        }
      }
    }

    return UserModel(
      id: idString,
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatarURL: json['avatarURL'] ?? json['avatar_url'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      birthDate: birthDate,
      gender: json['gender'],
      ageGroup: json['ageGroup'] ?? json['age_group'], // Add ageGroup from JSON
      notifToken: json['notifToken'] ?? json['notif_token'],
      role: json['role'] ?? json['group'],
      bio: json['bio'],
      userType: json['user_type'],
      country: countryData,
      currency: currencyData,
      fcmTokens: List<String>.from(json['fcmTokens'] ?? json['fcm_tokens'] ?? []),
      lastSeen: lastSeenDateTime,
      status: json['status'],
      authType: json['authType'] ?? json['auth_type'],
      deviceUniqueId: json['deviceUniqueId'] ?? json['device_unique_id'],
      isVerified: json['isVerified'] ?? json['is_verified'],
      numberOfPostedJobs: json['numberOfPostedJobs']?.toInt() ?? json['number_of_posted_jobs']?.toInt() ?? 0,
      isProfileCompleted: json['isProfileCompleted'] ?? json['is_profile_completed'] ?? json['profile_completed'] ?? false,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      isStaff: json['isStaff'] ?? json['is_staff'] ?? false,
      dateAdded: dateAdded,
      dateUpdated: dateUpdated,
      clientType: json['clientType'] ?? json['client_type'],
      isProduction: json['isProduction'] ?? json['is_production'] ?? false, // Handle isProduction field
    );
  }

  Map<String, dynamic> toJson() {
    // Convert DateTime to Timestamp for Firestore
    Timestamp? lastSeenTimestamp;
    if (lastSeen != null) {
      lastSeenTimestamp = Timestamp.fromDate(lastSeen!);
    }

    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'avatarURL': avatarURL,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'gender': gender,
      'ageGroup': ageGroup, // Add ageGroup to JSON
      'notifToken': notifToken,
      'user_type': userType,
      'role': role,
      'country': country?.toJson(), // Convert CountryData to Map
      'currency': currency?.toJson(), // Convert CurrencyData to Map
      'bio': bio,
      'lastSeen': lastSeenTimestamp,
      'status': status,
      'authType': authType,
      'deviceUniqueId': deviceUniqueId,
      'isVerified': isVerified,
      'numberOfPostedJobs': numberOfPostedJobs,
      'isProfileCompleted': isProfileCompleted,
      'isActive': isActive,
      'isStaff': isStaff,
      'clientType': clientType,
      'dateAdded': dateAdded != null ? Timestamp.fromDate(dateAdded!) : null,
      'dateUpdated': dateUpdated != null
          ? Timestamp.fromDate(dateUpdated!)
          : null,
      'isProduction': isProduction, // Include isProduction field
      'fcmTokens': fcmTokens ?? [], // Ensure fcmTokens is always a list
    };
  }

  // Create a copy of the user model with updated fields
  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? avatarURL,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    String? ageGroup, // Add ageGroup parameter
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
    String? clientType,
    List<String>? fcmTokens, // New field for FCM tokens
    bool? isProduction, // Add isProduction to copyWith
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarURL: avatarURL ?? this.avatarURL,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup, // Add ageGroup to copyWith return
      notifToken: notifToken ?? this.notifToken,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      authType: authType ?? this.authType,
      currency: currency ?? this.currency,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      deviceUniqueId: deviceUniqueId ?? this.deviceUniqueId,
      isVerified: this.isVerified,
      numberOfPostedJobs: this.numberOfPostedJobs,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      dateAdded: this.dateAdded,
      dateUpdated: this.dateUpdated,
      clientType: clientType ?? this.clientType,
      fcmTokens: fcmTokens ?? this.fcmTokens, // Handle fcmTokens
      isProduction: isProduction ?? this.isProduction, // Handle isProduction
    );
  }

  static UserModel createUserFromFirestore(Map<String, dynamic> userData) {
    // Handle the lastSeen Timestamp conversion
    DateTime? lastSeenDateTime;
    if (userData['lastSeen'] != null) {
      if (userData['lastSeen'] is Timestamp) {
        lastSeenDateTime = (userData['lastSeen'] as Timestamp).toDate();
      } else if (userData['lastSeen'] is DateTime) {
        lastSeenDateTime = userData['lastSeen'] as DateTime;
      }
    }

    // Handle country data
    CountryData? countryData;
    if (userData['country'] != null && userData['country'] is Map) {
      try {
        countryData = CountryData.fromJson(
          Map<String, dynamic>.from(userData['country']),
        );
      } catch (e) {
        print("Error parsing country data: $e");
      }
    }

    // Handle currency data
    CurrencyData? currencyData;
    if (userData['currency'] != null && userData['currency'] is Map) {
      try {
        currencyData = CurrencyData.fromJson(
          Map<String, dynamic>.from(userData['currency']),
        );
      } catch (e) {
        print("Error parsing currency data: $e");
      }
    }

    //Handle dateAdded and dateUpdated
    DateTime? dateAdded;
    if (userData['dateAdded'] != null) {
      if (userData['dateAdded'] is Timestamp) {
        dateAdded = (userData['dateAdded'] as Timestamp).toDate();
      } else if (userData['dateAdded'] is DateTime) {
        dateAdded = userData['dateAdded'] as DateTime;
      }
    }
    DateTime? dateUpdated;
    if (userData['dateUpdated'] != null) {
      if (userData['dateUpdated'] is Timestamp) {
        dateUpdated = (userData['dateUpdated'] as Timestamp).toDate();
      } else if (userData['dateUpdated'] is DateTime) {
        dateUpdated = userData['dateUpdated'] as DateTime;
      }
    }

    //Handle birthDate conversion
    DateTime? birthDate;
    if (userData['birthDate'] != null) {
      if (userData['birthDate'] is Timestamp) {
        birthDate = (userData['birthDate'] as Timestamp).toDate();
      } else if (userData['birthDate'] is DateTime) {
        birthDate = userData['birthDate'] as DateTime;
      } else if (userData['birthDate'] is String) {
        try {
          birthDate = DateTime.parse(userData['birthDate']);
        } catch (e) {
          print("Error parsing birth date: $e");
        }
      }
    }

    return UserModel(
      id: userData['id'],
      firstName: userData['first_name'],
      lastName: userData['last_name'],
      gender: userData['gender'],
      ageGroup: userData['ageGroup'], // Add ageGroup from Firestore
      email: userData['email'],
      birthDate: birthDate,
      bio: userData['bio'],
      phoneNumber: userData['phoneNumber'],
      avatarURL: userData['avatarURL'],
      country: countryData,
      notifToken: userData['notifToken'],
      role: userData['role'],
      userType: userData['userType'],
      lastSeen: lastSeenDateTime,
      status: userData['status'],
      authType: userData['authType'],
      deviceUniqueId: userData['deviceUniqueId'],
      isProfileCompleted: userData['isProfileCompleted'] ?? false,
      isActive: userData['isActive'] ?? true,
      isStaff: userData['isStaff'] ?? false,
      currency: currencyData,
      isVerified: userData['isVerified'] ?? false,
      numberOfPostedJobs: userData['numberOfPostedJobs'] ?? 0,
      dateAdded: dateAdded,
      dateUpdated: dateUpdated,
      fcmTokens: List<String>.from(userData['fcmTokens'] ?? []),
      isProduction:
          userData['isProduction'] ?? false, // Handle isProduction field
    );
  }

  // Format lastSeen in social media style
  String formatLastSeen() {
    if (lastSeen == null) return "last seen unknown";

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    // Get midnight times for comparisons
    final midnight = DateTime(now.year, now.month, now.day);
    final yesterdayMidnight = midnight.subtract(const Duration(days: 1));
    final weekAgo = now.subtract(const Duration(days: 7));
    final yearStart = DateTime(now.year, 1, 1);

    // Formatters
    final timeFormat = DateFormat('h:mm a'); // e.g. 3:45 PM
    final dateFormat = DateFormat('MMM d'); // e.g. Jan 15
    final fullDateFormat = DateFormat('MMM d, y'); // e.g. Jan 15, 2023

    // Active now / Just now (less than a minute ago)
    if (difference.inSeconds < 60) {
      return "online";
    }

    // Minutes ago (less than an hour)
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return "last seen ${minutes == 1 ? 'a minute' : '$minutes minutes'} ago";
    }

    // Hours ago (less than 4 hours)
    if (difference.inHours < 4) {
      final hours = difference.inHours;
      return "last seen ${hours == 1 ? 'an hour' : '$hours hours'} ago";
    }

    // Today
    if (lastSeen!.isAfter(midnight)) {
      return "last seen today at ${timeFormat.format(lastSeen!)}";
    }

    // Yesterday
    if (lastSeen!.isAfter(yesterdayMidnight)) {
      return "last seen yesterday at ${timeFormat.format(lastSeen!)}";
    }

    // Within last week
    if (lastSeen!.isAfter(weekAgo)) {
      return "last seen on ${DateFormat('EEEE').format(lastSeen!)} at ${timeFormat.format(lastSeen!)}";
    }

    // This year
    if (lastSeen!.isAfter(yearStart)) {
      return "last seen on ${dateFormat.format(lastSeen!)}";
    }

    // Previous years
    return "last seen on ${fullDateFormat.format(lastSeen!)}";
  }

  //Date since user joined
  String dateSinceJoined() {
    if (dateAdded == null) return "Joined unknown";

    final now = DateTime.now();
    final difference = now.difference(dateAdded!);

    if (difference.inDays < 1) {
      return "Joined today";
    } else if (difference.inDays == 1) {
      return "Joined yesterday";
    } else if (difference.inDays < 30) {
      return "Joined ${difference.inDays} days ago";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "Joined $months month${months > 1 ? 's' : ''} ago";
    } else {
      final years = (difference.inDays / 365).floor();
      return "Joined $years year${years > 1 ? 's' : ''} ago";
    }
  }

  //Give me a function which I will pass the datetime of userJoined and it will return a string like "Member since Jan 15, 2023"
  String memberSince(DateTime userJoined) {
    final dateFormat = DateFormat('MMM d, y'); // e.g. Jan 15, 2023
    return "Member since ${dateFormat.format(userJoined)}";
  }
}

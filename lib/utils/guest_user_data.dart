/// Simple utility to provide guest user data
/// This provides a consistent way to handle guest mode across the app
class GuestUserData {
  static final Map<String, dynamic> _guestData = {
    'uid': 'guest_user',
    'fullName': 'Guest User',
    'avatarURL': null,
    'email': 'guest@example.com',
    'role': 'Guest',
    'status': 'Active',
  };

  /// Gets guest user data as a map
  static Map<String, dynamic> get data => Map.from(_guestData);

  /// Gets a specific field from guest data
  static dynamic get(String field) => _guestData[field];

  /// Checks if guest data contains a field
  static bool containsKey(String field) => _guestData.containsKey(field);
}

/// Wrapper class to make Map<String, dynamic> behave like DocumentSnapshot
/// This helps avoid type casting errors when using guest mode data
class GuestUserDataWrapper {
  final Map<String, dynamic> _data;

  GuestUserDataWrapper(this._data);

  /// Get the underlying data map
  Map<String, dynamic> data() => _data;

  /// Get a field value from the data
  dynamic get(String field) => _data[field];

  /// Array access operator to mimic DocumentSnapshot behavior
  dynamic operator [](String key) => _data[key];

  /// Check if the document exists (always true for guest data)
  bool get exists => true;

  /// Get the document ID
  String get id => _data['uid'] ?? _data['id'] ?? 'guest_user';

  /// Get reference (not applicable for guest data, returns null)
  dynamic get reference => null;
}

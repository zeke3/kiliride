import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentifier {
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();
  final String _key = 'deviceUUID'; // Key to store the UUID in secure storage

  // Function to get the UUID (generate it if it's not present)
  Future<String> getDeviceUUID() async {
    // Try to read the stored UUID
    String? storedUUID = await _storage.read(key: _key);

    // If it's not present, generate a new one and store it
    if (storedUUID == null) {
      String newUUID = _uuid.v4(); // Generate a new UUID
      await _storage.write(key: _key, value: newUUID);
      return newUUID;
    } else {
      return storedUUID;
    }
  }
}

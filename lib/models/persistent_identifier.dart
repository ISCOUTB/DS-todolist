import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PersistentIdentifier {
  static const String _keyDeviceId = 'device_id';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);

    if (deviceId == null) {
      // Genera un nuevo UUID si no existe
      deviceId = const Uuid().v4();
      await prefs.setString(_keyDeviceId, deviceId);
    }

    return deviceId;
  }
}

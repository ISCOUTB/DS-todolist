import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PersistentIdentifier {
  static const String _keyDeviceId = 'device_id';

  static Future<String> Function({FirebaseAuth? auth}) getDeviceId =
      _getDeviceId;

  static Future<String> _getDeviceId({FirebaseAuth? auth}) async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);

    final user = (auth ?? FirebaseAuth.instance).currentUser;

    if (user != null) {
      // Si ya tiene un ID de Firebase, úsalo
      if (deviceId != null && deviceId.startsWith('Fire-')) {
        return deviceId;
      }
      // Si no, genera uno con prefijo Fire-
      String base = user.displayName ?? user.email ?? '';
      base = base.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      final nuevoId = 'Fire-$base${user.uid}';
      await prefs.setString(_keyDeviceId, nuevoId);
      return nuevoId;
    }

    // Si no hay usuario, usa UUID
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_keyDeviceId, deviceId);
    }
    return deviceId;
  }
}

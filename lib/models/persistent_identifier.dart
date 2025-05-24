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

    // Verifica si hay usuario autenticado en Firebase
    final user = (auth ?? FirebaseAuth.instance).currentUser;

    if (user != null) {
      // Toma las primeras 4 letras del displayName o email
      String base = user.displayName ?? user.email ?? '';
      base = base.replaceAll(RegExp(r'[^a-zA-Z]'), ''); // Solo letras
      if (base.length > 4) {
        base = base.substring(0, 4);
      }
      // Usa el UID de Firebase
      deviceId = 'Fire-$base${user.uid}';
      await prefs.setString(_keyDeviceId, deviceId);
      return deviceId;
    }

    // Si no hay usuario, usa UUID como antes
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_keyDeviceId, deviceId);
    }

    return deviceId;
  }
}

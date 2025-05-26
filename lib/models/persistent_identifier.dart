import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      if (deviceId != null && deviceId.startsWith('Fire-')) {
        // Si el ID ya es de Firebase, no lo cambiamos
        return deviceId;
      }

      final migrado = await migrarDatos(user);
      if (migrado) {
        // Leer el nuevo ID guardado tras la migración
        deviceId = prefs.getString(_keyDeviceId);
        return deviceId!;
      } else {
        // Si no se pudo migrar, genera un nuevo UUID
        deviceId = const Uuid().v4();
        await prefs.setString(_keyDeviceId, deviceId);
        return deviceId;
      }
    }

    // Si no hay usuario, usa UUID como antes
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_keyDeviceId, deviceId);
    }

    return deviceId;
  }

  static Future<bool> migrarDatos(user) async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener el ID actual (que podría ser antiguo o nuevo)
    String? idGuardado = prefs.getString(_keyDeviceId);

    // Verificar si ya es un ID de Firebase
    if (user == null || idGuardado == null || idGuardado.startsWith('Fire-')) {
      return false; // No migrar si no hay usuario o ya migrado
    }

    // Generar nuevo ID con prefijo Fire-
    String base = user.displayName ?? user.email ?? '';
    base = base.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (base.length > 4) {
      base = base.substring(0, 4);
    }
    final nuevoId = 'Fire-$base${user.uid}';

    // Enviar solicitud al servidor para migrar
    final url = Uri.parse('http://miapiservice.sytes.net:5000/unir_archivos');
    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'origen': idGuardado, 'destino': nuevoId}),
      );

      if (respuesta.statusCode == 200) {
        debugPrint('Migración exitosa: ${respuesta.body}');
        // Guardar nuevo ID en prefs
        await prefs.setString(_keyDeviceId, nuevoId);

        return true;
      } else {
        debugPrint(
          'Error en la migración: ${respuesta.statusCode} - ${respuesta.body}',
        );
      }
    } catch (e) {
      debugPrint('Error al conectar con el servidor: $e');
    }

    return false;
  }
}

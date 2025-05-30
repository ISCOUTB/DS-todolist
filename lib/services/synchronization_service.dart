import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/services/hive_storage.dart';
import 'package:to_do_list/services/api_storage.dart';
import 'package:to_do_list/models/persistent_identifier.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/services/task_notifier.dart';

class SynchronizationService {
  late final HiveStorage hiveStorage;
  late final ApiStorage apiStorage;
  Timer? syncTimer;

  /// Constructor que permite inyectar dependencias para pruebas unitarias
  /// y para usar diferentes estrategias de almacenamiento.
  SynchronizationService({HiveStorage? hiveStorage, ApiStorage? apiStorage})
    : hiveStorage = hiveStorage ?? HiveStorage(),
      apiStorage = apiStorage ?? ApiStorage();

  /// Llama esto al iniciar la app o al iniciar sesión
  Future<void> initialize({TaskNotifier? notifier, User? user}) async {
    user ??= FirebaseAuth.instance.currentUser;

    if (kIsWeb) {
      // WEB: Siempre usa API. Si no hay usuario, usa UUID; si hay usuario, usa Fire-<usuario>.
      await sincronizarWeb(user);
    } else {
      // MÓVIL: Usa Hive local y sincroniza con API cada hora si hay usuario.
      await sincronizarMovil(user);
      if (user != null) {
        startMobileSync();
      }
    }
    notifier?.loadTasks();
  }

  Future<bool> migrarDatosWeb(User user) async {
    final prefs = await SharedPreferences.getInstance();
    String? idGuardado = prefs.getString('device_id');

    // Verificar si ya es un ID de Firebase
    if (idGuardado == null || idGuardado.startsWith('Fire-')) {
      return false;
    }

    // Generar nuevo ID con prefijo Fire-
    String base = user.displayName ?? user.email ?? '';
    base = base.replaceAll(RegExp(r'[^a-zA-Z]'), '');
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
        // Guardar nuevo ID en prefs
        await prefs.setString('device_id', nuevoId);
        return true;
      }
    } catch (e) {
      // Puedes loggear el error si lo deseas
    }
    return false;
  }

  /// WEB: Fusiona datos del API con los actuales cada vez que inicia sesión
  Future<void> sincronizarWeb(User? user) async {
    // Si hay usuario, intenta migrar datos
    if (user != null) {
      await migrarDatosWeb(user);
    }
    // Cambia el identificador si hay usuario
    await PersistentIdentifier.getDeviceId(auth: FirebaseAuth.instance);
  }

  /// MÓVIL: Fusiona datos del API con Hive cada vez que inicia sesión
  Future<void> sincronizarMovil(User? user) async {
    if (user != null) {
      final apiTasks = await apiStorage.leerTareas();
      final localTasks = await hiveStorage.leerTareas();

      // Fusiona evitando duplicados por id
      final allTasks =
          {
            ...{for (var t in localTasks) t.id: t},
            ...{for (var t in apiTasks) t.id: t},
          }.values.toList();

      // Guarda la fusión localmente
      for (final task in allTasks) {
        await hiveStorage.guardarTarea(task);
      }
    }
  }

  /// MÓVIL: Cada hora sube los datos locales al API si hay usuario
  void startMobileSync() {
    syncTimer?.cancel();
    syncTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final localTasks = await hiveStorage.leerTareas();
        for (final task in localTasks) {
          await apiStorage.guardarTarea(task);
        }
      }
    });
  }

  void dispose() {
    syncTimer?.cancel();
  }
}

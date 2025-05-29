import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/services/api_storage.dart';
import 'package:to_do_list/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/models/persistent_identifier.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    PersistentIdentifier.getDeviceId = ({auth}) async => 'test-uuid';
  });

  group('ApiStorage', () {
    late ApiStorage apiStorage;

    setUp(() {
      apiStorage = ApiStorage();
    });

    test('guardarTarea no lanza excepción', () async {
      final task = Task(
        id: '1',
        title: 'Test',
        description: 'desc',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat',
      );
      await apiStorage.guardarTarea(task);
    });

    test('leerTareas retorna lista vacía si hay error', () async {
      final result = await apiStorage.leerTareas();
      expect(result, isA<List<Task>>());
      expect(result, isEmpty);
    });

    test('eliminarTarea retorna false si hay error', () async {
      final result = await apiStorage.eliminarTarea('1');
      expect(result, isFalse);
    });

    test('agregarCategoria retorna false si hay error', () async {
      final result = await apiStorage.agregarCategoria('Nueva');
      expect(result, isFalse);
    });

    test('leerCategorias retorna lista vacía si hay error', () async {
      final result = await apiStorage.leerCategorias();
      expect(result, isA<List<String>>());
      expect(result, isEmpty);
    });

    test('eliminarCategoria retorna false si hay error', () async {
      final result = await apiStorage.eliminarCategoria('cat');
      expect(result, isFalse);
    });

    test('editarTarea retorna false si hay error', () async {
      final task = Task(
        id: '1',
        title: 'Test',
        description: 'desc',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat',
      );
      final result = await apiStorage.editarTarea(task);
      expect(result, isFalse);
    });

    test('leerCategoriasFiltradas retorna lista vacía si hay error', () async {
      final result = await apiStorage.leerCategoriasFiltradas('cat');
      expect(result, isA<List<Task>>());
      expect(result, isEmpty);
    });

    test('getTasksPerDay retorna mapa vacío si hay error', () async {
      final result = await apiStorage.getTasksPerDay();
      expect(result, isA<Map<DateTime, int>>());
      expect(result, isEmpty);
    });

    // --- Cobertura de casos de éxito usando MockClient ---

    test('guardarTarea retorna éxito (mock)', () async {
      final task = Task(
        id: '2',
        title: 'Mock',
        description: 'desc',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat',
      );
      final api = ApiStorageMock(http.Client());
      api.mockPostResponse = http.Response('{}', 200);
      await api.guardarTarea(task);
    });

    test('leerTareas retorna lista de tareas (mock)', () async {
      final api = ApiStorageMock(http.Client());
      api.mockGetResponse = http.Response(
        jsonEncode({
          'tasks': [
            {
              'id': '1',
              'title': 'Tarea',
              'description': 'desc',
              'dueDate': DateTime.now().toIso8601String(),
              'completed': false,
              'createdAt': DateTime.now().toIso8601String(),
              'category': 'cat',
            },
          ],
        }),
        200,
      );
      final result = await api.leerTareas();
      expect(result, isA<List<Task>>());
      expect(result, isNotEmpty);
    });

    test('eliminarTarea retorna true (mock)', () async {
      final api = ApiStorageMock(http.Client());
      api.mockDeleteResponse = http.Response('', 200);
      final result = await api.eliminarTarea('1');
      expect(result, isTrue);
    });

    test('eliminarCategoria retorna true (mock)', () async {
      final api = ApiStorageMock(http.Client());
      api.mockDeleteResponse = http.Response('', 200);
      final result = await api.eliminarCategoria('cat');
      expect(result, isTrue);
    });

    test('agregarCategoria retorna true (mock)', () async {
      final api = ApiStorageMock(http.Client());
      api.mockPostResponse = http.Response('', 200);
      final result = await api.agregarCategoria('Nueva');
      expect(result, isTrue);
    });

    test('leerCategorias retorna lista (mock)', () async {
      final api = ApiStorageMock(http.Client());
      api.mockGetResponse = http.Response(
        jsonEncode([
          {'name': 'cat1'},
          {'name': 'cat2'},
        ]),
        200,
      );
      final result = await api.leerCategorias();
      expect(result, contains('cat1'));
      expect(result, contains('cat2'));
    });

    test('editarTarea retorna true (mock)', () async {
      final api = ApiStorageMock(http.Client());
      api.mockDeleteResponse = http.Response('', 200);
      api.mockPostResponse = http.Response('', 200);
      final task = Task(
        id: '1',
        title: 'Edit',
        description: 'desc',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat',
      );
      final result = await api.editarTarea(task);
      expect(result, isTrue);
    });

    test('leerCategoriasFiltradas retorna lista (mock)', () async {
      final api = ApiStorageMock(http.Client());
      api.mockGetResponse = http.Response(
        jsonEncode([
          {
            'id': '1',
            'title': 'Tarea',
            'description': 'desc',
            'dueDate': DateTime.now().toIso8601String(),
            'completed': false,
            'createdAt': DateTime.now().toIso8601String(),
            'category': 'cat',
          },
        ]),
        200,
      );
      final result = await api.leerCategoriasFiltradas('cat');
      expect(result, isA<List<Task>>());
      expect(result, isNotEmpty);
    });

    test('getTasksPerDay retorna mapa con datos (mock)', () async {
      final api = ApiStorageMock(http.Client());
      final now = DateTime.now();
      api.mockGetResponse = http.Response(
        jsonEncode({
          'tasks': [
            {
              'id': '1',
              'title': 'Tarea',
              'description': 'desc',
              'dueDate': now.toIso8601String(),
              'completed': false,
              'createdAt': now.toIso8601String(),
              'category': 'cat',
            },
          ],
        }),
        200,
      );
      final result = await api.getTasksPerDay();
      expect(result, isA<Map<DateTime, int>>());
      expect(result.values.first, equals(1));
    });
  });
}

// Mock de ApiStorage para inyectar respuestas HTTP
class ApiStorageMock extends ApiStorage {
  http.Response? mockGetResponse;
  http.Response? mockPostResponse;
  http.Response? mockDeleteResponse;
  final http.Client _client;

  get client => _client;

  ApiStorageMock(this._client);

  Future<http.Response> _get(Uri url) async {
    return mockGetResponse ?? http.Response('[]', 404);
  }

  Future<http.Response> _post(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    return mockPostResponse ?? http.Response('{}', 404);
  }

  Future<http.Response> _delete(Uri url) async {
    return mockDeleteResponse ?? http.Response('', 404);
  }

  // Sobrescribe los métodos de la superclase para usar los mocks
  @override
  Future<List<Task>> leerTareas() async {
    final uuid = await PersistentIdentifier.getDeviceId();
    final url = Uri.parse('$baseUrl/leer_json/$uuid');
    try {
      final respuesta = await _get(url);
      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        return (data['tasks'] as List)
            .map((task) => Task.fromJson(task))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> guardarTarea(Task task) async {
    final uuid = await PersistentIdentifier.getDeviceId();
    final url = Uri.parse('$baseUrl/guardar_json/$uuid');
    try {
      await _post(
        url,
        body: jsonEncode({'datos': task.toJson()}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (_) {}
  }

  @override
  Future<bool> eliminarTarea(String tareaId) async {
    final uuid = await PersistentIdentifier.getDeviceId();
    final url = Uri.parse('$baseUrl/eliminar_tarea/$uuid/$tareaId');
    try {
      final respuesta = await _delete(url);
      return respuesta.statusCode == 200;
    } catch (_) {}
    return false;
  }

  @override
  Future<bool> eliminarCategoria(String categoriaNombre) async {
    final uuid = await PersistentIdentifier.getDeviceId();
    final url = Uri.parse('$baseUrl/eliminar_categoria/$uuid/$categoriaNombre');
    try {
      final respuesta = await _delete(url);
      return respuesta.statusCode == 200;
    } catch (_) {}
    return false;
  }

  @override
  Future<bool> agregarCategoria(String categoriaNombre) async {
    final uuid = await PersistentIdentifier.getDeviceId();
    final url = Uri.parse('$baseUrl/agregar_categoria/$uuid');
    try {
      final respuesta = await _post(
        url,
        body: jsonEncode({"name": categoriaNombre}),
        headers: {'Content-Type': 'application/json'},
      );
      return respuesta.statusCode == 200;
    } catch (_) {}
    return false;
  }

  @override
  Future<List<String>> leerCategorias() async {
    final uuid = await PersistentIdentifier.getDeviceId();
    final url = Uri.parse('$baseUrl/leer_categorias/$uuid');
    try {
      final respuesta = await _get(url);
      if (respuesta.statusCode == 200) {
        final List<dynamic> data = jsonDecode(respuesta.body);
        return data.map((item) => item['name'] as String).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria) async {
    final uuid = await PersistentIdentifier.getDeviceId();
    final url = Uri.parse('$baseUrl/buscar_categoria/$uuid/$nombreCategoria');
    try {
      final respuesta = await _get(url);
      if (respuesta.statusCode == 200) {
        final decodedData = jsonDecode(respuesta.body);
        if (decodedData is List) {
          return decodedData.map((task) => Task.fromJson(task)).toList();
        } else if (decodedData is Map<String, dynamic> &&
            decodedData['tasks'] is List) {
          return (decodedData['tasks'] as List)
              .map((task) => Task.fromJson(task))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }
}

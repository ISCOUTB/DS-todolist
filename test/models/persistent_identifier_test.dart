import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/models/persistent_identifier.dart';

// Mock User
class MockUser implements User {
  @override
  String get uid => '12345';
  @override
  String? get displayName => 'TestUser';
  @override
  String? get email => 'test@email.com';
  // Implement other members as needed with throw UnimplementedError()
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock FirebaseAuth
class MockFirebaseAuth implements FirebaseAuth {
  final User? _user;
  MockFirebaseAuth([this._user]);
  @override
  User? get currentUser => _user;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersistentIdentifier (API fake connection)', () {
    final user = MockUser();
    final auth = MockFirebaseAuth(user);

    test('getDeviceId returns existing deviceId if no user', () async {
      SharedPreferences.setMockInitialValues({'device_id': 'device-uuid'});
      final id = await PersistentIdentifier.getDeviceId(
        auth: MockFirebaseAuth(null),
      );
      expect(id, 'device-uuid');
    });

    test(
      'getDeviceId generates new deviceId if none exists and no user',
      () async {
        SharedPreferences.setMockInitialValues({});
        final id = await PersistentIdentifier.getDeviceId(
          auth: MockFirebaseAuth(null),
        );
        expect(id, isNotNull);
        expect(id, isNotEmpty);
      },
    );

    test('getDeviceId returns deviceId if already migrated', () async {
      SharedPreferences.setMockInitialValues({'device_id': 'Fire-Test12345'});
      final id = await PersistentIdentifier.getDeviceId(auth: auth);
      expect(id, 'Fire-Test12345');
    });

    test('migrarDatos returns false if user is null', () async {
      SharedPreferences.setMockInitialValues({'device_id': 'old-id'});
      final result = await PersistentIdentifier.migrarDatos(null);
      expect(result, false);
    });

    test('migrarDatos returns false if idGuardado is null', () async {
      SharedPreferences.setMockInitialValues({});
      final result = await PersistentIdentifier.migrarDatos(user);
      expect(result, false);
    });

    test('migrarDatos returns false if already migrated', () async {
      SharedPreferences.setMockInitialValues({'device_id': 'Fire-Test12345'});
      final result = await PersistentIdentifier.migrarDatos(user);
      expect(result, false);
    });
  });
}

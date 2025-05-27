import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:to_do_list/models/task.dart';

class FakeBinaryReader extends BinaryReader {
  final List<dynamic> _values;
  int _index = 0;

  FakeBinaryReader(this._values) : super();

  @override
  dynamic read([int? offset]) => _values[_index++];

  @override
  int readByte() => _values[_index++];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('TaskAdapter', () {
    test('read() deserializa correctamente', () {
      final adapter = TaskAdapter();
      final now = DateTime.now();

      // Simula los valores que leería Hive: numOfFields, fieldId, value, ...
      final fakeReader = FakeBinaryReader([
        7, // numOfFields
        0, 'id1',
        1, 'title1',
        2, 'desc1',
        3, now,
        4, true,
        5, now,
        6, 'cat1',
      ]);

      final task = adapter.read(fakeReader);

      expect(task.id, 'id1');
      expect(task.title, 'title1');
      expect(task.description, 'desc1');
      expect(task.dueDate, now);
      expect(task.completed, true);
      expect(task.createdAt, now);
      expect(task.category, 'cat1');
    });

    test('hashCode y == funcionan correctamente', () {
      final adapter1 = TaskAdapter();
      final adapter2 = TaskAdapter();

      expect(adapter1, equals(adapter2));
      expect(adapter1.hashCode, adapter2.hashCode);
      expect(adapter1 == adapter2, isTrue);
      expect(adapter1 == Object(), isFalse);
    });
  });
}

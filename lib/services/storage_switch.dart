import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/storage_strategy.dart';

class StorageSwitch {
  late StorageStrategy _strategy;

  StorageSwitch(StorageStrategy strategy) {
    _strategy = strategy;
  }

  void setStrategy(StorageStrategy strategy) {
    _strategy = strategy;
  }

  Future<void> guardarTarea(task) async {
    await _strategy.guardarTarea(task);
  }

  Future<List<Task>> leerTareas() async {
    return await _strategy.leerTareas();
  }

  Future<void> eliminarTarea(String idtarea) async {
    await _strategy.eliminarTarea(idtarea);
  }
}

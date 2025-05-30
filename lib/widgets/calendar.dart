import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/models/task.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime today = DateTime.now();
  Map<DateTime, int> tasksPerDay = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_CO');
    _loadTasksPerDay();
  }

  Future<void> _loadTasksPerDay() async {
    final storage = Provider.of<TaskNotifier>(context, listen: false);
    await storage.loadTasks(); // Asegura que haya tareas cargadas
    final tareas = storage.tasks;

    Map<DateTime, int> conteo = {};
    for (var task in tareas) {
      if (task.dueDate != null) {
        final date = DateTime.utc(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        conteo[date] = (conteo[date] ?? 0) + 1;
      }
    }

    setState(() {
      tasksPerDay = conteo;
    });
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  List<Task> _getTasksForDay(List<Task> allTasks, DateTime day) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == day.year &&
          task.dueDate!.month == day.month &&
          task.dueDate!.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskNotifier = Provider.of<TaskNotifier>(context);
    final tareasDelDia = _getTasksForDay(taskNotifier.tasks, today);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TableCalendar(
            locale: "es_CO",
            rowHeight: 45,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              headerPadding: const EdgeInsets.only(bottom: 10),
              headerMargin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1.5),
                ),
              ),
            ),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            onDaySelected: _onDaySelected,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final normalizedDay = DateTime.utc(
                  day.year,
                  day.month,
                  day.day,
                );
                final tasks = tasksPerDay[normalizedDay] ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Text('${day.day}'),
                    if (tasks > 0)
                      Positioned(
                        bottom: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                              '$tasks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                tareasDelDia.isEmpty
                    ? const Center(child: Text('No hay tareas para este día.'))
                    : ListView.builder(
                      itemCount: tareasDelDia.length,
                      itemBuilder: (context, index) {
                        final task = tareasDelDia[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Text(task.description),
                            trailing: IconButton(
                              icon: Icon(
                                task.completed
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color:
                                    task.completed ? Colors.green : Colors.grey,
                              ),
                              onPressed: () {
                                final taskNotifier = Provider.of<TaskNotifier>(
                                  context,
                                  listen: false,
                                );
                                taskNotifier.toggleTaskCompletion(
                                  task.id,
                                  !task.completed,
                                );
                              },
                              tooltip:
                                  task.completed
                                      ? 'Marcar como pendiente'
                                      : 'Marcar como completada',
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for locale initialization
import 'package:to_do_list/services/data_manager.dart';

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
    initializeDateFormatting('es_CO'); // Initialize locale data
    _loadTasksPerDay();
  }

  Future<void> _loadTasksPerDay() async {
    final tasks = await DataManager.getTasksPerDay();
    setState(() {
    });

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            // Prevent overflow by constraining the widget
            child: SingleChildScrollView(
              child: TableCalendar(
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
                                    color: const Color.fromARGB(255, 0, 0, 0),
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
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:to_do_list/components/add_task_button.dart';
import 'package:to_do_list/components/search_textfield.dart';
import 'package:to_do_list/components/user_button.dart';
import 'package:to_do_list/components/sorter_button.dart';
import 'package:to_do_list/widgets/calendar.dart';
import 'package:to_do_list/widgets/drawer_widget.dart';
import 'package:to_do_list/widgets/responsive_widget.dart';
import 'package:to_do_list/widgets/task_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Índice de la vista seleccionada
  bool _isDesktop = false; // Estado para rastrear si estamos en escritorio

  final List<Widget> _views = [
    ResponsiveWidget(
      mobileLayout: buildMobileLayout(),
      tabletLayout: buildTabletLayout(),
      desktopLayout: buildDesktopLayout(),
    ),
    Calendar(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWidget.isDesktop(context);

    // Detecta el cambio a la vista de escritorio
    if (isDesktop && !_isDesktop) {
      setState(() {
        _isDesktop = true;
        _currentIndex = 0; // Cambia automáticamente a la vista principal
      });
    } else if (!isDesktop && _isDesktop) {
      setState(() {
        _isDesktop = false;
      });
    }

    final isMobile = ResponsiveWidget.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: SearchTextfield(),
        actions: const [SorterButton(), UserButton()],
      ),
      drawer: isMobile ? const Drawer(child: DrawerWidget()) : null,
      body: _views[_currentIndex],
      floatingActionButton:
          _currentIndex == 0
              ? const AddTaskButton() // Solo muestra el botón en la vista de tareas
              : null,
      bottomNavigationBar:
          !isDesktop
              ? BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: "Tareas",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_rounded),
                    label: "Calendario",
                  ),
                ],
              )
              : null,
    );
  }
}

Widget buildMobileLayout() =>
    Container(color: Colors.white, child: Center(child: TaskWidget()));

Widget buildTabletLayout() => Row(
  children: [
    Expanded(flex: 2, child: DrawerWidget()),
    Expanded(flex: 5, child: TaskWidget()),
  ],
);

Widget buildDesktopLayout() => Row(
  children: [
    Expanded(flex: 2, child: DrawerWidget()),
    Expanded(flex: 5, child: TaskWidget()),
    Expanded(flex: 4, child: Calendar()),
  ],
);

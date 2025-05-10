import 'package:flutter/material.dart';
import 'package:to_do_list/components/add_task_button.dart';
import 'package:to_do_list/components/search_textfield.dart';
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

  final List<Widget> _views = [
    ResponsiveWidget(
      mobileLayout: BuildMobileLayout(),
      tabletLayout: BuildTabletLayout(),
      desktopLayout: BuildDesktopLayout(),
    ),
    Calendar(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWidget.isMobile(context);
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: SearchTextfield(),
        actions: [
          AddTaskButton(),
        ],
      ),
      drawer: isMobile ? const Drawer(child: DrawerWidget()) : null,
      body: _views[_currentIndex],
      bottomNavigationBar:
          !isDesktop
              ? BottomNavigationBar(
                currentIndex: _currentIndex, // Índice actual
                onTap: (index) {
                  setState(() {
                    _currentIndex =
                        index; // Cambia la vista al seleccionar una pestaña
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

Widget BuildMobileLayout() =>
    Container(color: Colors.white, child: Center(child: TaskWidget()));

Widget BuildTabletLayout() => Row(
  children: [
    Expanded(flex: 2, child: DrawerWidget()),
    Expanded(flex: 5, child: TaskWidget()),
  ],
);

Widget BuildDesktopLayout() => Row(
  children: [
    Expanded(flex: 2, child: DrawerWidget()),
    Expanded(flex: 5, child: TaskWidget()),
    Expanded(flex: 4, child: Calendar()),
  ],
);

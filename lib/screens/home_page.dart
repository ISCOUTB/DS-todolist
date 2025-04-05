import 'dart:math';

import 'package:flutter/material.dart';
import 'package:to_do_list/widgets/drawer_widget.dart';
import 'package:to_do_list/widgets/responsive_widget.dart';
import 'package:to_do_list/widgets/task_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context){ 
    final isMobile = ResponsiveWidget.isMobile(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("TODO List"),
      ),
      drawer: isMobile ? const Drawer(child: DrawerWidget(),) : null,
      body: ResponsiveWidget(
        mobileLayout: BuildMobileLayout(), 
        tabletLayout: BuildTabletLayout(),
        desktopLayout: BuildDesktopLayout()
      ),
    ); 
  }
}

Widget BuildMobileLayout() => Container(
  color: Colors.white,
  child: Center(
    child: TaskWidget(),
  ),
);

Widget BuildTabletLayout() => Row(
  children: [
    Expanded(
      flex: 2,
      child: DrawerWidget()
    ),
    Expanded(
      flex: 5,
      child: TaskWidget(),
      ),
  ],
);

Widget BuildDesktopLayout() => Row(
  children: [
    Expanded(
      flex: 2,
      child: DrawerWidget()
    ),
    Expanded(
      flex: 5,
      child: TaskWidget(),
      ),
  ],
);

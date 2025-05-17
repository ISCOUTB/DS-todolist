import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/firebase_options.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/screens/home_page.dart';
import 'package:to_do_list/services/notification_service.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter(); // Inicializa Hive
  Hive.registerAdapter(TaskAdapter());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  NotificationService().initNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskNotifier()..loadTasks()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

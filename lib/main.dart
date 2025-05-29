import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/firebase_options.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/screens/home_page.dart';
import 'package:to_do_list/services/notification_service.dart';
import 'package:to_do_list/services/synchronization_service.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/theme/app_theme.dart'; // importa tu tema personalizado
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter(); // Inicializa Hive
  Hive.registerAdapter(TaskAdapter());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  await NotificationService().initNotification();
  // Removed SynchronizationService().initialize from here because context is not available
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskNotifier()..loadTasks()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize synchronization service here, where context is available
    Future.microtask(() {
      if (!mounted) return; // Chequeo inmediato tras el await

      final notifier = Provider.of<TaskNotifier>(context, listen: false);
      SynchronizationService().initialize(notifier: notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}

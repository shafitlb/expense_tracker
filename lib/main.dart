import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_expense_tracker/domain/models/expense_model.dart';

import 'presentation/screens/home.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)){
    Hive.registerAdapter(ExpenseModelAdapter());
  }

  runApp(const MyApp());
}

Future<void> initializeNotifications() async {
  // Initialize the timezone data
  tz.initializeTimeZones();

  // Initialize local notifications plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
     
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}



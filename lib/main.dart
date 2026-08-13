import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/reminder_provider.dart';
import 'providers/user_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();


  runApp(const SchoolFeesReminderApp());
}

class SchoolFeesReminderApp extends StatelessWidget {
  const SchoolFeesReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderProvider()..loadReminders()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadProfile()),
      ],
      child: MaterialApp(
        title: 'School Fees Reminder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.pink[800],
          // colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF033798)),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

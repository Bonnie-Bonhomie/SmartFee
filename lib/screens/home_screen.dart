import 'package:flutter/material.dart';
import 'package:smart_fee/services/notification_service.dart';
import 'upcoming_reminders_screen.dart';
import 'reminder_history_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'add_edit_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    UpcomingRemindersScreen(),
    ReminderHistoryScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  final _titles = const [
    'Upcoming Reminders',
    'Reminder History',
    'Search Reminders',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                print('Hello');
                // NotificationService().testingScheduleReminder(id: 1, title: 'title', body: 'Testing');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditReminderScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notifications_active_outlined),
            selectedIcon: Icon(Icons.notifications_active),
            label: 'Upcoming',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';
import 'add_edit_reminder_screen.dart';

class ReminderHistoryScreen extends StatelessWidget {
  const ReminderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final reminders = provider.history;

        if (reminders.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No reminder history yet.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return ReminderCard(
              reminder: reminder,
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditReminderScreen(existing: reminder),
                ),
              ),
              onDelete: () => provider.deleteReminder(reminder.id),
              onTogglePaid: (val) => provider.markAsPaid(reminder.id, paid: val),
            );
          },
        );
      },
    );
  }
}

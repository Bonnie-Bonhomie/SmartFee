import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';
import 'add_edit_reminder_screen.dart';

class UpcomingRemindersScreen extends StatelessWidget {
  const UpcomingRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final reminders = provider.upcomingReminders;

        if (reminders.isEmpty) {
          return const _EmptyState(
            icon: Icons.notifications_off_outlined,
            message: 'No upcoming reminders.\nTap + to add a school fees reminder.',
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadReminders,
          child: ListView.builder(
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
                onDelete: () => _confirmDelete(context, provider, reminder.id),
                onTogglePaid: (val) => provider.markAsPaid(reminder.id, paid: val),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, ReminderProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteReminder(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTogglePaid;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePaid,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '₦');
    final dateFmt = DateFormat('MMM d, yyyy');
    final overdue = reminder.isOverdue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Checkbox(
                  value: reminder.isPaid,
                  onChanged: (val) => onTogglePaid(val ?? false),
                ),
                const Text('Paid'),
              ],
            ),
            if (reminder.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(reminder.description,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(currencyFmt.format(reminder.amount))),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Due ${dateFmt.format(reminder.dueDate)}'),
                  backgroundColor: overdue
                      ? Colors.red.shade100
                      : reminder.isPaid
                          ? Colors.green.shade100
                          : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

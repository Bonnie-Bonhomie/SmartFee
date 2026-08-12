import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';
import 'add_edit_reminder_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search by title, description or amount',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        provider.setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: provider.searchQuery.trim().isEmpty
              ? const Center(child: Text('Start typing to search reminders.'))
              : provider.searchResults.isEmpty
                  ? const Center(child: Text('No matching reminders found.'))
                  : ListView.builder(
                      itemCount: provider.searchResults.length,
                      itemBuilder: (context, index) {
                        final reminder = provider.searchResults[index];
                        return ReminderCard(
                          reminder: reminder,
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditReminderScreen(existing: reminder),
                            ),
                          ),
                          onDelete: () => provider.deleteReminder(reminder.id),
                          onTogglePaid: (val) =>
                              provider.markAsPaid(reminder.id, paid: val),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

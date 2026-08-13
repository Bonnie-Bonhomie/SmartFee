import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../providers/reminder_provider.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? existing;

  const AddEditReminderScreen({super.key, this.existing});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _amountCtrl;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _notifyTime = const TimeOfDay(hour: 8, minute: 0);

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _amountCtrl = TextEditingController(
        text: r != null ? r.amount.toStringAsFixed(2) : '');
    if (r != null) _dueDate = r.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickNotifyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notifyTime,
    );
    if (picked != null) {
      setState(() => _notifyTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ReminderProvider>();
    final amount = double.parse(_amountCtrl.text.trim());

    /// Notify one day before due date at the chosen time (falls back to
    /// the due date itself if that day has already passed).
    var notifyDate = _dueDate.subtract(const Duration(days: 1));
    // print('After subtraction $notifyDate');
    if (notifyDate.isBefore(DateTime.now())) {
      print(notifyDate.isBefore(DateTime.now()));
      print(DateTime.now());
      notifyDate = _dueDate;
    }
    print(notifyDate);
    final notifyAt = DateTime(
      notifyDate.year,
      notifyDate.month,
      notifyDate.day,
      _notifyTime.hour,
      _notifyTime.minute,
    );

    if (_isEditing) {
      await provider.updateReminder(
        id: widget.existing!.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        amount: amount,
        dueDate: _dueDate,
        notifyAt: notifyAt,
      );
    } else {
      await provider.addReminder(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        amount: amount,
        dueDate: _dueDate,
        notifyAt: notifyAt,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reminder' : 'Add Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Fee Title (e.g. 1st Semester fee)',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₦ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Notification Time'),
              subtitle: Text(
                  'Remind me at ${_notifyTime.format(context)} (day before due date)'),
              trailing: const Icon(Icons.alarm),
              onTap: _pickNotifyTime,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? 'Update Reminder' : 'Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

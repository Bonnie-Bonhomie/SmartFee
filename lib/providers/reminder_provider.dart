import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();
  final _uuid = const Uuid();

  List<Reminder> _reminders = [];
  bool _isLoading = true;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Reminder> get allReminders => List.unmodifiable(_reminders);

  /// Unpaid reminders, soonest due date first.
  List<Reminder> get upcomingReminders {
    final list = _reminders.where((r) => !r.isPaid).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  /// Full history: paid + overdue + past reminders, newest first.
  List<Reminder> get history {
    final list = List<Reminder>.from(_reminders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Reminder> get overdueReminders =>
      _reminders.where((r) => r.isOverdue).toList();

  List<Reminder> get searchResults {
    if (_searchQuery.trim().isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return _reminders.where((r) {
      return r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.amount.toString().contains(q);
    }).toList();
  }

  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();
    _reminders = await _storage.loadReminders();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder({
    required String title,
    required String description,
    required double amount,
    required DateTime dueDate,
    DateTime? notifyAt,
  }) async {
    final notifId = await _storage.nextNotificationId();

    final reminder = Reminder(
      id: _uuid.v4(),
      title: title,
      description: description,
      amount: amount,
      dueDate: dueDate,
      notificationId: notifId,
    );

    _reminders.add(reminder);
    await _persist();

    final scheduleTime = notifyAt ?? dueDate;
    await _notifications.scheduleReminder(
      id: notifId,
      title: 'School Fees Due: ${reminder.title}',
      body:
          'Amount: ${reminder.amount.toStringAsFixed(2)} - due ${_formatDate(reminder.dueDate)}',
      scheduledDate: scheduleTime,
    );

    notifyListeners();
  }

  Future<void> updateReminder({
    required String id,
    required String title,
    required String description,
    required double amount,
    required DateTime dueDate,
    DateTime? notifyAt,
  }) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final old = _reminders[index];
    final updated = old.copyWith(
      title: title,
      description: description,
      amount: amount,
      dueDate: dueDate,
    );
    _reminders[index] = updated;
    await _persist();

    // Re-schedule notification with the (possibly new) date.
    await _notifications.cancelReminder(old.notificationId);
    final scheduleTime = notifyAt ?? dueDate.subtract(const Duration(days: 1));
    await _notifications.scheduleReminder(
      id: updated.notificationId,
      title: 'School Fees Due: ${updated.title}',
      body:
          'Amount: ${updated.amount.toStringAsFixed(2)} - due ${_formatDate(updated.dueDate)}',
      scheduledDate: scheduleTime,
    );

    notifyListeners();
  }

  Future<void> deleteReminder(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    await _notifications.cancelReminder(reminder.notificationId);
    _reminders.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> markAsPaid(String id, {bool paid = true}) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final reminder = _reminders[index];
    _reminders[index] = reminder.copyWith(
      isPaid: paid,
      paidAt: paid ? DateTime.now() : null,
    );

    if (paid) {
      await _notifications.cancelReminder(reminder.notificationId);
    }

    await _persist();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveReminders(_reminders);
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

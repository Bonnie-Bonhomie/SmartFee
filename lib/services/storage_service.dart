import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../models/user_profile.dart';

/// Handles all local (offline) persistence.
/// No network calls are made anywhere in this service.
class StorageService {
  static const _remindersKey = 'reminders_data_v1';
  static const _profileKey = 'user_profile_data_v1';
  static const _nextNotifIdKey = 'next_notification_id_v1';

  Future<List<Reminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_remindersKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_remindersKey, raw);
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  /// Generates a stable, incrementing integer id for scheduling
  /// local notifications (flutter_local_notifications requires an int id).
  Future<int> nextNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_nextNotifIdKey) ?? 1000;
    await prefs.setInt(_nextNotifIdKey, current + 1);
    return current;
  }
}

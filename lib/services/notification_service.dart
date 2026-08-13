import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Wraps flutter_local_notifications so that fee reminder alerts
/// are scheduled entirely on-device, with no internet dependency.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    // try {
      final TimezoneInfo currentTimeZone =
          await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
    // } catch (_) {
    //   // Fall back to UTC if the platform local zone cannot be resolved.
    //   tz.setLocalLocation(tz.getLocation('UTC'));
    // }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Ask for Android 13+ runtime notification permission.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);




    _initialized = true;
  }

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
        'school_fees_channel',
        'School Fees Reminders',
        channelDescription: 'Notifications for upcoming school fees payments',
        importance: Importance.high,
        priority: Priority.high,
      );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  /// Schedules a one-time local notification for [scheduledDate].
  /// If the date is already in the past, nothing is scheduled.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print('Schedule Notification start');
    if (scheduledDate.isBefore(DateTime.now().add(const Duration(minutes: 1))))
      return;

    print('Schedule $scheduledDate');
    await init();

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    print('Timezone time $tzDate');
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    print('Schedule notification delivered');
  }

  Future<void> cancelReminder(int id) async {
    await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}

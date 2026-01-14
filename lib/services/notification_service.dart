import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      // ✅ getLocalTimezone() trả về TimezoneInfo
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timeZoneInfo.identifier;

      print('[NotificationService] Local timezone: $timeZoneName');

      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print(
        '[NotificationService] ⚠️ setLocalLocation error: $e, fallback Asia/Ho_Chi_Minh',
      );
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }


    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    _initialized = true;
    print('[NotificationService] init done');
  }

  /// Xin quyền thông báo (Android 13+)
  static Future<void> requestNotificationPermission() async {
    final androidImpl =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted =
        await androidImpl?.requestNotificationsPermission() ?? false;

    print('[NotificationService] notifications permission granted = $granted');
  }

  /// 1 CHANNEL DUY NHẤT CHO CẢ TEST & LỊCH TẬP
  static const _channelId = 'common_channel';
  static const _channelName = 'Thông báo chung';
  static const _channelDescription = 'Kênh dùng chung cho test & lịch tập';

  /// Test ngay lập tức
  static Future<void> showTestNow() async {
    if (!_initialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      9999,
      'Test Notification',
      'Nếu bạn thấy cái này là notification đang hoạt động ✅',
      details,
    );
  }

  /// Đặt lịch trong tương lai (KHÔNG dùng exact alarm)
  static Future<void> scheduleWorkoutNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    String? body,
  }) async {
    if (!_initialized) {
      await init();
    }

    var scheduled = tz.TZDateTime.from(dateTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    print('[NotificationService] schedule request: $scheduled, now=$now');

    if (scheduled.isBefore(now)) {
      // Tính khoảng cách thời gian
      final diff = now.difference(scheduled);

      // Nếu thời gian đã chọn ở quá khứ nhưng chưa quá 5 phút
      // (Do người dùng chọn giờ hiện tại nhưng bị trễ giây hoặc thao tác chậm)
      if (diff.inMinutes < 5) {
        print('[NotificationService] Thời gian chọn hơi trễ so với Now, tự động +5s để kích hoạt ngay.');
        // Đặt lịch lại thành: Bây giờ + 5 giây
        scheduled = now.add(const Duration(seconds: 5));
      } else {
        // Nếu đã qua quá lâu (ví dụ chọn ngày hôm qua), thì bỏ qua thật
        print('[NotificationService] BỎ QUA: scheduled < now (quá khứ xa)');
        return;
      }
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.zonedSchedule(
        id,
        'Lịch tập',
        body ?? title,
        scheduled,
        details,
        // ❌ KHÔNG dùng exactAllowWhileIdle nữa
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );

      print('[NotificationService] ✅ Scheduled workout id=$id at $scheduled');
    } catch (e) {
      print('[NotificationService] ❌ zonedSchedule error: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    if (!_initialized) {
      await init();
    }
    await _plugin.cancel(id);
  }


  /// Debug: xem những notification đang pending
  static Future<void> debugPending() async {
    final list = await _plugin.pendingNotificationRequests();
    for (final e in list) {
      print(
          '[NotificationService] pending id=${e.id}, title=${e.title}, body=${e.body}');
    }
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  LocalNotification._internal();
  static final LocalNotification _instance = LocalNotification._internal();
  factory LocalNotification.instance() => _instance;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final _androidInitializationSetting = const AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  // ios
  final _iosInitializationSetting = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  final _androidChanel = const AndroidNotificationChannel(
    'channel_id',
    'Channel name',
    description: 'Android push notification channel',
    importance: Importance.max,
  );

  // Flage
  bool _isFlutterLocalNotificationInitialized = false;

  int _notificationCounter = 0;
  Future<void> init() async {
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSetting,
      iOS: _iosInitializationSetting,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChanel);

    _isFlutterLocalNotificationInitialized = true;
  }

  Future<void> showNOtification(
    String? title,
    String? body,
    String? payload,
  ) async {
    _notificationCounter++;

    AndroidNotificationDetails androidDetail = AndroidNotificationDetails(
      _androidChanel.id,
      _androidChanel.name,
      channelDescription: _androidChanel.description,
      priority: Priority.high,
    );

    DarwinNotificationDetails iosDetail = DarwinNotificationDetails(
      badgeNumber: _notificationCounter, // ⭐ iOS badge set HERE
    );

    final notificationDetails = NotificationDetails(
      android: androidDetail,
      iOS: iosDetail,
    );

    await _flutterLocalNotificationsPlugin.show(
      _notificationCounter,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}

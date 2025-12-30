import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Firebase/notification/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  LocalNotification? _localNotification;
  PrefStorage localStorage=PrefStorage();

  Future<void> init({required LocalNotification localNotification}) async {
    _localNotification = localNotification;

    // 1️⃣ Request permission first
    await _requestPermission();

    // 2️⃣ Then wait for APNs token (iOS only)
    await _waitForAPNsToken();

    // 3️⃣ Then safely handle FCM token
    await _handlePushNotificationToken();

    // 4️⃣ Set up message listeners
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

    // 5️⃣ Handle notification if app was opened from a terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenApp(initialMessage);
    }
  }

  Future<void> _handlePushNotificationToken() async {
    try {
      // Wait until APNs token exists (for iOS)
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
  
        await _waitForAPNsToken();
      }

      final token = await FirebaseMessaging.instance.getToken();
   
      await localStorage.saveFCMToken(fcmToken: token!);
      

      FirebaseMessaging.instance.onTokenRefresh
          .listen((fcmToken) {
            
          })
          .onError((e) {
           
          });
    } catch (e) {

    }
  }

  Future<void> _requestPermission() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
 
  }

  /// 👇 New helper: wait until iOS gives you an APNs token
  Future<void> _waitForAPNsToken() async {


    String? apnsToken;
    int retry = 0;

    while (apnsToken == null && retry < 20) {
      // waits up to 10 seconds
      await Future.delayed(const Duration(milliseconds: 500));
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      retry++;
    }

    if (apnsToken == null) {

    } else {
  
    }
  }

  void _onForegroundMessage(RemoteMessage message) {


    final notification = message.notification;
    if (notification != null) {
      _localNotification?.showNOtification(
        notification.title,
        notification.body,
        message.data.toString(),
      );
    }
  }

  void _onMessageOpenApp(RemoteMessage message) {

  }
}

// Must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

}

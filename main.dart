
import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/view_models/chat_view_model.dart';
import 'package:findup_mvvm/Data/view_models/notification_view_model.dart';
import 'package:findup_mvvm/Data/view_models/slide_view_model.dart';
import 'package:findup_mvvm/Firebase/notification/firebase_messaging_service.dart';
import 'package:findup_mvvm/Firebase/notification/local_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
import 'package:findup_mvvm/Data/view_models/group_category_view_model.dart';
import 'package:findup_mvvm/Data/view_models/group_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Data/view_models/sub_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotification = LocalNotification.instance();
  await localNotification.init();

  runApp(MyApp());

  // 🕐 Initialize Firebase Messaging AFTER the app is running
  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(localNotification: localNotification);
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  PrefStorage prefStorage = PrefStorage();
  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          
          // Firebase is fully initialized, now create your providers
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => UserViewModel()),
              ChangeNotifierProvider(create: (_) => GroupCategoryViewModel()),
              ChangeNotifierProvider(create: (_) => SubCategoryViewModle()),
              ChangeNotifierProvider(create: (_) => GroupPlaceViewModel()),
              ChangeNotifierProvider(create: (_) => SubPlaceViewModel()),
              ChangeNotifierProvider(create: (_) => ProductModelViewModel()),
              ChangeNotifierProvider(create: (_) => AppConfigViewModel()),
              ChangeNotifierProvider(create: (_) => ChatViewModel()),
              ChangeNotifierProvider(create: (_) => NotificationViewModel()),
              ChangeNotifierProvider(create: (_) => SlideViewModel()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: SplashPage(),
            ),
          );
        }

        // While Firebase initializes, show a loading screen
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Firebase/firebase_service.dart';
import 'package:findup_mvvm/Pages/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final PrefStorage prefStorage = PrefStorage();
  String lang = "km.txt";

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  /// 🔥 MAIN INITIALIZATION FLOW
  Future<void> _initApp() async {
    // 1️⃣ Firebase permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2️⃣ Load language
    await _initLanguage();

    // 3️⃣ Load local user data
    await _loadLocalUser();

    // 4️⃣ Load app config
    if (mounted) {
      await context.read<AppConfigViewModel>().getAppConfig();

      if (LocalStorage.userModel != null) {
        await context.read<UserViewModel>().getUserInfo(
          userID: LocalStorage.userModel!.id,
        );
      }
    }

    // 5️⃣ Navigate when everything is READY
    if (mounted) {
      Navigation.goReplacePage(context: context, page: HomePage());
    }
  }

  /// 🌐 Language loader
  Future<void> _initLanguage() async {
    String keyLan = prefStorage.langKey;
    final value = await prefStorage.initLanguages(key: keyLan);

    if (value.isNotEmpty) {
      lang = '${value['lan_code']}.txt';
    }

    await Translator.load('assets/lang/$lang');
  }

  /// 👤 Local user + token
  Future<void> _loadLocalUser() async {
    final userMap = await LocalStorage.getMap('user');
    final tokenMap = await LocalStorage.getMap('api_token');

    if (userMap != null && tokenMap != null) {
      LocalStorage.userModel = UserModel.fromJson(userMap);
      LocalStorage.apiToken = tokenMap['api_token'];
    } else {
      FirebaseService.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xfff7f7f8),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/background/bg3.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.blue.withOpacity(0.1),
              BlendMode.modulate,
            ),
          ),
        ),
        child: Center(
          child: Image.asset('assets/images/findUp.png', width: 160),
        ),
      ),
    );
  }
}

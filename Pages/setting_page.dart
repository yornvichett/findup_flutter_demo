import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view_models/group_category_view_model.dart';
import 'package:findup_mvvm/Data/view_models/group_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';

import 'package:findup_mvvm/Pages/splash_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  PrefStorage prefStorage = PrefStorage();
  List<Map<String, dynamic>> listItem = [
    //{'id':1,'title':'Your Contact','key_translate':'your_contact','icon':Icons.contact_phone_outlined,'color':Colors.green},
    {
      'id': 2,
      'title': 'Close Account',
      'key_translate': 'close_account',
      'icon': Icons.close_sharp,
      'color': Colors.blue,
    },
    {
      'id': 3,
      'title': 'Log out',
      'key_translate': 'log_out',
      'icon': Icons.logout,
      'color': Colors.red,
    },
  ];
  Future<void> onRefreshToken() async {
    await FirebaseMessaging.instance.deleteToken();
    String? newToken = await FirebaseMessaging.instance.getToken();
    await prefStorage.saveFCMToken(fcmToken: newToken!);
  }

  Helper helper = Helper();
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          Translator.translate('setting'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColor.textAppBarColor,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: userViewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: listItem.length,
              itemBuilder: (context, index) {
                return listItemWidget(
                  item: listItem[index],
                  onTab: () async {
                    if (listItem[index]['id'] == 1) {
                      
                    } else if (listItem[index]['id'] == 2) {
                      helper.showModernDialog(
                        
                        context,
                        title: Translator.translate('delete_account'),
                        tabOutSide: false,
                        color: const Color.fromARGB(255, 223, 221, 221),
                        icon: Icons.person_remove_alt_1_outlined,
                        subTitle: Translator.translate('this_account_will_delete_forever'),
                        onConfirm: () async {
                          await onRefreshToken();
                          await userViewModel.closeAccount(
                            userID: LocalStorage.userModel!.id,
                            context: context,
                          );
                        },
                      );
                    } else if (listItem[index]['id'] == 3) {
                      helper.showModernDialog(
                        context,
                        title: Translator.translate('log_out'),
                        icon: Icons.logout,
                        tabOutSide: false,
                        color: const Color.fromARGB(255, 223, 221, 221),
                        subTitle: Translator.translate('do_you_want_to_log_out'),
                        onConfirm: () async {
                          await onRefreshToken();
                          await userViewModel.logout(
                            context: context,
                            userID: LocalStorage.userModel!.id,
                          );
                          Navigator.pop(context);
                          Navigation.goReplacePage(
                            context: context,
                            page: SplashPage(),
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  Widget listItemWidget({
    required Map<String, dynamic> item,
    Function()? onTab,
  }) {
    return GestureDetector(
      onTap: onTab,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color.fromARGB(66, 0, 0, 0),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translator.translate(item['key_translate']),
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              Icon(item['icon'], color: item['color']),
            ],
          ),
        ),
      ),
    );
  }
}

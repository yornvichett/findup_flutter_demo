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
import 'package:findup_mvvm/Pages/_Profile/Add_Product/add_product_group_category_page.dart';

import 'package:findup_mvvm/Pages/splash_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SaleTypePage extends StatefulWidget {
  SaleTypePage({super.key});

  @override
  State<SaleTypePage> createState() => _SaleTypePageState();
}

class _SaleTypePageState extends State<SaleTypePage> {
  PrefStorage prefStorage = PrefStorage();
  List<Map<String, dynamic>> listItem = [
    //{'id':1,'title':'Your Contact','key_translate':'your_contact','icon':Icons.contact_phone_outlined,'color':Colors.green},
    {
      'id': 2,
      'title': 'Sale',
      'key_translate': 'add_sale',
      'icon': Icons.sell,
      'color': Colors.red,
    },
    {
      'id': 3,
      'title': 'Rent',
      'key_translate': 'add_rent',
      'icon': Icons.key,
      'color': Colors.blue,
    },
  ];
  Future<void> onRefreshToken() async {
    await FirebaseMessaging.instance.deleteToken();
    String? newToken = await FirebaseMessaging.instance.getToken();
    await prefStorage.saveFCMToken(fcmToken: newToken!);
  }

  Helper helper = Helper();
  String saleType = "";
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
          Translator.translate('posts'),
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
                    saleType = listItem[index]['title'];
                    Navigation.goPage(
                      context: context,
                      page: AddProductGroupCategoryPage(
                      
                      ),
                    );
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

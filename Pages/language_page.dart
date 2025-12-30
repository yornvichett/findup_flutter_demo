import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePage extends StatefulWidget {
  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selected = "km";
  

  final List<Map<String, String>> languages = [
    {"code": "km", "name": "ភាសាខ្មែរ", "flag": "🇰🇭"},
    {"code": "en", "name": "English", "flag": "🇺🇸"},
    {"code": "ch", "name": "中文", "flag": "🇨🇳"},
    {"code": "ko", "name": "한국어", "flag": "🇰🇷"},
  ];
  PrefStorage prefStorage = PrefStorage();
  TextHelper textHelper = TextHelper();
  ValueNotifier<bool> refresh = ValueNotifier(false);

  void setLangPref({required Map<String, dynamic> mapData}) {
    String keyLan = prefStorage.langKey;
    prefStorage.setLanguages(mapData: mapData, key: keyLan).then((value) {
      String lanCode = '';
      prefStorage
          .initLanguages(key: keyLan)
          .then((value) {
            if (value.isNotEmpty) {
              lanCode = value['lan_code'] + '.txt';
            }
          })
          .whenComplete(() async {
            await Translator.load('assets/lang/$lanCode');
            refresh.value = !refresh.value;
          });
    });
  }

  void saveKey({required String key}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('key', key);
  }

  void getKey() async {
    refresh.value=true;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? key = sharedPreferences.getString('key'); // no more !

    if(key=='null' || key==null){
      selected='km';
    }else{
      selected=key;
    }
    refresh.value=false;
    
  }

  @override
  void initState() {
    getKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigation.goReplacePage(context: context, page: SplashPage());
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios_new_outlined),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColor.appBarColor,
        title: ValueListenableBuilder(
          valueListenable: refresh,
          builder: (context, value, child) {
            return Text(
              Translator.translate('choose_languages'),
              style: textHelper.textAppBarStyle(),
            );
          },
        ),
      ),

      body: ValueListenableBuilder(
        valueListenable: refresh,
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: languages.map((lang) {
                bool isActive = selected == lang["code"];
          
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedScale(
                    scale: isActive ? 1.02 : 1.0,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeOut,
          
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          selected = lang["code"]!;
                          Map<String, dynamic> mapData = {'lan_code': selected};
                          setLangPref(mapData: mapData);
                          saveKey(key: selected);
                        });
          
                        // TODO: change language logic
                      },
          
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: isActive
                                ? Colors.blueAccent
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
          
                        child: Row(
                          children: [
                            Text(lang["flag"]!, style: TextStyle(fontSize: 22)),
          
                            SizedBox(width: 16),
          
                            Expanded(
                              child: Text(
                                lang["name"]!,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
          
                            if (isActive)
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      ),
    );
  }
}

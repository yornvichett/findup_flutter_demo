import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Data/models/app_config_model.dart';
import 'package:findup_mvvm/Data/view/app_config_view.dart';
import 'package:flutter/material.dart';

class AppConfigViewModel extends ChangeNotifier {
  AppConfigView appConfigView = AppConfigView();
  List<AppConfigModel> listAppConfigModel = [];
  bool isLoading = false;

  Future<void> getAppConfig() async {

    try {
      listAppConfigModel = await appConfigView.getAppConfig();

      Helper.groupCategoryID=listAppConfigModel.first.initSelectedGroupCategoryID;
    } catch (e) {
    } finally {

    }
  }
}

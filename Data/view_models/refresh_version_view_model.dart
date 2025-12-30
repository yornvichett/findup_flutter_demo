import 'package:findup_mvvm/Data/models/refresh_version_model.dart';
import 'package:findup_mvvm/Data/view/refresh_version_view.dart';
import 'package:flutter/material.dart';

class RefreshVersionViewModel extends ChangeNotifier {
  List<RefreshVersionModel> listRefreshVersionModel = [];
  RefreshVersionView refreshVersionView = RefreshVersionView();
  bool isFirstLoad = false;
  Future<void> getRefreshVersion() async {

    try {
      isFirstLoad = true;
      notifyListeners();

      listRefreshVersionModel = await refreshVersionView.getRefreshVersion();

    } catch (e) {

    } finally {
      isFirstLoad = false;
      notifyListeners();
    }
  }
}

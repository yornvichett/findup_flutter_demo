
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/view/group_category_view.dart';
import 'package:findup_mvvm/Data/view/group_place_view.dart';
import 'package:findup_mvvm/Pages/_Category_Filtter/1_group_place_list_page.dart';
import 'package:flutter/material.dart';

class GroupPlaceViewModel extends ChangeNotifier {
  GroupPlaceView groupPlaceViewModel = GroupPlaceView();
  List<GroupPlaceModel> gropuPlaceModel = [];
  bool isLoading = false;

  Future<void> getGroupPlace() async {
    isLoading = true;
    notifyListeners();
    try {
      gropuPlaceModel = await groupPlaceViewModel.getAllGroupPlace();

    } catch (e) {

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

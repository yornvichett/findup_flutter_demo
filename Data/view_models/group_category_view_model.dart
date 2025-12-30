import 'package:findup_mvvm/Core/Storage/refresh_storage.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:findup_mvvm/Data/view/group_category_view.dart';
import 'package:flutter/cupertino.dart';

class GroupCategoryViewModel extends ChangeNotifier {
  GroupCategoryView groupCategoryView = GroupCategoryView();
  List<GroupCategoryModel> lisGroupCategoryModel = [];
  bool isLoading = false;
  RefreshStorage refreshStorage=RefreshStorage();

  Future<void> getAllGroupCategory() async {
    // isLoading = true;
  
    // notifyListeners();
    try {
      lisGroupCategoryModel = await groupCategoryView.getAllGroupCategory();

    } catch (e) {

    } finally {
      // isLoading = false;
      // notifyListeners();
    }
  }

  void tabCategory(GroupCategoryModel groupCategoryModel) {
    if (lisGroupCategoryModel.isNotEmpty) {
      for (var item in lisGroupCategoryModel) {
        item.isSelected = 0;
      }
      
      
    }
    lisGroupCategoryModel.where((element) => element.id==groupCategoryModel.id,).first.isSelected=1;

  }
}

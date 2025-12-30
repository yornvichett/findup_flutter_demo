import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view/sub_category_view.dart';
import 'package:flutter/cupertino.dart';

class SubCategoryViewModle extends ChangeNotifier {
  SubCategoryView subCategoryView = SubCategoryView();
  List<SubCategoryModel> listFilterSubCategory = [];
  List<SubCategoryModel> listAllSubCategory = [];

  bool isLoading = false;

  Future<void> getFilterSubcategory({required int groupCategoryID}) async {
    isLoading = true;
    notifyListeners();
    try {
      listFilterSubCategory = await subCategoryView.filterSubCategory(
        groupCategoryID: groupCategoryID,
      );
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllSubcategory() async {
    isLoading = true;
    notifyListeners();
    try {
      listAllSubCategory = await subCategoryView.getAllSubCategory();

    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void tabSubCategory(SubCategoryModel subCagoryModel) {
    isLoading = true;
    notifyListeners();
    if (listFilterSubCategory.isNotEmpty) {
      for (var item in listFilterSubCategory) {
        item.is_selected = false;
      }
      subCagoryModel.is_selected = true;
      isLoading = false;
      notifyListeners();
    }
  }
}

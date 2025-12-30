import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/sub_place_model.dart';
import 'package:findup_mvvm/Data/view/sub_place_view.dart';
import 'package:flutter/cupertino.dart';

class SubPlaceViewModel extends ChangeNotifier {
  SubPlaceView subPlaceView = SubPlaceView();
  List<SubPlaceModel> listSubPlace = [];
  bool isLoading = false;

  Future<void> getSubPlace({required int groupPlaceID}) async {
    listSubPlace.clear();
    isLoading = true;
    notifyListeners();
    
    try {
      listSubPlace = await subPlaceView.getSubPlace(groupPlaceID: groupPlaceID);
    } catch (e) {
  
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> subCategoryTab({required SubPlaceModel subPlaceModel})async{
    isLoading = true;
    notifyListeners();
    for(var item in listSubPlace){
      item.isSelected=0;
    }
    subPlaceModel.isSelected=1;
    isLoading = false;
    notifyListeners();
  }
}

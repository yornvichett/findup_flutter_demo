import 'package:findup_mvvm/Data/models/slide_model.dart';
import 'package:findup_mvvm/Data/view/slide_view.dart';
import 'package:flutter/cupertino.dart';

class SlideViewModel extends ChangeNotifier {
  SlideView slideView = SlideView();
  List<SlideModel> listSlideTop = [];
  List<SlideModel> listSlideBottom = [];
  bool isLoading = false;

  Future<void> getBottomListADS() async {
    isLoading = true;
    notifyListeners();
    try {
      listSlideBottom = await slideView.getBottomListADS();

    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTopListADS() async {
    isLoading = true;
    notifyListeners();
    try {
      listSlideTop = await slideView.getTopListADS();

    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

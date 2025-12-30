import 'package:findup_mvvm/Core/Storage/refresh_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view_models/group_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Pages/_Auth/login_page.dart';
import 'package:findup_mvvm/Pages/_Category_Filtter/2_category_show_product_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GroupPlaceListPage extends StatefulWidget {
  SubCategoryModel subCategoryModel;

  GroupPlaceListPage({
    super.key,
    required this.subCategoryModel,

  });

  @override
  State<GroupPlaceListPage> createState() => _GroupPlaceListPageState();
}

class _GroupPlaceListPageState extends State<GroupPlaceListPage> {
  ValueNotifier<bool> refreshPage = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupPlaceViewModel>(context, listen: false).getGroupPlace();
    });
  }

  @override
  Widget build(BuildContext context) {
    GroupPlaceViewModel groupPlaceViewModel = Provider.of<GroupPlaceViewModel>(
      context,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          Translator.translate(widget.subCategoryModel.keyTranslate),

          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColor.textAppBarColor,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: refreshPage,
        builder: (context, value, child) {
          return groupPlaceViewModel.isLoading
              ? Center(child: CircularProgressIndicator(
                backgroundColor: Colors.blueGrey,
                color: Colors.white,
              ))
              : ListView.builder(
                  itemCount: groupPlaceViewModel.gropuPlaceModel.length,
                  itemBuilder: (context, index) {
                    GroupPlaceModel groupPlaceModel =
                        groupPlaceViewModel.gropuPlaceModel[index];
                    return listItemWidget(
                      groupPlaceModelitem: groupPlaceModel,
                      onTab: () {
                        if (LocalStorage.userModel == null) {
                          Navigation.goReplacePage(
                            context: context,
                            page: LoginPage(),
                          );
                        } else {
                          Navigation.goPage(
                            context: context,
                            page: CategoryShowProductPage(
                              subCategoryModel: widget.subCategoryModel,
                              groupPlaceModel: groupPlaceModel,
                            ),
                          );
                        }
                      },
                    );
                  },
                );
        },
      ),
    );
  }

  Widget listItemWidget({
    required GroupPlaceModel groupPlaceModelitem,
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
                Translator.translate(groupPlaceModelitem.keyGroupPlaceTranslate),
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              Icon(Icons.arrow_right),
            ],
          ),
        ),
      ),
    );
  }
}

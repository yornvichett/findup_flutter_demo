import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/Storage/refresh_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:findup_mvvm/Data/view_models/group_category_view_model.dart';
import 'package:findup_mvvm/Data/view_models/refresh_version_view_model.dart';
import 'package:findup_mvvm/Pages/_Profile/Add_Product/add_product_group_place_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddProductGroupCategoryPage extends StatefulWidget {




  AddProductGroupCategoryPage({
    super.key,
  });

  @override
  State<AddProductGroupCategoryPage> createState() => _AddProductGroupCategoryPageState();
}

class _AddProductGroupCategoryPageState extends State<AddProductGroupCategoryPage> {
  RefreshVersionViewModel refreshVersionViewModel = RefreshVersionViewModel();
  Map<String, dynamic> localGroupPlaceVersion = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
    });
  }

  @override
  Widget build(BuildContext context) {
    GroupCategoryViewModel groupCategoryViewModel =
        Provider.of<GroupCategoryViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          Translator.translate('type'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColor.textAppBarColor,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: groupCategoryViewModel.isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blueGrey,
                color: Colors.white,
              ),
            )
          : ListView.builder(
              itemCount: groupCategoryViewModel.lisGroupCategoryModel.length,
              itemBuilder: (context, index) {
                GroupCategoryModel groupCategoryModel =
                    groupCategoryViewModel.lisGroupCategoryModel[index];

                return listItemWidget(
                  groupCategoryModel: groupCategoryModel,
                  onTab: () {
                    Navigation.goPage(
                      context: context,
                      page: AddProductGroupPlacePage(
                        groupCategoryModel: groupCategoryModel,
                  
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget listItemWidget({
    required GroupCategoryModel groupCategoryModel,
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
                Translator.translate(groupCategoryModel.keyTranslate),
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              const Icon(Icons.arrow_right),
            ],
          ),
        ),
      ),
    );
  }
}

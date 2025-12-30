import 'package:findup_mvvm/Core/Storage/show_mode_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/check_screen.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/group_categ_horizon_scroll.dart';
import 'package:findup_mvvm/Core/utils/large_card_item_element.dart';
import 'package:findup_mvvm/Core/utils/list_card_item.dart';
import 'package:findup_mvvm/Core/utils/no_item_text_widget.dart';
import 'package:findup_mvvm/Core/utils/slide_auto_scroll_element.dart';
import 'package:findup_mvvm/Core/utils/sub_category_horizon_scroll.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view_models/group_category_view_model.dart';
import 'package:findup_mvvm/Data/view_models/group_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/slide_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Pages/Screen/dialog_map_show_location_of_property.dart';
import 'package:findup_mvvm/Pages/Screen/dialog_map_show_all_remark_lat_lon.dart';
import 'package:findup_mvvm/Pages/_Auth/login_page.dart';
import 'package:findup_mvvm/Pages/_See_All/dialog_search_see_all_product.dart';
import 'package:findup_mvvm/Pages/product_item_detail_page.dart';
import 'package:findup_mvvm/Pages/to_view_user_post_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeeAllProductPage extends StatefulWidget {
  SubCategoryViewModle subCategoryViewModle;
  int groupCategoryID;
  String title;

  SeeAllProductPage({
    super.key,
    required this.subCategoryViewModle,
    required this.groupCategoryID,
    required this.title
  });

  @override
  State<SeeAllProductPage> createState() =>
      _SeeAllProductPageState();
}

class _SeeAllProductPageState
    extends State<SeeAllProductPage> {
  TextHelper textHelper = TextHelper();
  CheckScreen checkScreen = CheckScreen();
  Helper helper = Helper();
  ProductModelViewModel? productModelViewModel;
  ValueNotifier<String> keyTitle = ValueNotifier('');
  ValueNotifier<bool> isListMode = ValueNotifier(false);
  String mode = '';
  @override
  void initState() {
    super.initState();
    widget.subCategoryViewModle.listFilterSubCategory.first.is_selected = true;
    keyTitle.value =
        widget.subCategoryViewModle.listFilterSubCategory.first.keyTranslate;
    int firsSubCatID = widget.subCategoryViewModle.listFilterSubCategory.first.id;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      mode = await ShowModeStorage.getModeCache();

      context.read<ProductModelViewModel>().getProductBySubCategory(
        userID: LocalStorage.userModel == null ? 0 : LocalStorage.userModel!.id,
        subCategoryID: firsSubCatID,
      );
      if (mode == 'list' || mode == '') {
        isListMode.value = true;
      } else {
        isListMode.value = false;
      }
    });
  }

  void FilterData({
    required int userID,
    required SubCategoryModel subCagoryModel,
  }) async {
    await productModelViewModel!.getProductBySubCategory(
      userID: userID,
      subCategoryID: subCagoryModel.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    SlideViewModel slideViewModel = Provider.of<SlideViewModel>(
      context,
      listen: false,
    );
    Size size = MediaQuery.of(context).size;
    productModelViewModel = Provider.of<ProductModelViewModel>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColor.appBarColor,
        title: Text(
          Translator.translate(widget.title),
          style: textHelper.textAppBarStyle(),
        ),
        actions: [
          GestureDetector(
            onTap: () {


              helper.showScreenPopUp(
                context: context,
                title: "All Product",
                child: DialogMapShowAllRemarkLatLon(listLatLong: productModelViewModel!.listGetProductBySubCategory,),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(CupertinoIcons.map_pin_ellipse, size: 28),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Advertisement
              helper.buildSlideAdvertise(
                loadingPathTemp: 'assets/slide/top_slide1.png',
                radius: 0,
                imgList: [slideViewModel.listSlideTop.first.imageUrl],
                height: checkScreen.isTablet(context)
                    ? (33 / 100) * size.height
                    : (25 / 100) * size.height,
              ),
              SizedBox(height: 10),
              // Sub Category
              SubCategoryHorizonScroll(
                listSUbCategory:
                    widget.subCategoryViewModle.listFilterSubCategory,
                onTab: (item) {
                  keyTitle.value = item.keyTranslate;
                  widget.subCategoryViewModle.tabSubCategory(item);
                  FilterData(
                    userID: LocalStorage.userModel == null
                        ? 0
                        : LocalStorage.userModel!.id,
                    subCagoryModel: item,
                  );
                },
              ),
              SizedBox(height: 10),
              productModelViewModel!.listGetProductBySubCategory.isEmpty
                  ? NoItemTextWidget()
                  : ValueListenableBuilder(
                    valueListenable: keyTitle,
                    builder: (context, value, child) {
                      return helper.modeLine(title: keyTitle.value, isListMode: isListMode, mode: mode);
                    }
                  ),
              SizedBox(height: 10),
              ListView.builder(
                physics:
                    NeverScrollableScrollPhysics(), // disable inner scrolling
                shrinkWrap: true, // important!
                itemCount:
                    productModelViewModel!.listGetProductBySubCategory.length,
                itemBuilder: (context, index) {
                  ProductModel productModel =
                      productModelViewModel!.listGetProductBySubCategory[index];
                  List<String> listImage = helper.productModelSplitImage(
                    product: productModel,
                    path: 'property',
                    context: context,
                  );
                  return ValueListenableBuilder(
                    valueListenable: isListMode,
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          isListMode.value
                              ? ListCardItem(
                                  productModel: productModel,
                                  onTap: () {
                                    Navigation.goPage(
                                      context: context,
                                      page: ProductItemDetailPage(
                                        productModel: productModel,
                                      ),
                                    );
                                  },
                                )
                              : LargeCardItemElement(
                                  productModel: productModel,
                                  showOptionControllItem: false,
                                  images: listImage,
                                  onTab: () {
                                    Navigation.goPage(
                                      context: context,
                                      page: ProductItemDetailPage(
                                        productModel: productModel,
                                      ),
                                    );
                                  },
                                  onGoProfile: () {
                                    if (LocalStorage.userModel == null) {
                                      Navigation.goPage(
                                        context: context,
                                        page: LoginPage(),
                                      );
                                    } else {
                                      Navigation.goPage(
                                        context: context,
                                        page: ToViewUserPostProfilePage(
                                          paramProductModel: productModel,
                                        ),
                                      );
                                    }
                                  },
                                ),
                          helper.borderCustom(size: size),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Color(0xff344a58)
    );
  }


}

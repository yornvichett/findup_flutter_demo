import 'package:findup_mvvm/Core/Storage/show_mode_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/check_screen.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/large_card_item_element.dart';
import 'package:findup_mvvm/Core/utils/list_card_item.dart';
import 'package:findup_mvvm/Core/utils/no_item_text_widget.dart';
import 'package:findup_mvvm/Core/utils/slide_auto_scroll_element.dart';
import 'package:findup_mvvm/Core/utils/sub_category_horizon_scroll.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/slide_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Pages/Screen/dialog_map_show_all_remark_lat_lon.dart';
import 'package:findup_mvvm/Pages/_Auth/login_page.dart';
import 'package:findup_mvvm/Pages/product_item_detail_page.dart';
import 'package:findup_mvvm/Pages/to_view_user_post_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeeAllTopShowPage extends StatefulWidget {
  SubCategoryViewModle subCategoryViewModle;
  // List<ProductModel> listTopShow;
  SeeAllTopShowPage({
    super.key,
    required this.subCategoryViewModle,
    // required this.listTopShow,
  });

  @override
  State<SeeAllTopShowPage> createState() => _SeeAllTopShowPageState();
}

class _SeeAllTopShowPageState extends State<SeeAllTopShowPage> {
  TextHelper textHelper = TextHelper();
  CheckScreen checkScreen = CheckScreen();
  Helper helper = Helper();
  ValueNotifier<bool> isListMode = ValueNotifier(false);
  String mode = '';

  @override
  void initState() {
    super.initState();
    widget.subCategoryViewModle.listFilterSubCategory.first.is_selected = true;
    int firsSubCatID = widget.subCategoryViewModle.listFilterSubCategory.first.id;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      mode = await ShowModeStorage.getModeCache();
      context.read<ProductModelViewModel>().getTopProductBySubCategory(
        userID: LocalStorage.userModel == null ? 0 : LocalStorage.userModel!.id,
        subCategoryID: firsSubCatID,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SlideViewModel slideViewModel = Provider.of<SlideViewModel>(
      context,
      listen: false,
    );
    Size size = MediaQuery.of(context).size;
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context);
    if (mode == 'list' || mode == '') {
      isListMode.value = true;
    } else {
      isListMode.value = false;
    }
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColor.appBarColor,
        title: Text(
          Translator.translate('top_show'),
          style: textHelper.textAppBarStyle(),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              helper.showScreenPopUp(
                context: context,
                title: "Map Dialog",
                child: DialogMapShowAllRemarkLatLon(
                  listLatLong:
                      productModelViewModel.listTopShowBySubCategoryFilter,
                ),
              );
            },
            child: Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.map_pin_ellipse),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              helper.buildSlideAdvertise(
                loadingPathTemp: 'assets/slide/top_slide1.png',
                radius: 0,
                imgList: [slideViewModel.listSlideTop.first.imageUrl],
                height: checkScreen.isTablet(context)
                    ? (33 / 100) * size.height
                    : (25 / 100) * size.height,
              ),
              SizedBox(height: 10),

              SubCategoryHorizonScroll(
                listSUbCategory:
                    widget.subCategoryViewModle.listFilterSubCategory,
                onTab: (item) async {
                  widget.subCategoryViewModle.tabSubCategory(item);
                  await productModelViewModel.getTopProductBySubCategory(
                    userID: LocalStorage.userModel == null
                        ? 0
                        : LocalStorage.userModel!.id,
                    subCategoryID: item.id,
                  );
                },
              ),
              SizedBox(height: 10),
              helper.modeLine(title: 'recommended', isListMode: isListMode, mode: mode),
              SizedBox(height: 10),
              productModelViewModel.listTopShowBySubCategoryFilter.isEmpty
                  ? NoItemTextWidget()
                  : ValueListenableBuilder(
                      valueListenable: isListMode,
                      builder: (context, value, child) {
                        return ListView.builder(
                          physics:
                              NeverScrollableScrollPhysics(), // disable inner scrolling
                          shrinkWrap: true, // important!
                          itemCount: productModelViewModel
                              .listTopShowBySubCategoryFilter
                              .length,
                          itemBuilder: (context, index) {
                            ProductModel productModel = productModelViewModel
                                .listTopShowBySubCategoryFilter[index];
                            List<String> listImage = helper
                                .productModelSplitImage(
                                  product: productModel,
                                  path: 'property',
                                  context: context,
                                );
                            return isListMode.value
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
                                : Column(
                                    children: [
                                      LargeCardItemElement(
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

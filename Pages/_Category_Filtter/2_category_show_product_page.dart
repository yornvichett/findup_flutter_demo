import 'dart:ui';

import 'package:findup_mvvm/Core/Storage/show_mode_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/check_screen.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/Loading/simmer_show_product_filter_element.dart';
import 'package:findup_mvvm/Core/utils/large_card_item_element.dart';
import 'package:findup_mvvm/Core/utils/list_card_item.dart';
import 'package:findup_mvvm/Core/utils/no_item_text_widget.dart';
import 'package:findup_mvvm/Core/utils/Loading/simmer_loader_element.dart';
import 'package:findup_mvvm/Core/utils/slide_auto_scroll_element.dart';
import 'package:findup_mvvm/Core/utils/boost_card_item_element.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/models/sub_place_model.dart';
import 'package:findup_mvvm/Data/view_models/group_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/slide_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Data/view_models/sub_place_view_model.dart';
import 'package:findup_mvvm/Pages/Screen/dialog_map_show_all_remark_lat_lon.dart';
import 'package:findup_mvvm/Pages/_Category_Filtter/Components/dialog_search.dart';
import 'package:findup_mvvm/Pages/product_item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoryShowProductPage extends StatefulWidget {
  SubCategoryModel subCategoryModel;
  GroupPlaceModel groupPlaceModel;

  CategoryShowProductPage({
    super.key,
    required this.subCategoryModel,
    required this.groupPlaceModel,
  });

  @override
  State<CategoryShowProductPage> createState() =>
      _CategoryShowProductPageState();
}

class _CategoryShowProductPageState extends State<CategoryShowProductPage> {
  Helper helper = Helper();
  TextHelper textHelper = TextHelper();
  CheckScreen checkScreen = CheckScreen();
  ValueNotifier<bool> isListMode = ValueNotifier(false);
  String mode = '';

  void filterProduct({
    required ProductModelViewModel productModelViewModel,
    required int subPlaceID,
  }) async {
    await productModelViewModel.getProductFilter(
      userID: LocalStorage.userModel!.id,
      subCategoryID: widget.subCategoryModel.id,
      groupPlaceID: widget.groupPlaceModel.id,
      subPlaceID: subPlaceID,
    );
  }

  @override
  void initState() {
    // data for scroll
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      mode = await ShowModeStorage.getModeCache();
      context
          .read<ProductModelViewModel>()
          .filterproductBySubCategoryAndGroupPlace(
            subCategoryID: widget.subCategoryModel.id,
            groupPlaceID: widget.groupPlaceModel.id,
            userId: LocalStorage.userModel!.id,
          );

    });
  }

  @override
  Widget build(BuildContext context) {
    SlideViewModel slideViewModel = Provider.of<SlideViewModel>(
      context,
      listen: false,
    );
    // SubPlaceViewModel subPlaceViewModel = Provider.of<SubPlaceViewModel>(
    //   context,
    // );
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context);
    Size size = MediaQuery.of(context).size;
    if (mode == 'list' || mode == '') {
      isListMode.value = true;
    } else {
      isListMode.value = false;
    }
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColor.appBarColor,
        title: Text(
          '${Translator.translate(widget.subCategoryModel.keyTranslate)} / ${Translator.translate(widget.groupPlaceModel.keyGroupPlaceTranslate)}',

          style: textHelper.textAppBarStyle(
            color: AppColor.textAppBarColor,
            fontSize: 20,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              helper.showScreenPopUp(
                context: context,
                title: "Map",
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: DialogMapShowAllRemarkLatLon(
                      listLatLong: productModelViewModel.listProductOfSubCategoryAndGroupPlace,
               
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 13),
              child: Icon(CupertinoIcons.map_pin_ellipse, size: 28),
            ),
          ),
        ],
      ),
      body: productModelViewModel.isLoading
          ? SimmerShowProductFilterElement(size: size)
          : SizedBox(
              width: size.width,
              height: size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Slide ADS
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          helper.buildSlideAdvertise(
                            loadingPathTemp: 'assets/slide/top_slide1.png',
                            radius: 0,
                            imgList: [
                              slideViewModel.listSlideTop.first.imageUrl,
                            ],
                            height: checkScreen.isTablet(context)
                                ? (33 / 100) * size.height
                                : (25 / 100) * size.height,
                          ),
                          // SizedBox(height: 10),
                          // buildSubPlace(
                          //   onTab: (item) async {
                          //     filterProduct(
                          //       subPlaceID: item.id,
                          //       productModelViewModel: productModelViewModel,
                          //     );
                          //     subPlaceViewModel.subCategoryTab(
                          //       subPlaceModel: item,
                          //     );
                          //   },
                          //   listSubPlace: subPlaceViewModel.listSubPlace,
                          // ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildTopShow(
                        context: context,
                        listTopShow: productModelViewModel.listTopShowHomePage,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: productModelViewModel.listProductOfSubCategoryAndGroupPlace.isEmpty
                          ? NoItemTextWidget()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                helper.modeLine(isListMode: isListMode, mode: mode, title: widget.subCategoryModel.keyTranslate,),
                                // Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     Padding(
                                //       padding: const EdgeInsets.only(
                                //         left: 8,
                                //         right: 8,
                                //       ),
                                //       child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.start,
                                //         children: [
                                //           Text(
                                //             Translator.translate(
                                //               widget
                                //                   .subCategoryModel
                                //                   .keyTranslate,
                                //             ),
                                //             style: TextStyle(
                                //               fontWeight: FontWeight.bold,
                                //               fontSize: 18,
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //     GestureDetector(
                                //       onTap: () {
                                //         isListMode.value = !isListMode.value;
                                //         if (mode == '' || mode == 'list') {
                                //           ShowModeStorage.saveModeCache(
                                //             mode: "grid",
                                //           );
                                //         } else {
                                //           ShowModeStorage.saveModeCache(
                                //             mode: "list",
                                //           );
                                //         }
                                //       },
                                //       child: Padding(
                                //         padding: const EdgeInsets.all(8.0),
                                //         child: ValueListenableBuilder(
                                //           valueListenable: isListMode,
                                //           builder: (context, value, child) {
                                //             return Icon(
                                //               isListMode.value == false
                                //                   ? Icons.view_list_sharp
                                //                   : Icons.grid_view_outlined,
                                //             );
                                //           },
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                ValueListenableBuilder(
                                  valueListenable: isListMode,
                                  builder: (context, value, child) {
                                    return ListView.builder(
                                      physics:
                                          NeverScrollableScrollPhysics(), // disable inner scrolling
                                      shrinkWrap: true, // important!
                                      itemCount: productModelViewModel
                                          .listProductOfSubCategoryAndGroupPlace
                                          .length,
                                      itemBuilder: (context, index) {
                                        ProductModel productModel =
                                            productModelViewModel
                                                .listProductOfSubCategoryAndGroupPlace[index];
                                        List<String> images = helper
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
                                                      productModel:
                                                          productModel,
                                                    ),
                                                  );
                                                },
                                              )
                                            : LargeCardItemElement(
                                                productModel: productModel,
                                                images: images,

                                                onTab: () {
                                                  Navigation.goPage(
                                                    context: context,
                                                    page: ProductItemDetailPage(
                                                      productModel:
                                                          productModel,
                                                    ),
                                                  );
                                                },
                                              );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                    ),

                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildSubPlace({
    required Function(SubPlaceModel) onTab,
    required List<SubPlaceModel> listSubPlace,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: listSubPlace
            .map(
              (subPlace) => GestureDetector(
                onTap: () {
                  onTab(subPlace);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: subPlace.isSelected == 1
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                      color: subPlace.isSelected == 1
                          ? Color(0xff344a58)
                          : AppColor.categoryBackgroundColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 11,
                        bottom: 11,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: subPlace.isSelected == 1
                                ? Colors.white
                                : AppColor.activeIconColor,
                          ),
                          SizedBox(width: 2),
                          Text(
                            subPlace.name,
                            style: GoogleFonts.poppins(
                              color: subPlace.isSelected == 1
                                  ? Colors.white
                                  : AppColor.textCategoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget buildTopShow({
    required BuildContext context,
    required List<ProductModel> listTopShow,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: listTopShow
            .map(
              (product) => BoostCardItemElement(
                onTab: () {
                  Navigation.goPage(
                    context: context,
                    page: ProductItemDetailPage(productModel: product),
                  );
                },
                imageUrl: helper
                    .productModelSplitImage(
                      product: product,
                      path: 'property',
                      context: context,
                    )
                    .first,
                price: product.basePrice,
                billingPeriod: product.billingPeriod,
                title: product.title,
                location: '${product.groupPlace}.${product.subPlace}',
                discount: 'New',
                userProfileImage: product.userProfile,

                userName: product.userName,
                timeAgo: product.timeAgo,
                bathCount: product.bathCount,
                bedCount: product.bedCount,
                size: product.size,
              ),
            )
            .toList(),
      ),
    );
  }
}

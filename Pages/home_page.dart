import 'dart:async';

import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/check_screen.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/telegram_bot.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/Loading/simmer_home_loading_element.dart';
import 'package:findup_mvvm/Core/utils/category_grid_item.dart';
import 'package:findup_mvvm/Core/utils/large_card_item_element.dart';
import 'package:findup_mvvm/Core/utils/no_item_text_widget.dart';
import 'package:findup_mvvm/Core/utils/slide_auto_scroll_element.dart';
import 'package:findup_mvvm/Core/utils/boost_card_item_element.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
import 'package:findup_mvvm/Data/view_models/group_category_view_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';

import 'package:findup_mvvm/Data/view_models/slide_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Core/utils/group_categ_horizon_scroll.dart';
import 'package:findup_mvvm/Pages/FIlter/filter_page.dart';
import 'package:findup_mvvm/Pages/language_page.dart';
import 'package:findup_mvvm/Pages/_Profile/profile_page.dart';
import 'package:findup_mvvm/Pages/_See_All/see_all_product_page.dart';
import 'package:findup_mvvm/Pages/_See_All/see_all_top_show_page.dart';
import 'package:findup_mvvm/Pages/_Category_Filtter/1_group_place_list_page.dart';
import 'package:findup_mvvm/Pages/_Auth/login_page.dart';
import 'package:findup_mvvm/Pages/product_item_detail_page.dart';
import 'package:findup_mvvm/Pages/to_view_user_post_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<bool> generalSelected = ValueNotifier(true);
  Helper helper = Helper();
  final ScrollController _controller = ScrollController();
  ValueNotifier<bool> isVisible = ValueNotifier(true);
  double lastOffset = 0;
  Timer? _scrollStopTimer;
  Duration scrollStopDelay = Duration(milliseconds: 300);
  List<String> listTopSlideImages = [];
  List<String> listBottomSlideImages = [];

  AppConfigViewModel appConfigViewModel=AppConfigViewModel();

  List<Map<String, dynamic>> userManageOption = [
    {
      "id": 0,
      "value": "Edit", // unique identifier for action
      "icon": Icons.edit, // icon to show in menu
      "title": "Add to Favourite", // menu item text
    },
    {
      "id": 1,
      "value": "Delete",
      "icon": Icons.delete,
      "title": "Hide this post",
    },
  ];

  CheckScreen checkScreen = CheckScreen();
  TextHelper textHelper = TextHelper();

  bool isUserExist = false;
  bool isFirstLoad = true;
  ValueNotifier<String> keyTitle = ValueNotifier("office_building");
  void scrollListener() {
    final offset = _controller.position.pixels;
    // Hide when scrolling down
    if (offset > lastOffset) {
      if (isVisible.value) isVisible.value = false;
    }
    lastOffset = offset;
    // Cancel timer if still scrolling
    _scrollStopTimer?.cancel();

    // When user stops → show
    _scrollStopTimer = Timer(scrollStopDelay, () {
      if (!isVisible.value) {
        isVisible.value = true;
      }
    });
  }

  TelegramBot telegramBot = TelegramBot();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      
      if (Helper.allowFirstAds) {
        helper.showAdsPopup(context);
        Helper.allowFirstAds = false;
      }
      _controller.addListener(scrollListener);
      context.read<SlideViewModel>().getTopListADS();
      context.read<GroupCategoryViewModel>().getAllGroupCategory();
      context.read<SubCategoryViewModle>().getFilterSubcategory(
        groupCategoryID: Helper.groupCategoryID,
      );
      await context.read<SlideViewModel>().getBottomListADS();
      await context.read<ProductModelViewModel>().getProductByGroupCategory(
        groupCategoryID: Helper.groupCategoryID,
        userId: LocalStorage.userModel == null ? 0 : LocalStorage.userModel!.id,
      );
 
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SlideViewModel slideViewModel = Provider.of<SlideViewModel>(context);
    GroupCategoryViewModel groupCategoryViewModel =
        Provider.of<GroupCategoryViewModel>(context);
    SubCategoryViewModle subCategoryViewModle =
        Provider.of<SubCategoryViewModle>(context);
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context);

    Size size = MediaQuery.of(context).size;

    // Build slide image lists from the latest slideViewModel data on each rebuild
    listTopSlideImages = slideViewModel.listSlideTop
        .map((e) => e.imageUrl)
        .toList();
    listBottomSlideImages = slideViewModel.listSlideBottom
        .map((e) => e.imageUrl)
        .toList();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColor.appBarColor,
        title: Text('Find UP', style: textHelper.textAppBarStyle()),
        actions: [
          GestureDetector(
            onTap: () async {
              Navigation.goPage(context: context, page: FilterPage());
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigation.goPage(context: context, page: LanguagePage());
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/icons/translation.png',
                width: 24,
                height: 24,
              ),
            ),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              if (LocalStorage.userModel != null) {
                Navigation.goPage(context: context, page: ProfilePage());
              } else {
                Navigation.goPage(context: context, page: LoginPage());
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.person, size: 28),
            ),
          ),
        ],
      ),
      body: Stack(
              children: [
                SizedBox(
                  width: size.width,
                  height: size.height,
                  child: SingleChildScrollView(
                    controller: _controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slide ADS
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 8,
                            right: 8,
                          ),
                          child: helper.buildSlideAdvertise(
                            loadingPathTemp: 'assets/slide/top_slide1.png',
                            radius: 0,
                            imgList: listTopSlideImages,
                            height: checkScreen.isTablet(context)
                                ? (33 / 100) * size.height
                                : (25 / 100) * size.height,
                          ),
                        ),

                        // horizontal group category
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GroupCategHorizonScroll(
                            listGroupCategory:
                                groupCategoryViewModel.lisGroupCategoryModel,
                            onTab: (item) {
                              Helper.groupCategoryID = item.id;

                              keyTitle.value = item.keyTranslate;
                              groupCategoryViewModel.tabCategory(item);
                              subCategoryViewModle.getFilterSubcategory(
                                groupCategoryID: item.id,
                              );
                              productModelViewModel.getProductByGroupCategory(
                                groupCategoryID: item.id,
                                userId: LocalStorage.userModel == null
                                    ? 0
                                    : LocalStorage.userModel!.id,
                              );
                            },
                          ),
                        ),
                        // Grid Category
                        CategoryGridItem(
                          itemPerRow: 4,
                          itemsPerPage:
                              subCategoryViewModle.listFilterSubCategory.length,
                          subCategoryList:
                              subCategoryViewModle.listFilterSubCategory,
                          calBack: (subCategoryModel) {
                            Navigation.goPage(
                              context: context,
                              page: GroupPlaceListPage(
                                subCategoryModel: subCategoryModel,
                              ),
                            );
                          },
                        ),
                        // bottom slide
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: helper.buildSlideAdvertise(
                            loadingPathTemp: 'assets/slide/bottom_slide1.png',
                            radius: 16,
                            imgList: listBottomSlideImages,
                            height: checkScreen.isTablet(context)
                                ? (33 / 100) * size.height
                                : (25 / 100) * size.height,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Top show
                        productModelViewModel.isLoading
                            ? SizedBox()
                            : topShowSection(
                                subCategoryViewModle: subCategoryViewModle,
                                productModelViewModel: productModelViewModel,
                                context: context,
                                onSeeAll: (subCategoryViewModle) {
                                  for (var item
                                      in subCategoryViewModle
                                          .listFilterSubCategory) {
                                    item.is_selected = false;
                                  }
                                  Navigation.goPage(
                                    context: context,
                                    page: SeeAllTopShowPage(
                                      subCategoryViewModle:
                                          subCategoryViewModle,
                                    ),
                                  );
                                },
                              ),
                        // list post card
                        productModelViewModel.isLoading
                            ? SizedBox()
                            : listCardPost(
                                productModelViewModel: productModelViewModel,
                                size: size,
                                title: Translator.translate(keyTitle.value),
                                subCategoryViewModle: subCategoryViewModle,
                                seeMoreTab: () {
                                  // Clear selected
                                  for (var item
                                      in subCategoryViewModle
                                          .listFilterSubCategory) {
                                    item.is_selected = false;
                                  }
                                  Navigation.goPage(
                                    context: context,
                                    page: SeeAllProductPage(
                                      subCategoryViewModle:
                                          subCategoryViewModle,
                                      title: keyTitle.value,
                                      groupCategoryID: Helper.groupCategoryID,
                                    ),
                                  );
                                },
                              ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget listCardPost({
    required ProductModelViewModel productModelViewModel,
    required Size size,
    required String title,
    required SubCategoryViewModle subCategoryViewModle,
    required Function() seeMoreTab,
  }) {
    return productModelViewModel.listProductByGroupCategory.isEmpty
        ? NoItemTextWidget()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: keyTitle,
                      builder: (context, value, child) {
                        return Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: seeMoreTab,
                      child: Container(
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 5,
                            bottom: 5,
                          ),
                          child: Text(
                            Translator.translate('see_all'),
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              ListView.builder(
                physics:
                    NeverScrollableScrollPhysics(), // disable inner scrolling
                shrinkWrap: true, // important!
                itemCount:
                    productModelViewModel.listProductByGroupCategory.length,
                itemBuilder: (context, index) {
                  ProductModel productModel =
                      productModelViewModel.listProductByGroupCategory[index];
                  List<String> listImage = helper.productModelSplitImage(
                    product: productModel,
                    path: 'property',
                    context: context,
                  );
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: LargeCardItemElement(
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
                      ),
                      helper.borderCustom(size: size),
                    ],
                  );
                },
              ),
            ],
          );
  }

  Widget topShowSection({
    required SubCategoryViewModle subCategoryViewModle,
    required ProductModelViewModel productModelViewModel,
    required BuildContext context,
    required Function(SubCategoryViewModle subCategoryViewModle) onSeeAll,
  }) {
    return subCategoryViewModle.listFilterSubCategory.isEmpty
        ? SizedBox()
        : productModelViewModel.listTopShowHomePage.isEmpty
        ? SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Translator.translate('recommended'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Clear selected
                        onSeeAll(subCategoryViewModle);
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 5,
                            bottom: 5,
                          ),
                          child: Text(
                            Translator.translate('see_all'),
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: productModelViewModel.listTopShowHomePage
                        .map(
                          (product) => BoostCardItemElement(
                            onTab: () {
                              Navigation.goPage(
                                context: context,
                                page: ProductItemDetailPage(
                                  productModel: product,
                                ),
                              );
                            },
                            isAssets: false,
                            imageUrl: helper
                                .productModelSplitImage(
                                  product: product,
                                  path: 'property',
                                  context: context,
                                )
                                .first,
                            price: product.basePrice,
                            billingPeriod: product.billingPeriod,
                            title: Translator.translate(product.keyTranslate),
                            location:
                                product.fullAddress,
                            discount: '',
                            userProfileImage: product.userProfile,

                            userName: product.userName,
                            timeAgo: '${product.timeAgo} ago',
                            bathCount: product.bathCount,
                            bedCount: product.bedCount,
                            size: product.size,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          );
  }
}

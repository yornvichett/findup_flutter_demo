import 'dart:math' as CupertinoIcons;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/Storage/refresh_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/notification_service.dart';
import 'package:findup_mvvm/Core/services/telegram_bot.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/boost_dialog_element.dart';
import 'package:findup_mvvm/Core/utils/cache_profile_image.dart';
import 'package:findup_mvvm/Core/utils/edit_profile_dialog_element.dart';
import 'package:findup_mvvm/Core/utils/large_card_item_element.dart';
import 'package:findup_mvvm/Core/utils/Loading/simmer_loader_element.dart';

import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
import 'package:findup_mvvm/Data/view_models/general_product_view_model.dart';
import 'package:findup_mvvm/Data/view_models/group_category_view_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/refresh_version_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/_Chat/Admin/list_all_user_chat_page.dart';
import 'package:findup_mvvm/Pages/_Chat/User/user_chat_page.dart';
import 'package:findup_mvvm/Pages/_Profile/Add_Product/sale_type_page.dart';

import 'package:findup_mvvm/Pages/_Profile/Verify_Center/verify_center_page.dart';
import 'package:findup_mvvm/Pages/_Profile/Edit_Product/edit_page.dart';
import 'package:findup_mvvm/Pages/_Profile/Add_Product/add_product_group_category_page.dart';
import 'package:findup_mvvm/Core/utils/profile_header_widget.dart';
import 'package:findup_mvvm/Pages/_Profile/Profile_Owner/your_boost_page.dart';
import 'package:findup_mvvm/Pages/_Profile/edit_profile_page.dart';

import 'package:findup_mvvm/Pages/product_item_detail_page.dart';
import 'package:findup_mvvm/Pages/setting_page.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int userID = LocalStorage.userModel!.id;

  RefreshStorage refreshStorage = RefreshStorage();
  RefreshVersionViewModel refreshVersionViewModel = RefreshVersionViewModel();
  Map<String, dynamic> localGroupCategoryVersion = {};
  bool allowRefresh = false;

  List<Map<String, dynamic>> listOptionControll = [
    {
      'id': 0,
      'value': 'Delete',
      'title': 'Delete',
      'icon': Icons.delete,
      'color': Colors.red,
    },
    {
      'id': 1,
      'value': 'Edit',
      'title': 'Edit',
      'icon': Icons.edit,
      'color': Colors.green,
    },
    {
      'id': 2,
      'value': 'Renew',
      'title': 'Renew',
      'icon': Icons.autorenew,
      'color': const Color.fromARGB(255, 140, 106, 5),
    },
  ];

  NotificationService notificationService = NotificationService();
  TelegramBot telegramBot = TelegramBot();

  Future<void> pushDataAlertToAdmin({
    required UserViewModel userViewModel,
    required ProductModel productModelCallBack,
    required Map<String, dynamic> val,
  }) async {
    try {
      telegramBot.sendMessageToTelegram(
        '''📱💸USER CHECK OUT BOOST PAYMENT (${helper.getFormattedDateTime()})
                          User Info : ${userViewModel.userModel!.name} (${userViewModel.userModel!.id})
                          Product ID: ${productModelCallBack.id}
                          =========================
                          Total     : ${val['price']}\$
                          Day Count : ${val['days']}d
                          Status    : Check Out''',
      );
      Navigator.pop(context);
    } catch (e) {}
  }

  TextHelper textHelper = TextHelper();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      RefreshStorage.getGroupCategoryVersion().then((value) {
        localGroupCategoryVersion = value;
      });
      Provider.of<ProductModelViewModel>(
        context,
        listen: false,
      ).getUserProduct(userID: LocalStorage.userModel!.id);
      Provider.of<UserViewModel>(
        context,
        listen: false,
      ).getUserInfo(userID: userID);

      refreshVersionViewModel.getRefreshVersion();
      // appConfigViewModel = context.read<AppConfigViewModel>();
      context.read<UserViewModel>().getAdminInfo();
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // 👇 Always dispose controllers
    _tabController.dispose();
    super.dispose();
  }

  Helper helper = Helper();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double heightAds = MediaQuery.of(context).size.height * 0.3;
    UserViewModel userViewModel = Provider.of<UserViewModel>(context);
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.blue,
        strokeWidth: 3,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          context.read<UserViewModel>().getAdminInfo();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: size.width,
                    height: 250,
                    imageUrl: userViewModel.userModel!.coverImage,
                    placeholder: (context, url) {
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) => Container(
                      width: size.width,
                      height: 250,
                      color: Colors.grey.shade200,
                      child: Center(child: Icon(Icons.image)),
                    ),
                  ),
                  Container(
                    width: size.width,
                    height: 250,

                    color: const Color.fromARGB(41, 0, 0, 0),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 10,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey[100],
                      
                      child: CacheProfileImage(
                        
                        userProfileImage: userViewModel.userModel!.userProfile,
                        radius: 45,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          circualrIcon(
                            onTab: () {
                              Navigator.pop(context);
                            },
                            icon: Icons.arrow_back_ios_new_outlined,
                          ),
                          Row(
                            children: [
                              circualrIcon(
                                iconSize: 26,
                                onTab: () {
                                  if (userViewModel.userModel?.role ==
                                      'admin') {
                                    Navigation.goPage(
                                      context: context,
                                      page: ListAllUserChatPage(
                                        userAdmin: userViewModel.userAdmin!,
                                      ),
                                    );
                                  } else {
                                    Navigation.goPage(
                                      context: context,
                                      page: UserChatPage(
                                        userModel: userViewModel.userModel!,
                                        userAdmin: userViewModel.userAdmin!,
                                      ),
                                    );
                                  }
                                },
                                icon: Icons.wechat_rounded,
                              ),
                              SizedBox(width: 10),
                              circualrIcon(
                                iconSize: 26,
                                onTab: () async {
                                  await telegramBot.contactViaTelegram(
                                    telegramUrl:
                                        "https://t.me/${userViewModel.userAdmin?.telegram}",
                                  );
                                },
                                icon: Icons.telegram,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          userViewModel.userModel!.name,
                          style: textHelper.textAppBarStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.person, color: Colors.green),
                      ],
                    ),
                    userViewModel.userModel!.bioTitle == 'none'
                        ? Text('No bio', style: TextStyle(color: Colors.grey))
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              userViewModel.userModel!.bioTitle,
                              style: GoogleFonts.aBeeZee(),
                            ),
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigation.goPage(
                            context: context,
                            page: AddProductGroupCategoryPage(),
                          );
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xff344a58),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              Translator.translate('add_post'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigation.goPage(
                            context: context,
                            page: EditProfilePage(userViewModel: userViewModel),
                          );
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 5, 127, 226),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              Translator.translate('edit_profile'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigation.goPage(
                          context: context,
                          page: SettingPage(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(Icons.settings),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: productModelViewModel.listUserProduct.length,
                itemBuilder: (context, index) {
                  ProductModel product =
                      productModelViewModel.listUserProduct[index];
                  List<String> listImg = helper.productModelSplitImage(
                    product: product,
                    path: 'property',
                    context: context,
                  );
                  return Column(
                    children: [
                      LargeCardItemElement(
                        allowProfileTab: false,
                        showOptionControllItem: true,
                        productModel: product,
                        isShowID: true,
                        totalPoint: userViewModel.userModel!.point,
                        userID: userViewModel.userModel!.id,
                        productModelViewModel: productModelViewModel,
                        userViewModel: userViewModel,

                        onBoost: (productModelCallBack) {
                          if (productModelCallBack.allowBoost == 0) {
                            helper.showModernDialog(
                              iconSize: 40,
                              textAlign: TextAlign.center,

                              context,
                              title: Translator.translate('access_required'),
                              tabOutSide: false,
                              color: const Color.fromARGB(255, 223, 221, 221),
                              icon: Icons.lock_outline,
                              subTitle:
                                  "${Translator.translate('this_feature_is_locked')}.\n${Translator.translate('contact_to_support_to_unlock_it')}.",
                              onConfirm: () async {},
                            );
                          } else if (productModelCallBack.allowBoost == 1) {
                            showDialog(
                              context: context,
                              builder: (context) => BoostDialogElement(
                                //totalPoint: totalPoint,
                                onCallBackAction: (val) async {
                                  await productModelViewModel
                                      .boostPenddingInsert(
                                        productID: productModelCallBack.id,
                                        userID: userID,
                                        boostDay: val['days'],
                                        total: val['price'],
                                      );
                                  // push to admin
                                  await pushDataAlertToAdmin(
                                    productModelCallBack: productModelCallBack,
                                    userViewModel: userViewModel,
                                    val: val,
                                  );
                                },
                              ),
                            );
                          }
                          if (productModelCallBack.isBoostPending == 1) {
                            Navigation.goPage(
                              context: context,
                              page: YourBoostPage(userViewModel: userViewModel),
                            );
                          }
                        },
                        manageOptionTab: (valCalBack) async {
                          if (valCalBack['id'] == 0) {
                            helper.showModernDialog(
                              iconSize: 40,
                              textAlign: TextAlign.center,

                              context,
                              title:
                                  "${Translator.translate('remove')} #${valCalBack['item_id']}",
                              tabOutSide: false,
                              color: const Color.fromARGB(255, 223, 221, 221),
                              icon: Icons.delete,
                              subTitle: Translator.translate(
                                'item_will_be_remove_from_your_list',
                              ),
                              onConfirm: () async {
                                bool isRemove = await productModelViewModel
                                    .removeProduct(
                                      userID: userID,
                                      productID: product.id,
                                      fileName: product.imageList,
                                    );
                                if (isRemove) {
                                  Navigator.pop(context);
                                  helper.showSuccessScreen(context: context);
                                }
                              },
                            );
                          } else if (valCalBack['id'] == 1) {
                            Navigation.goPage(
                              context: context,
                              page: EditPage(
                                productDefaultParam: product,
                                userViewModel: userViewModel,
                              ),
                            );
                          } else if (valCalBack['id'] == 2) {
                            if (product.reNewStatus == 0) {
                              helper.showAlertDialog(context);
                            } else {
                              await productModelViewModel
                                  .renewProduct(product_id: product.id)
                                  .then((value) {
                                    if (value) {
                                      productModelViewModel.getUserProduct(
                                        userID: userID,
                                      );
                                      helper.showAlertDialog(
                                        context,
                                        title: "Renew Success",
                                        subTitle:
                                            "You have ${product.reNewLimit - 1 == 0 ? 'no' : product.reNewLimit} more for renew",
                                        icon:
                                            Icons.check_circle_outline_outlined,
                                        color: Colors.green,
                                      );
                                    }
                                  });
                            }
                          }
                        },
                        listOptioinControllItem: listOptionControll,
                        images: listImg,
                        onTab: () {
                          Navigation.goPage(
                            context: context,
                            page: ProductItemDetailPage(productModel: product),
                          );
                        },
                      ),
                      helper.borderCustom(size: size),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget circualrIcon({required Function() onTab, required IconData icon,double iconSize=19}) {
    return GestureDetector(
      onTap: onTab,
      child: Container(
        width: 40,
        height: 40,

        decoration: BoxDecoration(
          color: const Color.fromARGB(184, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.black, size: iconSize),
        ),
      ),
    );
  }

  Widget textIcon({required IconData icon, required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [Icon(icon, size: 17), SizedBox(width: 10), Text(title)],
    );
  }
}

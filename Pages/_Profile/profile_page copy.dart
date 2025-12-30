// import 'dart:math' as CupertinoIcons;
// import 'package:findup_mvvm/Core/Storage/refresh_storage.dart';
// import 'package:findup_mvvm/Core/constants/app_color.dart';
// import 'package:findup_mvvm/Core/navigation/navigation.dart';
// import 'package:findup_mvvm/Core/services/helper.dart';
// import 'package:findup_mvvm/Core/services/local_storage.dart';
// import 'package:findup_mvvm/Core/services/notification_service.dart';
// import 'package:findup_mvvm/Core/services/telegram_bot.dart';
// import 'package:findup_mvvm/Core/services/translate.dart';
// import 'package:findup_mvvm/Core/utils/boost_dialog_element.dart';
// import 'package:findup_mvvm/Core/utils/edit_profile_dialog_element.dart';
// import 'package:findup_mvvm/Core/utils/large_card_item_element.dart';
// import 'package:findup_mvvm/Core/utils/Loading/simmer_loader_element.dart';

// import 'package:findup_mvvm/Data/models/product_model.dart';
// import 'package:findup_mvvm/Data/models/sub_category_model.dart';
// import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
// import 'package:findup_mvvm/Data/view_models/general_product_view_model.dart';
// import 'package:findup_mvvm/Data/view_models/group_category_view_model.dart';
// import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
// import 'package:findup_mvvm/Data/view_models/refresh_version_view_model.dart';
// import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
// import 'package:findup_mvvm/Pages/_Chat/Admin/list_all_user_chat_page.dart';
// import 'package:findup_mvvm/Pages/_Chat/User/user_chat_page.dart';

// import 'package:findup_mvvm/Pages/_Profile/Verify_Center/verify_center_page.dart';
// import 'package:findup_mvvm/Pages/_Profile/Edit_Product/edit_page.dart';
// import 'package:findup_mvvm/Pages/_Profile/Add_Product/add_product_group_category_page.dart';
// import 'package:findup_mvvm/Core/utils/profile_header_widget.dart';
// import 'package:findup_mvvm/Pages/_Profile/Profile_Owner/your_boost_page.dart';
// import 'package:findup_mvvm/Pages/_Profile/edit_profile_page.dart';

// import 'package:findup_mvvm/Pages/product_item_detail_page.dart';
// import 'package:findup_mvvm/Pages/setting_page.dart';

// import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';

// class ProfilePage extends StatefulWidget {
//   ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   int userID = LocalStorage.userModel!.id;

//   RefreshStorage refreshStorage = RefreshStorage();
//   RefreshVersionViewModel refreshVersionViewModel = RefreshVersionViewModel();
//   Map<String, dynamic> localGroupCategoryVersion = {};
//   bool allowRefresh = false;

//   List<Map<String, dynamic>> listOptionControll = [
//     {
//       'id': 0,
//       'value': 'Delete',
//       'title': 'Delete',
//       'icon': Icons.delete,
//       'color': Colors.red,
//     },
//     {
//       'id': 1,
//       'value': 'Edit',
//       'title': 'Edit',
//       'icon': Icons.edit,
//       'color': Colors.green,
//     },
//     {
//       'id': 2,
//       'value': 'Renew',
//       'title': 'Renew',
//       'icon': Icons.autorenew,
//       'color': const Color.fromARGB(255, 140, 106, 5),
//     },
//   ];
//   String saleType = "";
//   NotificationService notificationService = NotificationService();
//   TelegramBot telegramBot = TelegramBot();

//   Future<void> pushDataAlertToAdmin({
//     required UserViewModel userViewModel,
//     required ProductModel productModelCallBack,
//     required Map<String, dynamic> val,
//   }) async {
//     try {
//       telegramBot.sendMessageToTelegram(
//         '''📱💸USER CHECK OUT BOOST PAYMENT (${helper.getFormattedDateTime()})
//                           User Info : ${userViewModel.userModel!.name} (${userViewModel.userModel!.id})
//                           Product ID: ${productModelCallBack.id}
//                           =========================
//                           Total     : ${val['price']}\$
//                           Day Count : ${val['days']}d
//                           Status    : Check Out''',
//       );
//       Navigator.pop(context);
//     } catch (e) {}
//   }

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       RefreshStorage.getGroupCategoryVersion().then((value) {
//         localGroupCategoryVersion = value;
//       });
//       Provider.of<ProductModelViewModel>(
//         context,
//         listen: false,
//       ).getUserProduct(userID: LocalStorage.userModel!.id);
//       Provider.of<UserViewModel>(
//         context,
//         listen: false,
//       ).getUserInfo(userID: userID);

//       refreshVersionViewModel.getRefreshVersion();
//       // appConfigViewModel = context.read<AppConfigViewModel>();
//       context.read<UserViewModel>().getAdminInfo();
//     });

//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     // 👇 Always dispose controllers
//     _tabController.dispose();
//     super.dispose();
//   }

//   Helper helper = Helper();

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     UserViewModel userViewModel = Provider.of<UserViewModel>(context);
//     ProductModelViewModel productModelViewModel =
//         Provider.of<ProductModelViewModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxScrolled) => [
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: Colors.white,
//             elevation: 0.5,
//             expandedHeight: 350,
//             iconTheme: IconThemeData(color: Color(0xff344a58)),
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 userViewModel.userModel!.role == 'admin'
//                     ? helper.iconButton(
//                         iconsData: Icons.notification_add_sharp,
//                         onTab: () {
//                           Navigation.goPage(
//                             context: context,
//                             page: VerifyCenterPage(),
//                           );
//                         },
//                       )
//                     : helper.iconButton(
//                         iconsData: Icons.contact_support_outlined,
//                         onTab: () async {
                      
//                           await telegramBot.contactViaTelegram(
//                             telegramUrl:
//                                 "https://t.me/${userViewModel.userAdmin?.telegram}",
//                           );
//                         },
//                       ),
//               ],
//             ),
//             actions: [
//               GestureDetector(
//                 onTap: () {
//                   Navigation.goPage(context: context, page: SettingPage());
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
//                   child: Icon(Icons.settings, size: 27),
//                 ),
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: ProfileHeaderWidget(
//                 userEmail: userViewModel.userModel!.firstPhoneNumber == 'none'
//                     ? userViewModel.userModel!.email
//                     : userViewModel.userModel!.firstPhoneNumber,
//                 userName: userViewModel.userModel!.name,
//                 userProfile: userViewModel.userModel!.userProfile,
//                 postCount: productModelViewModel.isLoading
//                     ? 0
//                     : productModelViewModel.listUserProduct.length,
//                 userPoint: productModelViewModel.isLoading
//                     ? '0'
//                     : '${userViewModel.userModel!.point.toString()} ',
//                 addSaleTab: () {
//                   if (userViewModel.userModel!.checkVerify == 'Rejected') {
//                     helper.showAccountCheckingPopup(
//                       context: context,
//                       onTab: () {
//                         Navigator.pop(context);
//                       },
//                     );
//                   } else {
//                     saleType = "Sale";
//                     Navigation.goPage(
//                       context: context,
//                       page: AddProductGroupCategoryPage(
//                         saleType: saleType,
                      
//                         serverVersion: 0,
//                       ),
//                     );
//                   }
//                 },
//                 addRentTab: () {
//                   if (userViewModel.userModel!.checkVerify == 'Rejected') {
//                     helper.showAccountCheckingPopup(
//                       context: context,
//                       onTab: () {
//                         Navigator.pop(context);
//                       },
//                     );
//                   } else {
//                     saleType = "Rent";
//                     Navigation.goPage(
//                       context: context,
//                       page: AddProductGroupCategoryPage(
//                         saleType: saleType,
                      
//                         serverVersion: 0,
//                       ),
//                     );
//                   }
//                 },
//                 onEdit: () {
//                  // Navigation.goPage(context: context, page: EditProfilePage());
//                   showDialog(
//                     context: context,
//                     builder: (context) => EditProfileDialogElement(
//                       //totalPoint: totalPoint,
//                       onConfirm: (imagePath) async {
//                         await userViewModel.uploadImageProfile(
//                           imagePath: imagePath,
//                           username: LocalStorage.userModel!.name,
//                           userID: LocalStorage.userModel!.id,
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//             bottom: tabViewClick(prodcutModelViewModel: productModelViewModel),
//           ),
//         ],
//         body: productModelViewModel.isLoading
//             ? SizedBox()
//             : tabViewBody(
//                 size: size,
//                 userViewModel: userViewModel,
//                 listProductModel: productModelViewModel.listUserProduct,
//                 productViewModel: productModelViewModel,
//               ),
//       ),
//     );
//   }

//   PreferredSizeWidget? tabViewClick({
//     required ProductModelViewModel prodcutModelViewModel,
//   }) {
//     return TabBar(
//       dividerColor: Colors.transparent,
//       controller: _tabController,
//       indicatorColor: Colors.transparent,
//       labelColor: Colors.red,
//       unselectedLabelColor: Colors.grey[600],

//       tabs: [
//         Tab(
//           text:
//               '${Translator.translate('my_post')} (${prodcutModelViewModel.listUserProduct.length}${Translator.translate('posts')})',
//         ),
//         Tab(text: Translator.translate('support')),
//       ],
//     );
//   }

//   Widget tabViewBody({
//     required List<ProductModel> listProductModel,
//     required UserViewModel userViewModel,
//     required ProductModelViewModel productViewModel,
//     required Size size,
//   }) {
//     return TabBarView(
//       controller: _tabController,
//       children: [
//         myPostList(
//           size: size,
//           lsitProduct: listProductModel,
//           userViewModel: userViewModel,
//           productModelViewModel: productViewModel,
//         ),
//         Center(
//           child: GestureDetector(
//             onTap: () {
//               if (userViewModel.userModel?.role == 'admin') {
//                 Navigation.goPage(
//                   context: context,
//                   page: ListAllUserChatPage(
//                     userAdmin: userViewModel.userAdmin!,
//                   ),
//                 );
//               } else {
//                 Navigation.goPage(
//                   context: context,
//                   page: UserChatPage(
//                     userModel: userViewModel.userModel!,
//                     userAdmin: userViewModel.userAdmin!,
//                   ),
//                 );
//               }
//             },
//             child: Container(
//               width: size.width,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/background/bg3.png'),
//                   fit: BoxFit.cover,
//                   colorFilter: ColorFilter.mode(
//                     Colors.blue.withOpacity(
//                       0.1,
//                     ), // 0.0 = fully transparent, 1.0 = normal
//                     BlendMode.modulate,
//                   ),
//                 ),
//               ),
//               child: chatSection(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget chatSection() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.blueAccent,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//             ],
//             gradient: LinearGradient(
//               colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 28),
//             ],
//           ),
//         ),
//         SizedBox(height: 10),
//         Text(Translator.translate('free_support')),
//       ],
//     );
//   }

//   Widget myPostList({
//     required List<ProductModel> lsitProduct,
//     required UserViewModel userViewModel,
//     required ProductModelViewModel productModelViewModel,
//     required Size size,
//   }) {
//     return SingleChildScrollView(
//       child: Column(
//         children: lsitProduct.map((product) {
//           List<String> listImg = helper.productModelSplitImage(
//             product: product,
//             path: 'property',
//             context: context,
//           );
//           return Column(
//             children: [
//               LargeCardItemElement(
//                 allowProfileTab: false,
//                 showOptionControllItem: true,
//                 productModel: product,
//                 isShowID: true,
//                 totalPoint: userViewModel.userModel!.point,
//                 userID: userViewModel.userModel!.id,
//                 productModelViewModel: productModelViewModel,
//                 userViewModel: userViewModel,

//                 onBoost: (productModelCallBack) {
//                   if (productModelCallBack.allowBoost == 0) {
//                     helper.showModernDialog(
//                       iconSize: 40,
//                       textAlign: TextAlign.center,

//                       context,
//                       title: Translator.translate('access_required'),
//                       tabOutSide: false,
//                       color: const Color.fromARGB(255, 223, 221, 221),
//                       icon: Icons.lock_outline,
//                       subTitle:
//                           "${Translator.translate('this_feature_is_locked')}.\n${Translator.translate('contact_to_support_to_unlock_it')}.",
//                       onConfirm: () async {},
//                     );
//                   } else if (productModelCallBack.allowBoost == 1) {
//                     showDialog(
//                       context: context,
//                       builder: (context) => BoostDialogElement(
//                         //totalPoint: totalPoint,
//                         onCallBackAction: (val) async {
//                           await productModelViewModel.boostPenddingInsert(
//                             productID: productModelCallBack.id,
//                             userID: userID,
//                             boostDay: val['days'],
//                             total: val['price'],
//                           );
//                           // push to admin
//                           await pushDataAlertToAdmin(
//                             productModelCallBack: productModelCallBack,
//                             userViewModel: userViewModel,
//                             val: val,
//                           );
//                         },
//                       ),
//                     );
//                   } 
//                   if (productModelCallBack.isBoostPending == 1) {
//                     Navigation.goPage(
//                       context: context,
//                       page: YourBoostPage(userViewModel: userViewModel),
//                     );
//                   }
//                 },
//                 manageOptionTab: (valCalBack) async {
//                   if (valCalBack['id'] == 0) {
//                     helper.showModernDialog(
//                       iconSize: 40,
//                       textAlign: TextAlign.center,

//                       context,
//                       title:
//                           "${Translator.translate('remove')} #${valCalBack['item_id']}",
//                       tabOutSide: false,
//                       color: const Color.fromARGB(255, 223, 221, 221),
//                       icon: Icons.delete,
//                       subTitle: Translator.translate(
//                         'item_will_be_remove_from_your_list',
//                       ),
//                       onConfirm: () async {
//                         bool isRemove = await productModelViewModel
//                             .removeProduct(
//                               userID: userID,
//                               productID: product.id,
//                               fileName: product.imageList,
//                             );
//                         if (isRemove) {
//                           Navigator.pop(context);
//                           helper.showSuccessScreen(context: context);
//                         }
//                       },
//                     );
//                     // helper.showAlertOption(
//                     //   context,
//                     //   title:
//                     //       "${Translator.translate('remove')} #${valCalBack['item_id']}",
//                     //   subTitle: Translator.translate(
//                     //     'item_will_be_remove_from_your_list',
//                     //   ),
//                     //   icon: Icons.delete,
//                     //   color: const Color.fromARGB(255, 223, 221, 221),
//                     //   onConfirm: () async {
//                     //     bool isRemove = await productModelViewModel
//                     //         .removeProduct(
//                     //           userID: userID,
//                     //           productID: product.id,
//                     //           fileName: product.imageList,
//                     //         );
//                     //     if (isRemove) {
//                     //       Navigator.pop(context);
//                     //       helper.showSuccessScreen(context: context);
//                     //     }
//                     //   },
//                     // );
//                   } else if (valCalBack['id'] == 1) {
//                     Navigation.goPage(
//                       context: context,
//                       page: EditPage(
//                         productDefaultParam: product,
//                         userViewModel: userViewModel,
//                       ),
//                     );
//                   } else if (valCalBack['id'] == 2) {
//                     if (product.reNewStatus == 0) {
//                       helper.showAlertDialog(context);
//                     } else {
//                       await productModelViewModel
//                           .renewProduct(product_id: product.id)
//                           .then((value) {
//                             if (value) {
//                               productModelViewModel.getUserProduct(
//                                 userID: userID,
//                               );
//                               helper.showAlertDialog(
//                                 context,
//                                 title: "Renew Success",
//                                 subTitle:
//                                     "You have ${product.reNewLimit - 1 == 0 ? 'no' : product.reNewLimit} more for renew",
//                                 icon: Icons.check_circle_outline_outlined,
//                                 color: Colors.green,
//                               );
//                             }
//                           });
//                     }
//                   }
//                 },
//                 listOptioinControllItem: listOptionControll,
//                 images: listImg,
//                 onTab: () {
//                   Navigation.goPage(
//                     context: context,
//                     page: ProductItemDetailPage(productModel: product),
//                   );
//                 },
//               ),
//               helper.borderCustom(size: size),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

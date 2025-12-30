import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/boost_dialog_element.dart';
import 'package:findup_mvvm/Core/utils/facebook_image_style_element.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:findup_mvvm/Data/view/product_model_view.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/_Chat/User/user_chat_page.dart';
import 'package:findup_mvvm/Pages/_Profile/profile_page.dart';
import 'package:findup_mvvm/Pages/_Profile/Profile_Owner/your_boost_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class LargeCardItemElement extends StatelessWidget {
  final List<String> images;

  bool isAssets;

  List<Map<String, dynamic>>? listOptioinControllItem;
  Function(Map<String, dynamic> valCalBack)? manageOptionTab;
  final Function()? onTab;
  Function(ProductModel productModel)? onBoost;

  bool showOptionControllItem;
  Function()? onGoProfile;
  ProductModel productModel;
  bool allowProfileTab;
  bool isShowID;
  int totalPoint;
  int userID;
  ProductModelViewModel? productModelViewModel;
  UserViewModel? userViewModel;

  LargeCardItemElement({
    super.key,
    this.productModelViewModel,
    this.userViewModel,
    required this.productModel,
    required this.images,
    this.allowProfileTab = true,
    this.listOptioinControllItem,
    this.isShowID = false,
    this.manageOptionTab,
    this.totalPoint = 0,
    this.isAssets = true,
    this.showOptionControllItem = false,
    this.onGoProfile,
    this.onTab,
    this.userID = 0,
    this.onBoost,
  });

  Helper helper = Helper();

  @override
  Widget build(BuildContext context) {
    String strID = '${productModel.id}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
      child: GestureDetector(
        onTap: onTab,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Profile + Menu
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: allowProfileTab == false
                        ? () {}
                        : () {
                            if (LocalStorage.userModel != null) {
                              if (productModel.userId ==
                                  LocalStorage.userModel?.id) {
                                Navigation.goPage(
                                  context: context,
                                  page: ProfilePage(),
                                );
                              } else {
                                onGoProfile!();
                              }
                            } else {
                              onGoProfile!();
                            }
                          },
                    child: Row(
                      children: [
                        
    
                        CircleAvatar(
                          radius: 20.5,
                          backgroundColor: const Color.fromARGB(89, 0, 0, 0),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: productModel.userProfile,
                              placeholder: (context, url) =>
                                  Image.asset('assets/images/user_default.png',fit: BoxFit.cover,),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productModel.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${productModel.timeAgo} ${Translator.translate('ago')}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      productModel.boostStatus == 1
                          ? Icon(
                              Icons.hotel_class_sharp,
                              color: const Color.fromARGB(255, 215, 162, 2),
                            )
                          : SizedBox(),
                      productModel.isBoostPending == 1
                          ? SizedBox()
                          : showOptionControllItem
                          ? PopupMenuButton<String>(
                              color: Colors.white,
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              onSelected: (value) {
                                final selectedItem = listOptioinControllItem!
                                    .firstWhere(
                                      (item) => item['value'] == value,
                                      orElse: () => {},
                                    );
                                selectedItem['item_id'] = strID;
                                manageOptionTab!(selectedItem);
                              },
                              itemBuilder: (context) {
                                return listOptioinControllItem!.map<
                                  PopupMenuEntry<String>
                                >((item) {
                                  return PopupMenuItem<String>(
                                    value: item['value'] as String,
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: item['id'] == 2 ? 2 : 0,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                item['icon'] as IconData,
                                                color: item['color'],
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                Translator.translate(
                                                  item['title']
                                                      .toString()
                                                      .toLowerCase(),
                                                ),
                                                style: TextStyle(
                                                  color: item['color'],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        item['id'] == 2
                                            ? Positioned(
                                                bottom: 15,
                                                right: 0,
                                                child: Text(
                                                  '${productModel.reNewCount}/${productModel.reNewLimit}',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: item['color'],
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
    
            // 🖼 Images
            Stack(
              children: [
                FacebookImageStyleElement(images: images),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: productModel.saleType.toLowerCase() == 'sale'
                          ? Colors.orange.shade700
                          : Colors.blue.shade600,
    
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      Translator.translate(productModel.saleType.toLowerCase()),
    
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    
            // 🏠 Post Info
            Padding(
              padding: const EdgeInsets.only(left: 12,top: 10,bottom: 22,right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏷️ Title
                  Text(
                    Translator.translate(productModel.keyTranslate),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    textWidthBasis: TextWidthBasis.longestLine,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      productModel.subTitle,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                  ),
    
                  const SizedBox(height: 6),
    
                  // 💰 Price
                  Text(
                    '${helper.currencyFormat(number: productModel.basePrice)}${productModel.billingPeriod}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
    
                  // 📍 Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_city,
                        color: Color.fromARGB(255, 121, 121, 121),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          productModel.fullAddress, // your text here
                          maxLines: 2, // limit to 1 line
                          overflow: TextOverflow.ellipsis, // show ...
                          softWrap: false, // prevent wrapping
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          isShowID
                              ? Text(
                                  'ID: $strID', // your text here
                                  maxLines: 1, // limit to 1 line
                                  overflow: TextOverflow.ellipsis, // show ...
                                  softWrap: false, // prevent wrapping
                                  style: TextStyle(color: Colors.black),
                                )
                              : SizedBox(),
                        ],
                      ),
                      showOptionControllItem == false ||
                              productModel.boostStatus == 1
                          ? SizedBox()
                          : boostButton(
                              onTab: () {
                                onBoost!(productModel);
                              },
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget boostButton({required Function() onTab}) {
    return GestureDetector(
      onTap: onTab,
      child: Container(
        // color noted
        decoration: BoxDecoration(
          border: Border.all(
            color: productModel.boostPendingStatus == 'Verify Checking...'
                ? Colors.blue
                : Colors.amber.shade800,
            width: 2,
          ),
          color: productModel.boostPendingStatus == 'Verify Checking...'
              ? Colors.green
              : Color(0xff344a58),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 7,
            bottom: 7,
          ),
          child: Center(
            child: Text(
              productModel.isBoostPending == 1
                  ? Translator.translate(productModel.boostPendingStatus)
                  : Translator.translate('boost'),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

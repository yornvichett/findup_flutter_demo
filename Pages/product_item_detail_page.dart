import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/view_models/group_category_view_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Pages/home_page.dart';
import 'package:findup_mvvm/Pages/Screen/dialog_map_show_location_of_property.dart';
import 'package:findup_mvvm/Pages/_Profile/profile_page.dart';
import 'package:findup_mvvm/Pages/_Auth/login_page.dart';
import 'package:findup_mvvm/Pages/Screen/show_image_full_screen.dart';
import 'package:findup_mvvm/Pages/to_view_user_post_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProductItemDetailPage extends StatefulWidget {
  final ProductModel productModel;

  ProductItemDetailPage({super.key, required this.productModel});

  @override
  State<ProductItemDetailPage> createState() => _ProductItemDetailPageState();
}

class _ProductItemDetailPageState extends State<ProductItemDetailPage> {
  int _currentImageIndex = 0;
  List<String> listImage = [];
  Helper helper = Helper();
  ValueNotifier<bool> userReportStatus = ValueNotifier(true);
  PrefStorage prefStorage = PrefStorage();

  @override
  void initState() {
    super.initState();
    // Check if current user already reported this post
    userReportStatus.value = _checkReport();
  }

  bool _checkReport() {
    if (LocalStorage.userModel == null) return true;
    final currentUserId = LocalStorage.userModel!.id.toString();
    final reportedIds = widget.productModel.reportBy.split(",");
    return !reportedIds.contains(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context, listen: false);
    listImage = helper.productModelSplitImage(
      product: widget.productModel,
      path: 'property',
      context: context,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColor.appBarColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.productModel.userName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (LocalStorage.userModel != null) {
                  if (widget.productModel.userId ==
                      LocalStorage.userModel?.id) {
                    Navigation.goPage(context: context, page: ProfilePage());
                  } else {
                    Navigation.goReplacePage(
                      context: context,
                      page: ToViewUserPostProfilePage(
                        paramProductModel: widget.productModel,
                      ),
                    );
                  }
                } else {
                  Navigation.goReplacePage(context: context, page: LoginPage());
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.productModel.userProfile,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image slider
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: listImage.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShowImageFullScreen(
                                images: listImage,
                                initialIndex: _currentImageIndex,
                              ),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: listImage[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(listImage.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 12 : 8,
                          height: _currentImageIndex == index ? 12 : 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? Color(0xfffe7c00)
                                : Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              widget.productModel.saleType.toLowerCase() ==
                                  'sale'
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
                          Translator.translate(
                            widget.productModel.saleType.toLowerCase(),
                          ),

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product info and report button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${helper.currencyFormat(number: widget.productModel.basePrice)}${widget.productModel.billingPeriod}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      (LocalStorage.userModel != null &&
                              widget.productModel.userId ==
                                  LocalStorage.userModel!.id)
                          ? SizedBox()
                          : ValueListenableBuilder(
                              valueListenable: userReportStatus,
                              builder: (context, value, child) {
                                return GestureDetector(
                                  onTap: () async {
                                    if (LocalStorage.userModel != null) {
                                      // helper.showModernDialog(
                                      //   iconSize: 40,
                                      //   textAlign: TextAlign.center,

                                      //   context,
                                      //   title:
                                      //      "Report Issue",
                                      //   tabOutSide: false,
                                      //   color: const Color.fromARGB(
                                      //     255,
                                      //     223,
                                      //     221,
                                      //     221,
                                      //   ),
                                      //   icon: Icons.delete,
                                      //   subTitle: "Please describe the problem so we can improve your experience.",
                                      //   onConfirm: () async {
                                      //     bool isRemove =
                                      //         await productModelViewModel
                                      //             .removeProduct(
                                      //               userID: userID,
                                      //               productID: product.id,
                                      //               fileName: product.imageList,
                                      //             );
                                      //     if (isRemove) {
                                      //       Navigator.pop(context);
                                      //       helper.showSuccessScreen(
                                      //         context: context,
                                      //       );
                                      //     }
                                      //   },
                                      // );
                                      helper.showReportDialog(
                                        context,
                                        onSubmit: (message) async {
                                          try {
                                            Map<String, dynamic> jsonBody = {
                                              'user_id':
                                                  LocalStorage.userModel!.id,
                                              'product_id':
                                                  widget.productModel.id,
                                              'user_message': message,
                                            };
                                            await productModelViewModel
                                                .reportProduct(
                                                  jsonBody: jsonBody,
                                                );
                                            Navigator.pop(context);

                                            Navigation.goReplacePage(
                                              context: context,
                                              page: HomePage(),
                                            );
                                          } catch (e) {}
                                        },
                                      );
                                    } else {
                                      Navigation.goReplacePage(
                                        context: context,
                                        page: LoginPage(),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.flag_outlined,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          Translator.translate('report'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text(
                    Translator.translate(widget.productModel.keyTranslate),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // location
                  helper.locationWidget(
                    productModel: widget.productModel,
                    fontSize: 18,
                  ),

                  const SizedBox(height: 20),
                  Text(
                    widget.productModel.subTitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _featureIconText(
                        '${widget.productModel.bedCount.toString()} ${Translator.translate('bed')}',
                        Icons.bed,
                      ),
                      _featureIconText(
                        '${widget.productModel.bathCount.toString()} ${Translator.translate('bath')}',
                        Icons.bathtub,
                      ),
                      _featureIconText(
                        widget.productModel.size.toString(),
                        Icons.square_foot,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Safety Guidelines Section
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(47, 0, 0, 0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.amber),
                              SizedBox(width: 10),
                              Text(
                                Translator.translate('safety_guidelines'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "• ${Translator.translate('dont_pay_money_in_advance')}",
                          ),
                          Text(
                            "• ${Translator.translate('verify_the_property_and_owner_before_making_any_transaction')}",
                          ),
                          Text(
                            "• ${Translator.translate('all_content_is_generated_by_users_findup_not_responsible_for_user_content')}",
                          ),
                          // Text(
                          //     "• Report inappropriate posts using the Report button."),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  widget.productModel.userFirstPhoneNumber == 'none'
                      ? SizedBox()
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(47, 0, 0, 0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: GestureDetector(
                              onTap: () {
                                helper.openPhoneCall(
                                  widget.productModel.userFirstPhoneNumber,
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Color(0xff344a58),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),

                                        child: Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        widget
                                            .productModel
                                            .userFirstPhoneNumber,
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward, size: 19),
                                ],
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          widget.productModel.lat == 0 && widget.productModel.lon == 0
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (LocalStorage.userModel == null) {
                        Navigation.goReplacePage(
                          context: context,
                          page: LoginPage(),
                        );
                      } else {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Map Dialog",
                          barrierColor: Colors.black54,
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                                return Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: DialogMapShowLocationOfProperty(
                                      productModel: widget.productModel,
                                    ),
                                  ),
                                );
                              },
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                                final curvedValue =
                                    Curves.easeInOut.transform(
                                      animation.value,
                                    ) -
                                    1.0;
                                return Transform.translate(
                                  offset: Offset(0.0, curvedValue * -50),
                                  child: Opacity(
                                    opacity: animation.value,
                                    child: child,
                                  ),
                                );
                              },
                        );
                      }
                    },
                    child: Image.asset(
                      'assets/icons/remark_icon.png',
                      width: 70,
                    ),
                  ),
                ],
              ),
            ),

      // floatingActionButton:
      //     widget.productModel.lat == 0 && widget.productModel.lon == 0
      //     ? SizedBox()
      //     : Row(
      //         mainAxisAlignment: MainAxisAlignment.end,
      //         children: [
      //           GestureDetector(
      //             onTap: () {
      //               if (LocalStorage.userModel == null) {
      //                 Navigation.goReplacePage(
      //                   context: context,
      //                   page: LoginPage(),
      //                 );
      //               } else {
      //                 showGeneralDialog(
      //                   context: context,
      //                   barrierDismissible: true,
      //                   barrierLabel: "Map Dialog",
      //                   barrierColor: Colors.black54,
      //                   transitionDuration: const Duration(milliseconds: 500),
      //                   pageBuilder: (context, animation, secondaryAnimation) {
      //                     return Center(
      //                       child: Material(
      //                         color: Colors.transparent,
      //                         child: MapPeropertyDetailScreen(
      //                           productModel: widget.productModel,
      //                         ),
      //                       ),
      //                     );
      //                   },
      //                   transitionBuilder:
      //                       (context, animation, secondaryAnimation, child) {
      //                         final curvedValue =
      //                             Curves.easeInOut.transform(animation.value) -
      //                             1.0;
      //                         return Transform.translate(
      //                           offset: Offset(0.0, curvedValue * -50),
      //                           child: Opacity(
      //                             opacity: animation.value,
      //                             child: child,
      //                           ),
      //                         );
      //                       },
      //                 );
      //               }
      //             },
      //             child: Image.asset('assets/icons/remark_icon.png', width: 70),
      //           ),
      //         ],
      //       ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _featureIconText(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}

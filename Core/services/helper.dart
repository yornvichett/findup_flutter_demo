import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/Storage/show_mode_storage.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/cache_profile_image.dart';
import 'package:findup_mvvm/Core/utils/dialog_pop_up_elements.dart';
import 'package:findup_mvvm/Core/utils/slide_auto_scroll_element.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
import 'package:findup_mvvm/Firebase/firebase_service.dart';

import 'package:findup_mvvm/Pages/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  static bool allowFirstAds = true;
  static int groupCategoryID=0;

  Widget buildTextArea(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,

  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: maxLines,
    
        validator: (value) => value == null || value.isEmpty
            ? '${Translator.translate('please_enter')} $label'
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget modeLine({
    required String title,
    required ValueNotifier<bool> isListMode,
    required String mode,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Translator.translate(title),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        GestureDetector(
          onTap: () {
            isListMode.value = !isListMode.value;
            if (mode == '' || mode == 'list') {
              ShowModeStorage.saveModeCache(mode: "grid");
            } else {
              ShowModeStorage.saveModeCache(mode: "list");
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder(
              valueListenable: isListMode,
              builder: (context, value, child) {
                return Icon(
                  isListMode.value == false
                      ? Icons.dehaze_rounded
                      : Icons.dashboard_outlined,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> openPhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);

    if (!await launchUrl(url)) {
      throw Exception('Could not open dialer');
    }
  }

  void showItemPopupDetail({
    required BuildContext context,
    required ProductModel productModel,
    required Function(ProductModel productModel) onTabProfile,
  }) {
    Helper helper = Helper();
    PageController pageController = PageController();
    ValueNotifier<int> currentPage = ValueNotifier<int>(0);

    List<String> listImg = helper.productModelSplitImage(
      path: 'property',
      product: productModel,
      context: context,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // ===== BEAUTIFUL GLASS BACKGROUND =====
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),

              // ===== MAIN CARD =====
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.white.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 25,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== SLIDER / HERO IMAGE =====
                        SizedBox(
                          height: 310,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: pageController,
                                itemCount: listImg.length,
                                onPageChanged: (index) =>
                                    currentPage.value = index,
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    imageUrl: listImg[index],
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        Icon(Icons.error),
                                  );
                                },
                              ),

                              // ===== DARK GRADIENT OVERLAY =====
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.25),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== PAGE INDICATORS =====
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: ValueListenableBuilder(
                                  valueListenable: currentPage,
                                  builder: (_, value, __) => Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      listImg.length,
                                      (i) => AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        width: value == i ? 14 : 8,
                                        height: value == i ? 14 : 8,
                                        decoration: BoxDecoration(
                                          color: value == i
                                              ? Colors.white
                                              : Colors.white54,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            if (value == i)
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 6,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== PREV BUTTON =====
                              Positioned(
                                left: 12,
                                top: 130,
                                child: _circleButton(
                                  icon: Icons.chevron_left,
                                  onTap: () {
                                    if (pageController.page! > 0) {
                                      pageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  },
                                ),
                              ),

                              // ===== NEXT BUTTON =====
                              Positioned(
                                right: 12,
                                top: 130,
                                child: _circleButton(
                                  icon: Icons.chevron_right,
                                  onTap: () {
                                    if (pageController.page! <
                                        listImg.length - 1) {
                                      pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== INFO CONTENT =====
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TITLE
                              Text(
                                Translator.translate(productModel.keyTranslate),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),

                              SizedBox(height: 10),

                              // SUBTITLE
                              Text(
                                productModel.subTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  height: 1.45,
                                ),
                              ),

                              SizedBox(height: 16),

                              Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      productModel.fullAddress,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),

                              // ===== LUXURY PRICE TAG =====
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xffc59d5f),
                                          Color(0xffd4ab6b),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          offset: Offset(0, 4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "${helper.currencyFormat(number: productModel.basePrice)}  ${productModel.billingPeriod}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      onTabProfile(productModel);
                                    },
                                    child: CacheProfileImage(
                                      userProfileImage:
                                          productModel.userProfile,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== CLOSE BUTTON =====
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: EdgeInsets.only(top: 18, right: 18),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(Icons.close, size: 24, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== Reusable Modern Button =====
  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  void showAdsPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close", // <<< REQUIRED
      barrierColor: Colors.black.withOpacity(0.4),
      pageBuilder: (_, __, ___) {
        return Material(
          color: const Color.fromARGB(161, 0, 0, 0),
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),

              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: Image.asset(
                          "assets/images/first_pop_up.png",
                          width: double.infinity,
                          height: 290,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "🔥 Special Promotion!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "Find room, house, condo and land with 0% fee only on FindUp. Fast, easy and trusted!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showSnackBar({required BuildContext context, required String title}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
  }

  void checkLogoutUser({required BuildContext context}) async {
    LocalStorage.userModel = null;

    await LocalStorage.remove("user");
    await LocalStorage.remove("api_token");
    await FirebaseService.logout();
    Navigation.goPage(context: context, page: SplashPage());
  }

  void showAccountCheckingPopup({
    required BuildContext context,
    Function()? onTab,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // user cannot close by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 50),
                const SizedBox(height: 15),

                const Text(
                  "Your account Rejected.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Please check your account information.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey,
                    fontFamily: "Poppins",
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onTab,
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showVerifyPaymentSheet(
    BuildContext context, {
    required Future<void> Function({
      required String pathImage,
      required String message,
    })
    onConfirmVerify,
  }) {
    TextEditingController messageController = TextEditingController();
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isLoading = false; // ✅ FIXED — now outside builder

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E2B),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    border: Border.all(color: Colors.orange, width: 1.4),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Grab bar
                        Center(
                          child: Container(
                            width: 55,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        /// TITLE
                        Text(
                          Translator.translate('verify_payment'),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                          ),
                        ),
                        const SizedBox(height: 18),

                        /// IMAGE PICKER
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                            );

                            if (picked != null) {
                              setState(() => selectedImagePath = picked.path);
                            }
                          },
                          child: Container(
                            height: 170,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: const Color(0xFF222536),
                              border: Border.all(
                                color: Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: selectedImagePath == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.upload_rounded,
                                        size: 42,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        Translator.translate(
                                          "upload_verify_payment",
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.file(
                                      File(selectedImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        /// MESSAGE INPUT
                        Text(
                          Translator.translate('write_a_message_(optional)'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF222536),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: messageController,
                            maxLines: 4,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins",
                            ),
                            decoration: const InputDecoration(
                              hintText: "Write something...",
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        /// SUBMIT BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (selectedImagePath == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            Translator.translate(
                                              'upload_verify_payment',
                                            ),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => isLoading = true);

                                    await onConfirmVerify(
                                      pathImage: selectedImagePath!,
                                      message: messageController.text,
                                    );

                                    setState(() => isLoading = false);

                                    Navigator.pop(context);
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.8,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    Translator.translate('submit_verification'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showBoostItemInfo(BuildContext context, productModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Boost Your Property",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                "Scan QR to make payment and increase visibility.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // QR IMAGE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Image.asset(
                  "assets/images/qr_boost.png",
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Renew Count
              Text(
                "Renew Left: ${productModel.reNewCount}/${productModel.reNewLimit}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Boost Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Your boost function here
                  },
                  child: const Text(
                    "I Have Paid – Boost Now",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void showBoostPopup(BuildContext context, productModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Boost Your Property",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                "Scan QR to make payment and increase visibility.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // QR IMAGE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Image.asset(
                  "assets/images/qr_boost.png",
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Renew Count
              Text(
                "Renew Left: ${productModel.reNewCount}/${productModel.reNewLimit}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Boost Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Your boost function here
                  },
                  child: const Text(
                    "I Have Paid – Boost Now",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> showReviewDialog(
    BuildContext context, {
    required Function(String message) onSubmit,
  }) {
    final TextEditingController messageController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Header Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FA3FF).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    // Icons.shield_person,
                    Icons.shield_outlined,
                    color: Color(0xFF0057D9),
                    size: 36,
                  ),
                ),

                const SizedBox(height: 18),

                /// Title
                const Text(
                  "Account Under Review",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF002F6C),
                  ),
                ),

                const SizedBox(height: 10),

                /// Subtitle
                const Text(
                  "We are reviewing your account to ensure a safe and trusted experience. "
                  "You can add properties once the verification is completed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                /// Message Field
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write your message...",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Buttons
                Row(
                  children: [
                    /// Cancel
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Submit
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                        ),
                        onPressed: () {
                          final message = messageController.text.trim();

                          onSubmit(message);
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showScreenPopUp({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Map Dialog",
      barrierColor: Colors.black54, // background dim
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(child: child);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.easeInOut.transform(animation.value) - 1.0;
        return Transform.translate(
          offset: Offset(0.0, curvedValue * -50), // slide from bottom
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  Future<void> showReportDialog(
    BuildContext context, {
    required Function(String message) onSubmit,
  }) {
    final TextEditingController messageController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(148, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Translator.translate('report_issue'),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white),
                ),

                const SizedBox(height: 10),
                Text(
                  Translator.translate('please_describe_the_problem_so_we_can_improve_your_experience'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // TextField
                TextField(
                  controller: messageController,
                  style: TextStyle(color: Colors.white70),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "${Translator.translate('enter_your_message')}...",
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black,
                    
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child:  Text(Translator.translate('cancel'),style: TextStyle(color: Colors.white),),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Submit Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          final message = messageController.text.trim();

                          if (message.isEmpty) return;

                          onSubmit(message);
                        },
                        child:  Text(
                          Translator.translate('submit'),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget iconButton({
    Function()? onTab,
    required IconData iconsData,
    double size = 26,
  }) {
    return GestureDetector(
      onTap: onTab,
      child: Center(child: Icon(iconsData, size: 26, color: Color(0xff344a58))),
    );
  }

  String getFormattedDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE dd-MM-yyyy');
    return formatter.format(now);
  }

  void showSuccessScreen({
    required BuildContext context,
    IconData icon = Icons.check_circle_outline_outlined,
    Color color = Colors.green,
    String title = 'Success',
    String subTitle = '',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogPopUpElements(
        subTitle: Translator.translate(subTitle),
        icon: icon,
        iconColor: color,
        message: Translator.translate(title),
        onProcess: () async {
          await Future.delayed(const Duration(seconds: 3));
        },
      ),
    );
  }

  Widget buildSlideAdvertise({
    required double height,
    required List<String> imgList,
    required double radius,
    required String loadingPathTemp,
  }) {
    return SlideAutoScrollElement(
      loadingPathTemp: loadingPathTemp,
      imagePaths: imgList,
      isAsset: false,
      interval: Duration(hours: 12), // stay 4 seconds per slide
      slideDuration: Duration(milliseconds: 800), // slide animation speed
      hight: height,
      radius: radius,
    );
  }

  Widget locationWidget({
    required ProductModel productModel,
    double fontSize = 16,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.location_city, size: fontSize, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            productModel.fullAddress,
            style: TextStyle(fontSize: fontSize - 5, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget timneAgo({required ProductModel productModel, double fontSize = 16}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.av_timer_outlined, size: fontSize, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${productModel.timeAgo} ${Translator.translate('ago')}',
            style: TextStyle(fontSize: fontSize - 5, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void showContactToAllowDialog(
    BuildContext context, {
    Color textColor = Colors.white,
    Function()? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(148, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color.fromARGB(148, 0, 0, 0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Colors.blueAccent),

                const SizedBox(height: 12),

                Text(
                  Translator.translate('access_required'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "${Translator.translate('this_feature_is_locked')}.\n${Translator.translate('contact_to_support_to_unlock_it')}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: textColor),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        Translator.translate('back'),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                      ),
                      onPressed: onConfirm,
                      child: Text(
                        Translator.translate('ok'),
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAlertOption(
    BuildContext context, {
    required Function() onConfirm,
    String title = 'Remove',
    IconData icon = Icons.delete_outline,
    Color color = Colors.red,
    String subTitle =
        "This item will be removed from your list.\nClick confirm to proceed.",
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(147, 29, 28, 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  subTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color.fromARGB(255, 192, 191, 191),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: BorderSide(color: Colors.transparent),

                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          Translator.translate('cancel'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          Translator.translate('ok'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget borderCustom({required Size size}) {
    return Container(
      width: size.width,
      height: 0.5,
      color: const Color.fromARGB(30, 0, 0, 0),
    );
  }

  void showAlertAskingDialog(
    BuildContext context, {
    Function()? onPress,
    String title = 'Expired',
    IconData icon = Icons.lock_clock_rounded,
    Color color = Colors.red,
    bool tabOutSide = true,
    String subTitle = "Your renew plan has expired.\nPlease renew to continue.",
  }) {
    showDialog(
      context: context,
      barrierDismissible: tabOutSide,
      builder: (context) {
        String btnTitle = "OK";
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              backgroundColor: const Color.fromARGB(148, 0, 0, 0),
              title: Row(
                children: [
                  Icon(icon, color: color, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
              content: Text(
                subTitle,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 192, 191, 191),
                  height: 1.4,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isLoading
                          ? SizedBox()
                          : Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  Translator.translate('back'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    isLoading = true;
                                    btnTitle = "Log out...";
                                  });

                                  onPress!();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "${Translator.translate('log_out')}...",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  Translator.translate('ok'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showModernDialog(
    BuildContext context, {
    Function()? onConfirm,
    String title = 'Expired',
    IconData icon = Icons.lock_clock_rounded,
    double iconSize=26,
    Color color = Colors.red,
    bool tabOutSide = true,
    TextAlign textAlign=TextAlign.left,
    String subTitle = "Your renew plan has expired.\nPlease renew to continue.",
  }) {
    showDialog(
      context: context,
      barrierDismissible: tabOutSide,
      builder: (context) {
        String btnTitle = "OK";
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              backgroundColor: const Color.fromARGB(148, 0, 0, 0),
              icon: Icon(icon, color: color, size: iconSize),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
              content: Text(
                subTitle,
                textAlign: textAlign,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 192, 191, 191),
                  height: 1.4,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isLoading
                          ? SizedBox()
                          : Expanded(
                              child: ElevatedButton(
                                
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5,bottom: 5),
                                  child: Text(
                                    Translator.translate('back'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    isLoading = true;
                                    btnTitle = "Log out...";
                                  });

                                  onConfirm!();
                                },
                          style: ElevatedButton.styleFrom(
                            
                            backgroundColor: color,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? Padding(
                                padding: const EdgeInsets.only(top: 5,bottom: 5),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "${Translator.translate('log_out')}...",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                              )
                              : Text(
                                  Translator.translate('ok'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showOtpBlockedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 24),

          title: Row(
            children: [
              Icon(Icons.block, color: Colors.redAccent, size: 28),
              const SizedBox(width: 10),
              Text(
                "Too Many Requests",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "We've temporarily blocked OTP requests from this device due to unusual activity.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 10),
              Text(
                "Please wait 10–60 minutes before trying again.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Optional Helper Tip
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "For development, use Firebase Test Number to avoid blocking.",
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          actionsPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 16,
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(fontSize: 15, color: Colors.blueGrey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Try Again Later",
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void showAlertDialog(
    BuildContext context, {
    Function()? onPress,
    String title = 'Expired',
    IconData icon = Icons.lock_clock_rounded,
    Color color = Colors.red,
    String subTitle = "Your renew plan has expired.\nPlease renew to continue.",
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          content: Text(
            subTitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<File>> convertNetworkImagesToFiles(List<String> urls) async {
    final tempDir = await getTemporaryDirectory();

    // Download all images in parallel
    final futures = urls.map((url) async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final fileName = url.split('/').last.split('?').first;
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          return file;
        }
      } catch (e) {}
      return null;
    }).toList();

    // Wait for all downloads to complete
    final results = await Future.wait(futures);
    return results.whereType<File>().toList();
  }

  String currencyFormat({required double number}) {
    final formatNum = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    String result = formatNum.format(number);
    return result;
  }

  List<String> productModelSplitImage({
    required ProductModel product,
    required String path,
    bool singleImage = false,
    required BuildContext context,
  }) {
    AppConfigViewModel appConfigViewModel = Provider.of<AppConfigViewModel>(
      context,
      listen: false,
    );
    String imageList = product
        .imageList; // from API, e.g. "Makara_20251020_072754_1.jpg,Makara_20251020_072754_2.jpg"

    List<String> imageNames = imageList.split(',');
    List<String> fullImageUrls = imageNames
        .map(
          (name) =>
              "${appConfigViewModel.listAppConfigModel.first.baseAPIUrl}/storage/upload/images/$path/$name",
        )
        .toList();

    return fullImageUrls;
  }

  String getSingleImage({
    required String imgName,
    required String path,
    required BuildContext context,
  }) {
    AppConfigViewModel appConfigViewModel = Provider.of<AppConfigViewModel>(
      context,
      listen: false,
    );
    String imageUrl =
        "${appConfigViewModel.listAppConfigModel.first.baseAPIUrl}/storage/upload/images/$path/$imgName";
    return imageUrl;
  }
}

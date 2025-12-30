import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/cache_profile_image.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/home_page.dart';
import 'package:findup_mvvm/Pages/product_item_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ToViewUserPostProfilePage extends StatefulWidget {
  final ProductModel paramProductModel;

  const ToViewUserPostProfilePage({super.key, required this.paramProductModel});

  @override
  State<ToViewUserPostProfilePage> createState() =>
      _ToViewUserPostProfilePageState();
}

class _ToViewUserPostProfilePageState extends State<ToViewUserPostProfilePage> {
  Helper helper = Helper();
  TextHelper textHelper = TextHelper();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductModelViewModel>(
        context,
        listen: false,
      ).getUserProduct(userID: widget.paramProductModel.userId);
      Provider.of<ProductModelViewModel>(
        context,
        listen: false,
      ).toViewUserPostProfilePage(
        userViewID: LocalStorage.userModel == null
            ? 0
            : LocalStorage.userModel!.id,
        userOwnerProfileID: widget.paramProductModel.userId,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final prodcutModelViewModel = Provider.of<ProductModelViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            _buildProfileHeader(
              size: size,
              productModel: widget.paramProductModel,
              postCount:
                  prodcutModelViewModel.listToViewProductUserProfile.length,
            ),
            Expanded(
              child: _buildPostGrid(
                prodcutModelViewModel: prodcutModelViewModel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required ProductModel productModel,
    required int postCount,
    required Size size,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            CachedNetworkImage(
              fit: BoxFit.cover,
              width: size.width,
              height: 250,
              imageUrl: widget.paramProductModel.userCovertImg,
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
                  userProfileImage: widget.paramProductModel.userProfile,
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
                    widget.paramProductModel.userFirstPhoneNumber == 'none'
                        ? SizedBox()
                        : circualrIcon(
                            onTab: () {
                              helper.openPhoneCall(
                                widget.paramProductModel.userFirstPhoneNumber,
                              );
                            },
                            icon: Icons.call,
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
                    widget.paramProductModel.userName,
                    style: textHelper.textAppBarStyle(color: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.person, color: Colors.green),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.paramProductModel.userBioTitle,
                  style: GoogleFonts.aBeeZee(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  

  Widget textIcon({required IconData icon, required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [Icon(icon, size: 17), SizedBox(width: 10), Text(title)],
    );
  }

  Widget circualrIcon({required Function() onTab, required IconData icon}) {
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
          child: Icon(icon, color: Colors.black, size: 18),
        ),
      ),
    );
  }

  Widget _buildPostGrid({
    required ProductModelViewModel prodcutModelViewModel,
  }) {
    final list = prodcutModelViewModel.listToViewProductUserProfile;
    if (list.isEmpty) {
      return const Center(child: Text("No posts yet"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final product = list[index];
        final listImg = helper.productModelSplitImage(
          product: product,
          path: 'property',
          context: context,
        );
        return GestureDetector(
          onTap: () {
            Navigation.goPage(
              context: context,
              page: ProductItemDetailPage(productModel: product),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: listImg.isNotEmpty
                            ? listImg.first
                            : 'https://via.placeholder.com/200',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.saleType.toLowerCase() == 'sale'
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
                          Translator.translate(product.saleType.toLowerCase()),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.fullAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${helper.currencyFormat(number: product.basePrice)}${product.billingPeriod}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "User Bio: This is a modern user profile layout. You can expand this section to show additional user details, contact info, or reviews.",
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
      ),
    );
  }
}

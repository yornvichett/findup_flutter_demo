import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
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
    final prodcutModelViewModel = Provider.of<ProductModelViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.paramProductModel.userName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        // actions: [

        //   GestureDetector(
        //     onTap: () {
        //       helper.openPhoneCall(widget.paramProductModel.userFirstPhoneNumber);
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Icon(Icons.call),
        //     ),
        //   )
        // ],
        
      ),
      body: prodcutModelViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(
                    productModel: widget.paramProductModel,
                    postCount: prodcutModelViewModel.listToViewProductUserProfile.length,
                  ),
                ),
              ],
              body: _buildPostGrid(
                prodcutModelViewModel: prodcutModelViewModel,
              ),
            ),
    );
  }

  Widget _buildProfileHeader({
    required ProductModel productModel,
    required int postCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.appBarColor, Color(0xFF64B5F6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        image: DecorationImage(
          image: AssetImage('assets/background/bg3.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(
              0.15,
            ), // 0.0 = fully transparent, 1.0 = normal
            BlendMode.modulate,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 53,
            backgroundColor: Color(0xff344a58),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: CachedNetworkImageProvider(
                widget.paramProductModel.userProfile,
              ),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat(Translator.translate('post'), postCount.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
        ),
      ],
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
          context: context
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
                        "${product.groupPlace} / ${product.subPlace}",
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/utils/pop_up_boost_payment_item_history.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Pages/product_item_detail_page.dart';

import 'package:flutter/material.dart';

class BoostListVerifyScreen extends StatelessWidget {
  final List<ProductModel> listProductBoostPending;
  Function(ProductModel product) onReject;
  Function(ProductModel product) onConFirm;
  BoostListVerifyScreen({
    super.key,
    required this.listProductBoostPending,
    required this.onConFirm,
    required this.onReject,
  });

  Helper helper = Helper();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: listProductBoostPending.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          ProductModel product = listProductBoostPending[index];

          return GestureDetector(
            onTap: () {
              // Navigation.goPage(
              //   context: context,
              //   page: ItemDetailPage(productModel: product),
              // );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // PROFILE IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: helper.getSingleImage(
                        imgName: product.imageShow,
                        path: 'property',
                        context: context
                      ),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // USER INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.subTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontFamily: "Poppins",
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          color: const Color.fromARGB(46, 0, 0, 0),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 8,
                              bottom: 8,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                String iamgeUrl = helper.getSingleImage(
                                  imgName: product.boostImageVerify,
                                  path: 'boostVerify',
                                  context: context
                                );

                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      PopUpBoostPaymentItemHistory(
                                        imageUrl: iamgeUrl,
                                        boostDay: product.boostPendingDay,
                                        total: product.boostPendingTotal,

                                        //totalPoint: totalPoint,
                                      ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ID: ${product.id.toString()}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                  Text(
                                    "Day: ${product.boostPendingDay.toString()}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                  Text(
                                    "Total: ${product.boostPendingTotal.toString()}\$",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ACTION BUTTONS
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          onConFirm(product);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      GestureDetector(
                        onTap: () {
                          onReject(product);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Reject",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
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
      ),
    );
  }
}

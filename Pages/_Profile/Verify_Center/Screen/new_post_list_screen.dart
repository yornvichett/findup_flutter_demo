import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';

import 'package:flutter/material.dart';

class NewPostListScreen extends StatelessWidget {
  final List<ProductModel> listProduct;
  Function(ProductModel product) onReject;
  Function(ProductModel product) onConFirm;
  NewPostListScreen({super.key, required this.listProduct,required this.onConFirm,required this.onReject});

  Helper helper=Helper();
  @override
  Widget build(BuildContext context) {
   
    return Container(
      color: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: listProduct.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          ProductModel product = listProduct[index];

          return Container(
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
                    imageUrl: helper.getSingleImage(imgName: product.imageShow, path: 'property',context: context),
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
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontFamily: "Poppins",
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
                            horizontal: 14, vertical: 8),
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
                            horizontal: 14, vertical: 8),
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
          );
        },
      ),
    );
  }
}

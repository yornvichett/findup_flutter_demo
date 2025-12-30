import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/boost_dialog_element.dart';
import 'package:findup_mvvm/Core/utils/pop_up_boost_payment_item_history.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:flutter/material.dart';

/// =======================================
/// 🍊 MODERN BOOST LIST ITEM (Premium UI)
/// =======================================
class BoostCardItemElements extends StatelessWidget {
  final ProductModel productModel;
  Function(int productId) removeCallBack;
  Function(int productID) onVerifyPayment;
  Function(ProductModel productModel) onViewPayment;
  BoostCardItemElements({
    super.key,
    required this.productModel,
    required this.removeCallBack,
    required this.onVerifyPayment,
    required this.onViewPayment,
  });

  String imageShow = '';

  @override
  Widget build(BuildContext context) {
    Helper helper = Helper();
    imageShow = helper.getSingleImage(
      imgName: productModel.imageShow,
      path: 'property',
      context: context
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT IMAGE (CACHED NETWORK IMAGE)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: imageShow,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            
              /// Placeholder while loading
              placeholder: (context, url) => Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade300,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orange,
                  ),
                ),
              ),
            
              /// On error (broken image)
              errorWidget: (context, url, error) => Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// RIGHT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  productModel.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF222222),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                /// SUBTITLE
                Text(
                  productModel.subTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 10),

                /// BOOST DAY INFO
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${productModel.boostPendingDay}d ( ${productModel.boostPendingTotal}\$ )',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text("ID: ${productModel.id}"),
                const SizedBox(height: 10),

                /// STATUS + UPLOAD
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        onVerifyPayment(productModel.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color:
                              productModel.boostPendingStatus ==
                                  'Verify Checking...'
                              ? Colors.green
                              : Color(0xff344a58),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          Translator.translate(productModel.boostPendingStatus),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    productModel.boostPendingStatus == 'Verify Checking...'
                        ? GestureDetector(
                            onTap: () {
                              onViewPayment(productModel);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(Translator.translate('view')),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              removeCallBack(productModel.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Icon(Icons.remove, color: Colors.black),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

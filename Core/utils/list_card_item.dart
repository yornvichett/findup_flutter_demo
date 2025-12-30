import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListCardItem extends StatelessWidget {

  final ProductModel productModel;
  final VoidCallback? onTap;

    ListCardItem({
    super.key,
    required this.productModel,

    this.onTap,
  });
  String image='';
  Helper helper=Helper();

  @override
  Widget build(BuildContext context) {
    image=helper.getSingleImage(imgName: productModel.imageShow, path: 'property',context: context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        color: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 12),

        child: Row(
          children: [
            // -------------------------------
            // IMAGE
            // -------------------------------
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomLeft: Radius.circular(0),
              ),
              child: CachedNetworkImage(
                imageUrl: image,
                width: 130,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 130,
                  height: 140,
                  color: Colors.black12,
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 40),
              ),
            ),

            // -------------------------------
            // TEXT AREA
            // -------------------------------
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      Translator.translate(productModel.keyTranslate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // SUBTITLE
                    Text(
                      productModel.subTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // LOCATION
                    helper.locationWidget(productModel: productModel,fontSize: 18),
 
                    SizedBox(height: 5,),

                    // PRICE
                    Text(
                     '${ helper.currencyFormat(number: productModel.basePrice).toString()}${productModel.billingPeriod}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

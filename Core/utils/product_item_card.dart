import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';

class ProductItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  ProductItemCard({super.key, required this.product, this.onTap});

  Helper helper = Helper();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size.width,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ---- LEFT: IMAGE ----
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: helper.getSingleImage(
                  imgName: product.imageShow,
                  path: 'property',
                  context: context
                ),
                width: 110,
                height: 110,
                fit: BoxFit.cover,

                // 🔄 Show a gray shimmer while loading
                placeholder: (context, url) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),

                // ❌ If image fails to load
                errorWidget: (context, url, error) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ---- RIGHT: DETAILS ----
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // price
                  Text(
                    "\$${product.basePrice.toStringAsFixed(0)}${product.billingPeriod}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_city,color: Colors.grey,),
                      Text(
                        product.subPlace,
                        style: TextStyle(color: Colors.grey),
                        
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // icons row (bed, bath, size)
                  Row(
                    children: [
                      Icon(Icons.bed, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 3),
                      Text("${product.bedCount}"),

                      const SizedBox(width: 12),

                      Icon(
                        Icons.bathtub,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 3),
                      Text("${product.bathCount}"),

                      const SizedBox(width: 12),

                      Icon(
                        Icons.square_foot,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 3),
                      Text(product.size, style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),

            // Favorite icon
          ],
        ),
      ),
    );
  }
}

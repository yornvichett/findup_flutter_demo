import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/utils/cache_profile_image.dart';
import 'package:findup_mvvm/Pages/to_view_user_post_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class BoostCardItemElement extends StatelessWidget {
  final String imageUrl;
  final double price;
  final String billingPeriod;
  final String title;
  final String location;
  final String discount;
  final String userProfileImage;
  final String userName;
  final String timeAgo;
  final int bedCount;
  final int bathCount;
  final String size;
  bool isAssets;
  final Function()? onTab;

  BoostCardItemElement({
    super.key,
    required this.imageUrl,
    required this.price,
    required this.billingPeriod,
    required this.title,
    required this.location,
    required this.discount,
    required this.userProfileImage,
    required this.userName,
    required this.timeAgo,
    required this.bathCount,
    required this.bedCount,
    required this.size,
    this.isAssets = true,
    this.onTab,
  });

  Helper helper = Helper();

  @override
  Widget build(BuildContext context) {
    Size pageSize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 5),
      child: GestureDetector(
        onTap: onTab,
        child: Container(
          //height: 360,
          width: pageSize.width / 2,
          decoration: BoxDecoration(
            //color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(11, 0, 0, 0))
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼 Image with overlays
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 130,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          height: 130,
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.grey[300]),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${helper.currencyFormat(number: price)}$billingPeriod',
                            style: GoogleFonts.acme(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (discount.isNotEmpty)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              discount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 📄 Content
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _featureIconText(bedCount.toString(), Icons.bed),
                          _featureIconText(bathCount.toString(), Icons.bathtub),
                          _featureIconText(size, Icons.square_foot),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for features row
  Widget _featureIconText(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text.length > 18 ? '${text.substring(0, 18)}...' : text,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

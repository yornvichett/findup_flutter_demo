import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ProfileIconElement extends StatelessWidget {
  final String imageUrl;
  final bool isAssets;
  final double size;
  final bool hasStoryBorder;
  final double borderWidth;
  final Color borderColor; // ✅ New border color property
  final Function()? onTap;

  const ProfileIconElement({
    super.key,
    required this.imageUrl,
    this.size = 70,
    this.hasStoryBorder = true,
    this.borderWidth = 3,
    this.borderColor = Colors.blueAccent, // ✅ Default color
    this.isAssets = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size + (hasStoryBorder ? borderWidth * 2 : 0),
        height: size + (hasStoryBorder ? borderWidth * 2 : 0),
        decoration: hasStoryBorder
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor, // ✅ Apply border color here
                  width: borderWidth,
                ),
              )
            : null,
        child: ClipOval(
          child: isAssets
              ? Image.asset(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: size+60,
                  height: size+60,
                  fit: BoxFit.cover,
                 
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: size,
                      height: size,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
        ),
      ),
    );
  }
}

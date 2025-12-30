import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CacheProfileImage extends StatelessWidget {
  final String userProfileImage;
  final double radius;

  const CacheProfileImage({
    super.key,
    required this.userProfileImage,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    final double dpr = MediaQuery.of(context).devicePixelRatio;

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: userProfileImage,

        // ✅ Exact size
        width: size,
        height: size,
        fit: BoxFit.cover,

        // ✅ Decode image only at needed resolution
        memCacheWidth: (size * dpr).toInt(),
        memCacheHeight: (size * dpr).toInt(),

        // ✅ Smooth appearance
        fadeInDuration: const Duration(milliseconds: 200),

        // ✅ Lightweight placeholder (FAST)
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade300,
        ),

        // ✅ Error fallback
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: Icon(
            Icons.person,
            size: radius,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

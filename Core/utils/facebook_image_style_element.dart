import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class FacebookImageStyleElement extends StatelessWidget {
  final List<String> images;
  const FacebookImageStyleElement({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return _buildFacebookStyleImages(images: images);
  }

  Widget _buildFacebookStyleImages({required List<String> images}) {
    const double height = 190;

    if (images.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(color: Colors.grey.shade300),
      );
    } else if (images.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: _cachedImage(images[0], height),
      );
    } else if (images.length == 2) {
      return Row(
        children: images.map((img) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ClipRRect(
                child: _cachedImage(img, height),
              ),
            ),
          );
        }).toList(),
      );
    } else if (images.length == 3) {
      return SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: _cachedImage(images[0], height),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: _cachedImage(images[1], height / 2),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: _cachedImage(images[2], height / 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (images.length == 4) {
      return SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: _cachedImage(images[0], height),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: _cachedImage(images[1], height / 2),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: _cachedImage(images[2], height / 2),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: _cachedImage(images[3], height / 2),
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
    } else {
      return SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: _cachedImage(images[0], height),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: _cachedImage(images[1], height / 2),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: _cachedImage(images[2], height / 2),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _cachedImage(
                              images[3],
                              height / 2,
                              darken: true,
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '+${images.length - 4}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
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

  Widget _cachedImage(String url, double height, {bool darken = false}) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      color: darken ? Colors.black.withOpacity(0.6) : null,
      colorBlendMode: darken ? BlendMode.darken : null,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: height,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}

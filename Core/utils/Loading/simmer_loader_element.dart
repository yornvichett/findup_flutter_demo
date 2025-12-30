import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SimmerLoaderElement extends StatelessWidget {
  final Size size;

  const SimmerLoaderElement({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image slider placeholder
            Container(
              width: size.width,
              height: 300,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
        
            // Thumbnails row placeholder
            Row(
              children: List.generate(
                4,
                (index) => Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(left: 10),
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
        
            // Property info card placeholder
            Container(
              width: size.width - 32,
              height: 150,
              margin: const EdgeInsets.only(left: 10),
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
        
            // Contact / Map card placeholder
            Container(
              width: size.width - 32,
              height: 80,
              margin: const EdgeInsets.only(left: 10),
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

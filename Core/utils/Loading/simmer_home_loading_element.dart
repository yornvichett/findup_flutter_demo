import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SimmerHomeLoadingElement extends StatelessWidget {
  final Size size;
  const SimmerHomeLoadingElement({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ 1. TOP SLIDE BANNER
          shimmerBox(
            height: size.height * 0.25,
            width: size.width,
            radius: 12,
            margin: const EdgeInsets.all(8),
          ),

          // ⭐ 2. GROUP CATEGORY HORIZONTAL CHIPS
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (_, __) => shimmerBox(
                height: 45,
                width: 110,
                radius:20 ,
                margin: const EdgeInsets.only(right: 8),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ⭐ 3. GRID CATEGORY 4-COLUMN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              runSpacing: 10,
              spacing: 10,
              children: List.generate(
                8,
                (index) => shimmerBox(
                  height: 80,
                  width: (size.width - 60) / 4,
                  radius:50,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ⭐ 4. BOTTOM SLIDE
          shimmerBox(
            height: size.height * 0.22,
            width: size.width,
            radius: 12,
            margin: const EdgeInsets.all(8),
          ),

          const SizedBox(height: 10),

          // ⭐ 5. TOP SHOW HORIZONTAL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (_, __) => shimmerBox(
                  height: 170,
                  width: 140,
                  radius: 12,
                  margin: const EdgeInsets.only(right: 10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ⭐ 6. LARGE LIST ITEMS
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (_, __) => Column(
              children: [
                shimmerBox(
                  height: 260,
                  width: size.width,
                  radius: 12,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ⭐ UNIVERSAL SHIMMER BOX BUILDER
  Widget shimmerBox({
    required double height,
    required double width,
    double radius = 12,
    EdgeInsets? margin,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade200,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

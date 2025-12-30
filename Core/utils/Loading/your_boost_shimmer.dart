import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class YourBoostShimmer extends StatelessWidget {
  const YourBoostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        // 🔶 TOP SUMMARY CARD SHIMMER
        Padding(
          padding: const EdgeInsets.all(14),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: size.width,
              padding: const EdgeInsets.all(20),
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),

        // 🔶 LIST SHIMMER
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left image box
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Right content shimmer
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title line
                              Container(
                                height: 14,
                                width: size.width * 0.6,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Subtitle line 1
                              Container(
                                height: 12,
                                width: size.width * 0.45,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Subtitle line 2
                              Container(
                                height: 12,
                                width: size.width * 0.38,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Boost date line
                              Container(
                                height: 12,
                                width: size.width * 0.25,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Row: status + button
                              Row(
                                children: [
                                  // status box
                                  Container(
                                    height: 22,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const Spacer(),

                                  // button box
                                  Container(
                                    height: 28,
                                    width: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

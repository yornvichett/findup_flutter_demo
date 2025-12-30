import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SimmerRowImageElement extends StatelessWidget {
  final Size size;

  const SimmerRowImageElement({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              3,
              (index) => Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(left: 10),
                
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

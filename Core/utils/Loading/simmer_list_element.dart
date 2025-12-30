import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SimmerListElement extends StatelessWidget {
  final Size size;

  const SimmerListElement({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border(
                  bottom: BorderSide(
                    color: const Color.fromARGB(66, 0, 0, 0),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

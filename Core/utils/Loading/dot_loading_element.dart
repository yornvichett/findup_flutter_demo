import 'package:flutter/material.dart';

class DotLoadingElement extends StatefulWidget {
  const DotLoadingElement({super.key});

  @override
  _DotLoadingElementState createState() => _DotLoadingElementState();
}

class _DotLoadingElementState extends State<DotLoadingElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              double value = (_controller.value + i * 0.2) % 1.0;
              double size = 4 + (value * 10); // size growing effect

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

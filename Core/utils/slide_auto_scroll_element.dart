import 'dart:async';
import 'dart:io';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:flutter/material.dart';

class SlideAutoScrollElement extends StatefulWidget {
  final double radius;
  final List<String> imagePaths;
  final bool isAsset;
  final Duration interval; // Time between slide changes
  final Duration slideDuration; // Animation speed
  double hight;
  Color activeDotColor;
  Color nonActiveDotColor;
  String loadingPathTemp;

  SlideAutoScrollElement({
    super.key,
    required this.imagePaths,
    required this.hight,
    this.isAsset = true,
    this.activeDotColor = Colors.black87,
    this.nonActiveDotColor = Colors.white,
    this.interval = const Duration(seconds: 3),
    this.slideDuration = const Duration(milliseconds: 700),
    this.radius = 0,
    required this.loadingPathTemp
  });

  @override
  State<SlideAutoScrollElement> createState() => _SlideAutoScrollElementState();
}

class _SlideAutoScrollElementState extends State<SlideAutoScrollElement> {
  late final PageController pageController;
  Timer? timer;
  int currentPage = 0;
  LocalStorage localStorage = LocalStorage();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);

    timer = Timer.periodic(widget.interval, (timer) {
      if (!pageController.hasClients) return;

      int nextPage = currentPage + 1;

      if (nextPage >= widget.imagePaths.length) {
        // Jump instantly to first page
        pageController.jumpToPage(0);
        currentPage = 0;
      } else {
        // Slide with custom animation speed
        pageController.animateToPage(
          nextPage,
          duration: widget.slideDuration,
          curve: Curves.easeInOut,
        );
        currentPage = nextPage;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.hight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) => setState(() => currentPage = index),
            itemBuilder: (context, index) {
              final image = widget.imagePaths[index];

              if (widget.isAsset) {
                return Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              } else {
                // Load from cached local file
                return FutureBuilder<String>(
                  future: localStorage.getLocalImage(image),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(widget.radius),
                        child: Image.asset(
                          widget.loadingPathTemp,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(
                        widget.radius,
                      ), // change radius here
                      child: Image.file(
                        File(snapshot.data!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

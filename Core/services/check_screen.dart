import 'dart:math';

import 'package:flutter/material.dart';

class CheckScreen {
  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(
      (size.width * size.width) + (size.height * size.height),
    );
    // Usually devices with diagonal > 1100 pixels are considered tablets
    return diagonal > 1100.0;
  }
}

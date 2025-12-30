import 'package:findup_mvvm/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Navigation {
  static void goPage({required BuildContext context, required Widget page}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
  static void goReplacePage({required BuildContext context, required Widget page}) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }
}

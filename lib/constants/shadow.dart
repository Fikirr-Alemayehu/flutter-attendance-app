import 'package:flutter/material.dart';
import 'package:glc/constants/colors.dart';

class AppShadow {
  static List<BoxShadow> ksSimpleShadow(BuildContext context) => [
    BoxShadow(
      color: kcOnBackground(context).withValues(alpha: 0.1),
      spreadRadius: 1,
      blurRadius: 3,
      offset: const Offset(0, 3),
    ),
  ];
}

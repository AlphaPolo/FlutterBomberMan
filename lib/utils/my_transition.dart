import 'package:flutter/material.dart';

Widget buildMyMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    ) {
  final curveAnimation = CurvedAnimation(
    parent: animation.drive(Tween(begin: 0.3, end: 1)),
    curve: Curves.easeOutBack,
  );
  // 使用缩放动画
  return FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: curveAnimation,
      child: child,
    ),
  );
}
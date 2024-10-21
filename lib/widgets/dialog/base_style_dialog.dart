import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BaseStyleDialog extends StatelessWidget {
  const BaseStyleDialog({
    super.key,
    required this.child,
    this.backgroundColor,
    this.alignment,
  });

  final Widget child;
  final Color? backgroundColor;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Dialog(
      elevation: 10,
      backgroundColor: backgroundColor ?? Colors.black87,
      alignment: alignment,
      shadowColor: Colors.grey.withOpacity(0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(width: 4, color: Colors.white),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedSize(
            duration: 200.ms,
            curve: Curves.easeOutQuart,
            child: IntrinsicWidth(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
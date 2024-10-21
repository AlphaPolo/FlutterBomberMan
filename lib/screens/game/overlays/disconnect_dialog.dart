import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DisconnectDialog extends StatelessWidget {
  const DisconnectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: ColorTween(begin: Colors.transparent, end: Colors.black45),
      duration: 700.ms,
      curve: Curves.easeOutQuart,
      builder: (context, color, child) {
        return Container(
          color: color,
          child: child,
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: Container(
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  side: BorderSide(width: 4, color: Colors.white),
                ),
                color: Colors.black87,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('連線中斷', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('返回'),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .effect(curve: Curves.easeOutQuart)
                .fadeIn()
                .moveY(begin: 25, duration: 300.ms, curve: Curves.easeOutBack)
                .scale(
                    begin: const Offset(0, 2),
                    duration: 300.ms,
                    curve: Curves.easeOutBack),
          ),
        ),
      ),
    );
  }

}
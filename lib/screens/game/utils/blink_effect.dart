import 'package:bonfire/bonfire.dart';
import 'package:flutter/animation.dart';

enum BlinkType {
  fadeIn,
  fadeOut,
}

OpacityEffect createBlinkEffect({
  double duration = 1.0,
  double interval = 0.1,
  BlinkType type = BlinkType.fadeIn,
  VoidCallback? onComplete,
}) {
  final effectController = EffectController(
    duration: duration,
    curve: SawTooth(duration ~/ interval),
  );

  return switch (type) {
    BlinkType.fadeOut => OpacityEffect.fadeOut(
        effectController,
        onComplete: onComplete,
      ),
    BlinkType.fadeIn => OpacityEffect.fadeIn(
        effectController,
        onComplete: onComplete,
      ),
  };
}
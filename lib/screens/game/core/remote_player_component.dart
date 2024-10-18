// import 'dart:async';
// import 'dart:math';
//
// import 'package:bomber_man/providers/settings_provider.dart';
// import 'package:bomber_man/screens/game/behaviors/moving_behavior.dart';
// import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
// import 'package:bomber_man/screens/game/core/bomber_man_game.dart';
// import 'package:bomber_man/screens/game/core/movable_actor.dart';
// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flame/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class PlayerComponent extends MovableActor with KeyboardHandler, HasGameRef<BomberManGame> {
//   final BomberManKeyConfig keyConfig;
//
//
//
//   PlayerComponent._({
//     super.priority = BomberManConstant.player,
//     required super.speed,
//     super.position,
//     super.behaviors,
//     super.children,
//     super.anchor = Anchor.center,
//     super.size,
//     required this.keyConfig,
//   });
//
//   factory PlayerComponent.createFromMap(
//     Point<int> coordinate,
//     BomberManKeyConfig keyConfig,
//   ) {
//     final position = Vector2(
//       (coordinate.x + 0.5) * BomberManConstant.cellSize.width,
//       (coordinate.y + 0.5) * BomberManConstant.cellSize.height,
//     );
//
//     final playerSize = BomberManConstant.cellSize * 0.8;
//
//     return PlayerComponent._(
//       position: position,
//       speed: 300,
//       anchor: Anchor.center,
//       size: playerSize.toVector2(),
//       keyConfig: keyConfig,
//       behaviors: [
//         MovingBehavior(),
//       ],
//     );
//   }
//
//
//   @override
//   FutureOr<void> onLoad() {
//     debugMode = true;
//     addAll([
//       CircleComponent.relative(
//         1,
//         parentSize: size,
//         paint: Paint()
//           ..color = Colors.white,
//       ),
//       // CircleHitbox(),
//       RectangleHitbox(),
//     ]);
//   }
//
//   // @override
//   // void update(double dt) {
//   //   super.update(dt);
//     // handleInputMovement(dt);
//   // }
//
//   @override
//   bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
//     inputMovement.setZero();
//
//     if (keysPressed.contains(keyConfig.getLogicalKey(BomberManKey.moveUp))) {
//       inputMovement.add(BomberManConstant.up);
//     }
//
//     if (keysPressed.contains(keyConfig.getLogicalKey(BomberManKey.moveDown))) {
//       inputMovement.add(BomberManConstant.down);
//     }
//
//     if (keysPressed.contains(keyConfig.getLogicalKey(BomberManKey.moveLeft))) {
//       inputMovement.add(BomberManConstant.left);
//     }
//
//     if (keysPressed.contains(keyConfig.getLogicalKey(BomberManKey.moveRight))) {
//       inputMovement.add(BomberManConstant.right);
//     }
//
//     inputMovement.normalize();
//
//     return true;
//   }
// }

import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bonfire/bonfire.dart';

import '../../../providers/settings_provider.dart';

class RemotePlayerComponent extends PlayerComponent {
  RemotePlayerComponent({
    required super.position,
    required super.playerIndex,
  }) : super(
    keyConfig: BomberManKeyConfig.empty(),
  );

  final Vector2 _handle = Vector2.zero();


  @override
  Future<void> onLoad() async {
    _handle.setFrom(position);
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {}

  @override
  void onJoystickAction(JoystickActionEvent event) {}

  // do override to disable update direction
  // @override
  // void translate(Vector2 displacement) {
  //   position.add(displacement);
  // }

  void onRemoteUpdatePosition(Offset offset) {
    _handle.setValues(offset.dx, offset.dy);
    position.setFrom(_handle);

    // // if distance greater than 5 pixel do interpolation of position
    // if (position.distanceTo(_handle) > 5) {
    //   add(
    //     MoveEffect.to(
    //       _handle,
    //       EffectController(duration: 0.05),
    //     ),
    //   );
    // }
    //
    // if (_handle.direction != null) {
    //   moveFromDirection(_handle.direction!.toDirection());
    // } else {
    //   lastDirection = offset.lastDirection.toDirection();
    //   stopMove();
    // }
  }

}

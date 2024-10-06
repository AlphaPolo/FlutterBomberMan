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

import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class PlayerComponent extends SimplePlayer with BlockMovementCollision  {
  static const double defaultSpeed = 300;
  late final Vector2 halfSize;

  int bombCapacity = 1;

  PlayerComponent(Vector2 position, Vector2 collisionSize)
      : super(
    // animation: PlayerSpriteSheet.simpleDirectionAnimation,
    size: Vector2(56, 56),
    position: position,
    speed: defaultSpeed,
  );

  @override
  Future<void> onLoad() {
    anchor = Anchor.center;
    addAll([
      CircleComponent.relative(
        1,
        // Vector2.all(1),
        parentSize: size,
        paint: Paint()..color = Colors.red,
      ),
      RectangleHitbox(
        // size: size / 2,
        // position: size / 4,
      ),
    ]);

    halfSize = size / 2;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    checkOutOfBounds();
  }

  void checkOutOfBounds() {

    position.clamp(halfSize, BomberManConstant.gameSize - halfSize);
  }
}
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

import 'dart:math';

import 'package:bomber_man/screens/game/core/bomb_component.dart';
import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import '../../../providers/settings_provider.dart';

class PlayerComponent extends SimplePlayer with BlockMovementCollision  {
  static const double defaultSpeed = 300;
  late final Vector2 halfSize;

  final BomberManKeyConfig keyConfig;

  int force = 2;
  int bombCapacity = 2;

  PlayerComponent({
    required super.position,
    required this.keyConfig,
  })
      : super(
    // animation: PlayerSpriteSheet.simpleDirectionAnimation,
    size: Vector2(56, 56),
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

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    switch(other) {
      case PlayerComponent():
        return false;
      case BombComponent():
        return !other.ignoreList.contains(this);
      // case BrickObject():
      //   return false;
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if(isDead) return;
    if(event case JoystickActionEvent(event: ActionEvent.DOWN)) {
      if(event.id == keyConfig.getLogicalKey(BomberManKey.actionBomb)) {
        placeBomb();
      }
      if(event.id == keyConfig.getLogicalKey(BomberManKey.actionThrow)) {
        throwBomb();
      }
    }
    super.onJoystickAction(event);
  }



  void checkOutOfBounds() {
    position.clamp(halfSize, BomberManConstant.gameSize - halfSize);
  }

  void placeBomb() {
    final coordinate = BomberUtils.getCoordinate(position);

    if(alreadyOverBombCapacity()) {
      print('超過最大炸彈數');
      return;
    }

    if(alreadyHasBomb(coordinate)) {
      print('下方已經有炸彈');
      return;
    }

    gameRef.add(
      BombComponent.create(
        this,
        coordinate,
        BombConfigData(force),
      ),
    );

    print('placeBomb');
  }

  void throwBomb() {
    print(properties);
    print('throwBomb');
  }

  bool alreadyOverBombCapacity() {
    return gameRef.query<BombComponent>()
        .where((bomb) => bomb.owner == this)
        .length >= bombCapacity;
  }

  bool alreadyHasBomb(Point<int> coordinate) {
    return gameRef.query<BombComponent>()
        .map((bomb) => BomberUtils.getCoordinate(bomb.position))
        .any((position) => position == coordinate);
  }

  @override
  void onDie() {
    super.onDie();

    removeFromParent();
    print('player onDie');
  }


}
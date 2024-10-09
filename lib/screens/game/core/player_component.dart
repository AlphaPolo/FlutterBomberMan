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
import 'package:bomber_man/screens/game/utils/blink_effect.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bonfire/bonfire.dart';

import '../../../providers/settings_provider.dart';
import '../../../utils/my_print.dart';
import '../utils/player_sprite_sheet.dart';

class PlayerComponent extends SimplePlayer with BlockMovementCollision  {
  static const double maxSpeed = 550;
  static const double defaultSpeed = 250;
  late final Vector2 halfSize;

  final BomberManKeyConfig keyConfig;

  // ability
  int force = 1;
  int bombCapacity = 1;
  bool actionKick = false;
  bool actionThrow = false;




  PlayerComponent({
    required super.position,
    required this.keyConfig,
    required int playerIndex,
  })
      : super(
    animation: PlayerSpriteSheet.simpleDirectionAnimation(playerIndex),
    size: Vector2(52, 78),
    speed: defaultSpeed,
    initDirection: Direction.down,
  ) {
    priority = BomberManConstant.player;
  }

  @override
  Future<void> onLoad() {
    anchor = const Anchor(0.5, 2/3);
    final hitBoxPosition = Vector2(
      size.x * anchor.x,
      size.y * anchor.y,
    );

    // debugMode = true;
    addAll([
      // CircleComponent.relative(
      //   1,
      //   // Vector2.all(1),
      //   parentSize: size,
      //   paint: Paint()..color = color,
      //   // anchor: Anchor.center,
      // ),
      CircleHitbox(
        position: hitBoxPosition,
        anchor: Anchor.center,
        radius: 26,
        // size: size / 2,
        // position: size / 4,
      ),
    ]);

    halfSize = Vector2.all(26);
    return super.onLoad();
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
  void onBlockedMovement(PositionComponent other, CollisionData collisionData) {
    // TODO: implement onBlockedMovement
    final v = velocity;
    super.onBlockedMovement(other, collisionData);

    checkKickBomb(other);
    velocity = v;
  }

  void checkKickBomb(PositionComponent other) {
    /// 如果沒有這個能力直接return
    if(!actionKick) {
      return;
    }

    if(other case BombComponent bomb) {
      myPrint(bomb.currentDirection);
      if(bomb.ignoreList.contains(this)) return;
      if(bomb.currentDirection != ExplosionDirectionType.cross) return;
      myPrint('pass');
      final currentPosition = BomberUtils.getCoordinate(position);
      final bombPosition = BomberUtils.getCoordinate(other.position);
      switch(bombPosition - currentPosition) {
        /// up
        case Point<int>(x:0, y:-1):
          other.applyKickForce(ExplosionDirectionType.up);
        /// down
        case Point<int>(x:0, y:1):
          other.applyKickForce(ExplosionDirectionType.down);
        /// left
        case Point<int>(x:-1, y:0):
          other.applyKickForce(ExplosionDirectionType.left);
        /// right
        case Point<int>(x:1, y:0):
          other.applyKickForce(ExplosionDirectionType.right);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    checkOutOfBounds();
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
      myPrint('超過最大炸彈數');
      return;
    }

    if(alreadyHasBomb(coordinate)) {
      myPrint('下方已經有炸彈');
      return;
    }

    gameRef.add(
      BombComponent.create(
        this,
        coordinate,
        BombConfigData(force),
      ),
    );

    myPrint('placeBomb');
  }

  void throwBomb() {
    myPrint(properties);
    myPrint('throwBomb');
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

    AnimatedGameObject? stub;

    stub = AnimatedGameObject(
      position: topLeftPosition,
      size: size,
      animation: animation?.others[PlayerSpriteSheet.playerDead],
      removeOnFinish: false,
      loop: false,
      onFinish: () {
        stub?.add(
          createBlinkEffect(
            type: BlinkType.fadeOut,
            onComplete: () {
              stub?.removeFromParent();
            },
          ),
        );
      },
    );

    gameRef.add(
      stub,
    );


    removeFromParent();
    myPrint('player onDie');
  }


}
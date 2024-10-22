import 'dart:async';
import 'dart:math';

import 'package:bomber_man/screens/game/core/ability_component.dart';
import 'package:bomber_man/screens/game/core/remote_manager.dart';
import 'package:bomber_man/screens/game/network_event/network_event.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bomber_man/screens/game/utils/object_sprite_sheet.dart';
import 'package:bonfire/bonfire.dart';

import 'bomber_man_constant.dart';

class BrickObject extends GameDecorationWithCollision with Attackable {

  BrickObject._({
    // super.priority = BomberManConstant.environment,
    // required super.sprite,
    required super.position,
    required super.size,
    // Iterable<Behavior>? behaviors,
  }) {
    priority = BomberManConstant.environment;
  }

  @override
  Future<void> onLoad() async {
    // debugMode = true;
    addAll([

      // TextComponent(
      //   text: BomberUtils.getCoordinate(position).toString().substring(5),
      // ),
      // RectangleComponent.relative(
      //   Vector2.all(1),
      //   parentSize: size,
      //   paint: Paint()..color = Colors.grey.withOpacity(0.5),
      // ),
      GameDecoration.withSprite(
        sprite: ObjectSpriteSheet.brick,
        // position: BomberManConstant.zero,
        size: size*0.9,
        anchor: Anchor.center,
        position: size/2,
      ),
      RectangleHitbox.relative(
        Vector2.all(0.9),
        parentSize: size,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    ]);
  }

  factory BrickObject.createFromMap(Point<int> coordinate) {
    final brick = BrickObject._(
      position: BomberUtils.getPositionCenter(coordinate),
      size: BomberManConstant.cellSize.toVector2(),
    );
    brick.anchor = Anchor.center;

    return brick;
  }

  @override
  void onDie() {
    super.onDie();
    final coordinate = BomberUtils.getCoordinate(position);
    final ability = AbilityComponent.random(
      coordinate: coordinate,
      useNetwork: gameRef.query<RemoteManager>().firstOrNull != null,
    );

    _pushBroadcast(coordinate, ability);
    playDestroyedAnimation(ability);
  }

  void playDestroyedAnimation(AbilityComponent? ability) {
    removeWhere((component) => component is GameDecoration);
    addAll([
      GameDecoration.withAnimation(
        animation: SpriteAnimation.load(
          BomberManConstant.tiles,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.1,
            textureSize: Vector2.all(16),
            texturePosition: Vector2(80, 48),
          ),
        ),
        size: size*0.9,
        anchor: Anchor.center,
        position: size/2,
      ),
      TimerComponent(
        period: 0.5,
        removeOnFinish: true,
        onTick: () {
          if(ability != null) {
            gameRef.add(ability);
          }

          removeFromParent();
        },
      ),
    ]);
  }

  void _pushBroadcast(Point<int> coordinate, AbilityComponent? abilityComponent) {
    gameRef.query<RemoteManager>().firstOrNull?.pushRemovedObject(
      brickEvent: BrickDestroyedData(
        coordinate: coordinate,
        ability: abilityComponent?.ability,
      ),
    );
  }

}

//
// class EmptyObject {
//   const EmptyObject();
// }
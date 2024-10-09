import 'dart:async';
import 'dart:math';

import 'package:bomber_man/screens/game/core/ability_component.dart';
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
        sprite: ObjectSpriteSheet.brick2,
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
      position: Vector2(
        (coordinate.x + 0.5) * BomberManConstant.cellSize.width,
        (coordinate.y + 0.5) * BomberManConstant.cellSize.height,
      ),
      size: BomberManConstant.cellSize.toVector2(),
    );
    brick.anchor = Anchor.center;

    return brick;
  }

  @override
  void onDie() {
    super.onDie();
    final coordinate = BomberUtils.getCoordinate(position);
    removeWhere((component) => component is GameDecoration);
    addAll([
      GameDecoration.withAnimation(
        animation: SpriteAnimation.load(
          'tiled/tiles.png',
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
          if(AbilityComponent.random(coordinate: coordinate) case final component?) {
            gameRef.add(component);
          }

          removeFromParent();
        },
      ),
    ]);
  }

}

//
// class EmptyObject {
//   const EmptyObject();
// }
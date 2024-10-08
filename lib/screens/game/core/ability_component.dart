import 'dart:math';

import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bomber_man/screens/game/utils/object_sprite_sheet.dart';
import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';

import 'ability.dart';

class AbilityComponent extends GameDecorationWithCollision {

//   AbilityDropWeights = map[unitmodel.AbilityType]float64{
//   unitmodel.None:           1.6,
//   unitmodel.BombCapability: 0.5,
//   unitmodel.Speed:          0.5,
//   unitmodel.Power:          0.5,
//   unitmodel.Kick:           0.1,
//   unitmodel.Throw:          0,
// }
  static final Map<Ability? Function(), double> weightsMap = {
    () => null : 1.6,
    () => AbilityCapacity() : 0.5,
    () => AbilitySpeed() : 0.5,
    () => AbilityPower() : 0.5,
    () => AbilityKick() : 0,
    () => AbilityGoldenPower() : 0,
    () => AbilityThrow() : 0,
    () => AbilitySkull() : 0,
  };

  final Ability ability;

  AbilityComponent._({
    required super.position,
    required super.size,
    required this.ability,
  });


  factory AbilityComponent.create({
    required Ability ability,
    required Point<int> coordinate,
  }) {
    return AbilityComponent._(
      ability: ability,
      position: BomberUtils.getPositionCenter(coordinate),
      size: BomberManConstant.bombSize,
    );
  }

  static AbilityComponent? random({
    required Point<int> coordinate,
    Random? random,
  }) {

    random ??= Random();

    final totalWeights = weightsMap.values.sum;
    final diceWeight = random.nextDouble() * totalWeights;
    double weightSum = 0;

    Ability? choose;

    for(final MapEntry(key: supply, value: weight) in weightsMap.entries) {
      weightSum += weight;
      if(diceWeight < weightSum) {
        choose = supply();
        break;
      }
    }

    if(choose == null) return null;

    final component = AbilityComponent.create(
      ability: choose,
      coordinate: coordinate,
    );

    return component;
  }


  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;

    final Future<Sprite> sprite;
    switch(ability) {
      case AbilityCapacity():
        sprite = ObjectSpriteSheet.abilityCapacity;
      case AbilitySpeed():
        sprite = ObjectSpriteSheet.abilitySpeed;
      case AbilityKick():
        sprite = ObjectSpriteSheet.abilityKick;
      case AbilityThrow():
        sprite = ObjectSpriteSheet.abilityThrow;
      case AbilitySkull():
        sprite = ObjectSpriteSheet.abilitySkull;
      case AbilityGoldenPower():
        sprite = ObjectSpriteSheet.abilityGoldenPower;
      case AbilityPower():
        sprite = ObjectSpriteSheet.abilityPower;
    }

    addAll([
      GameDecoration.withSprite(
        sprite: sprite,
        position: BomberManConstant.zero,
        size: size,
      ),
      RectangleHitbox(),
    ]);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if(other case PlayerComponent player) {
      ability.applyToPlayer(player);
      removeFromParent();
    }
  }
}
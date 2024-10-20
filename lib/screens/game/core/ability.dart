import 'dart:math';

import 'package:bomber_man/screens/game/core/player_component.dart';

sealed class Ability {
  void applyToPlayer(PlayerComponent player);
}


class AbilityCapacity extends Ability {
  static const String tag = 'AbilityCapacity';

  @override
  void applyToPlayer(PlayerComponent player) {
    player.bombCapacity = min(player.bombCapacity + 1, 7);
  }

}

class AbilitySpeed extends Ability {
  static const String tag = 'AbilitySpeed';


  @override
  void applyToPlayer(PlayerComponent player) {
    player.speed = min(player.speed + 40, PlayerComponent.maxSpeed);
  }

}

class AbilityKick extends Ability {
  static const String tag = 'AbilityKick';


  @override
  void applyToPlayer(PlayerComponent player) {
    player.actionKick = true;
  }

}

class AbilityThrow extends Ability {
  static const String tag = 'AbilityThrow';


  @override
  void applyToPlayer(PlayerComponent player) {
    player.actionThrow = true;
  }

}

class AbilityPower extends Ability {
  static const String tag = 'AbilityPower';


  @override
  void applyToPlayer(PlayerComponent player) {
    player.force = min(player.force + 1, 7);
  }

}

class AbilitySkull extends Ability {
  static const String tag = 'AbilitySkull';


  @override
  void applyToPlayer(PlayerComponent player) {
    player.speed = max(player.speed - 50, 250);
    player.force = max(player.force - 1, 1);
  }

}

class AbilityGoldenPower extends Ability {
  static const String tag = 'AbilityGoldenPower';


  @override
  void applyToPlayer(PlayerComponent player) {
    player.force = 7;
  }

}
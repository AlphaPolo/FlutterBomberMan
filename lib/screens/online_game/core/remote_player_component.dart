

import 'package:bomber_man/providers/peer_provider.dart';
import 'package:bomber_man/providers/settings_provider.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bonfire/bonfire.dart';

class RemotePlayerComponent extends PlayerComponent {

  RemotePlayerComponent({
    required super.position,
    required super.playerIndex,
  }): super(
    keyConfig: BomberManKeyConfig.empty(),
  );

  @override
  void onBlockedMovement(PositionComponent other, CollisionData collisionData) {
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    return false;
  }

  void onRemoteUpdatePosition(PlayerPositionData data) {
    final PlayerPositionData(:currentAnimation, newPosition: Offset(:dx, :dy)) = data;
    position.setValues(dx, dy);
    animation?.play(currentAnimation);
  }

}



import 'package:bomber_man/providers/settings_provider.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bonfire/bonfire.dart';

import '../network_event/network_event.dart';

class RemotePlayerComponent extends PlayerComponent {

  final Vector2 _handle = Vector2.zero();

  RemotePlayerComponent({
    required super.position,
    required super.playerIndex,
    super.isHost,
  }): super(
    keyConfig: BomberManKeyConfig.empty(),
  );

  @override
  Future<void> onLoad() {
    _handle.setFrom(position);
    return super.onLoad();
  }

  @override
  void onBlockedMovement(PositionComponent other, CollisionData collisionData) {
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    return false;
  }

  void onRemoteUpdatePosition(PlayerPositionData data) {
    final PlayerPositionData(:currentAnimation, newPosition: Offset(:dx, :dy)) = data;
    _handle.setValues(dx, dy);
    // if distance greater than 5 pixel do interpolation of position
    if (position.distanceTo(_handle) > 5) {
      add(
        MoveEffect.to(
          _handle,
          EffectController(duration: 0.05),
        ),
      );
    }
    // position.setValues(dx, dy);
    animation?.play(currentAnimation);
  }

}


mixin RemoteMixin on Attackable {
  bool get isHost;


  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, identify) {
    if(!isHost) {
      return;
    }
    super.onReceiveDamage(attacker, damage, identify);
  }

  void onReceiveDamageFromNetwork(AttackOriginEnum attacker, double damage, identify) {
    if(isHost) {
      return;
    }
    super.onReceiveDamage(attacker, damage, identify);
  }
}
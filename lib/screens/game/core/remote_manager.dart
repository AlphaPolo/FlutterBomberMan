import 'package:bomber_man/providers/peer_provider.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bonfire/bonfire.dart';

class RemoteManager extends GameComponent {

  void Function(List<PlayerPositionData>) onPlayerPositionsCollect;

  List<PlayerComponent> query = [];

  RemoteManager(
    this.onPlayerPositionsCollect,
  );

  @override
  void onMount() {
    super.onMount();
    query = gameRef.query<PlayerComponent>().toList();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // scanPositions(dt);
  }

  void scanPositions(double dt) {
    // const interval = 16*2;
    const interval = 1000;

    if(checkInterval('updatePositions', interval, dt)) {
      final query = gameRef.query<PlayerComponent>();
      onPlayerPositionsCollect.call([
        for(final player in query)
          PlayerPositionData(
            playerIndex: player.playerIndex,
            newPosition: player.position.toOffset(),
            // currentAnimation: player.animation?.currentType ?? player.animation?.lastPlayedAnimation ?? SimpleAnimationEnum.idleDown,
          ),
      ]);
    }
  }
}
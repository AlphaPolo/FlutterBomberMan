import 'package:bomber_man/providers/peer_provider.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/screens/game/core/remote_player_component.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bomber_man/utils/my_print.dart';
import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';

import '../network_event/network_event.dart';
import 'bomb_component.dart';

class RemoteManager extends GameComponent {
  bool isHost;

  final PeerProvider provider;
  double elapsedTime = 0.0;

  RemoteManager({
    required this.provider,
    required this.isHost,
  });

  @override
  void onMount() {
    super.onMount();
    provider.setOnGameUpdateListener((message) {
        for(final eventData in message.data) {
          // myPrint('gameUpdate $eventData');
          switchEvent(eventData);
        }
      },
    );
  }

  @override
  void onRemove() {
    provider.setOnGameUpdateListener(null);
    super.onRemove();
  }

  @override
  void update(double dt) {
    elapsedTime += dt;
    super.update(dt);
    scanPositions(dt);
  }

  void scanPositions(double dt) {
    const interval = 16*2;
    // const interval = 1000;

    if(checkInterval('updatePositions', interval, dt)) {
      final query = gameRef.query<PlayerComponent>();
      final events = [
        for (final player in query)
          if (player is! RemotePlayerComponent)

            /// 只蒐集可操作的 Player 資訊
            ...[
            PlayerPositionData(
              playerIndex: player.playerIndex,
              newPosition: player.position.toOffset(),
              currentAnimation: player.animation?.currentType ??
                  player.animation?.lastPlayedAnimation ??
                  SimpleAnimationEnum.idleDown,
            ),
            if (player.consumeBombTrigger())
              DropBombData(
                playerIndex: player.playerIndex,
                coordinate: BomberUtils.getCoordinate(player.position),
              ),
          ],
      ];

      provider.send(GameUpdateMessage(timestamp: elapsedTime, data: events));
    }
  }

  void switchEvent(GameEventData eventData) {
    switch(eventData) {
      case PlayerPositionData(:final playerIndex):
        onPlayerPositionEvent(playerIndex, eventData);
      case DropBombData():
        onDropBombEvent(eventData);
    }
  }

  void onPlayerPositionEvent(int playerIndex, PlayerPositionData eventData) {
    gameRef.query<RemotePlayerComponent>()
        .whereType<RemotePlayerComponent>()
        .firstWhereOrNull((player) => player.playerIndex == playerIndex)
        ?.onRemoteUpdatePosition(eventData);
  }

  void onDropBombEvent(DropBombData eventData) {
    final player = gameRef.query<PlayerComponent>()
        .firstWhereOrNull((player) => player.playerIndex == eventData.playerIndex);

    if(player == null) {
      return;
    }

    if(isHost) {
      if(player.alreadyOverBombCapacity()) {
        return;
      }

      if(player.alreadyHasBomb(eventData.coordinate)) {
        return;
      }

      gameRef.add(
        BombComponent.create(
          player.playerIndex,
          eventData.coordinate,
          BombConfigData(player.force),
          true,
        ),
      );

      provider.send(
        GameUpdateMessage(
          timestamp: elapsedTime,
          data: [
            DropBombData(
              playerIndex: player.playerIndex,
              coordinate: eventData.coordinate,
            ),
          ],
        ),
      );
    }
    else {
      myPrint('Receive Bomb Event');
      gameRef.add(
        BombComponent.create(
          player.playerIndex,
          eventData.coordinate,
          BombConfigData(player.force),
          false,
        ),
      );
    }
  }
}
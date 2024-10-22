import 'dart:math';

import 'package:bomber_man/providers/peer_provider.dart';
import 'package:bomber_man/screens/game/core/ability_component.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/screens/game/core/remote_player_component.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bomber_man/screens/game/utils/id_generator.dart';
import 'package:bomber_man/utils/my_print.dart';
import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';

import '../network_event/network_event.dart';
import 'bomb_component.dart';
import 'map_parser.dart';

class RemoteManager extends GameComponent {
  IdGenerator bombIdGenerator = idGenerator();
  Set<int> removedBombIds = {};

  /// for host
  (
    List<RemoveBombEvent> removeBombEvents,
    List<BrickDestroyedData> destoryedBricks,
    List<PlayerDeadEvent> killPlayers,
  )? collectExplosionDataThisFrame;

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
    provider.setDisconnectListener(() {
      if(gameRef.overlays.isActive('GameOver')) {
        return;
      }
      gameRef.overlays.clear();
      gameRef.overlays.add('Disconnect');
      gameRef.pauseEngine();
    });
  }

  @override
  void onRemove() {
    provider.setOnGameUpdateListener(null);
    provider.setDisconnectListener(null);
    super.onRemove();
  }

  @override
  void update(double dt) {
    elapsedTime += dt;
    super.update(dt);
    scanPositions(dt);
    checkCollectAndBroadcast();
  }

  /// 監測可操作玩家的位置資訊
  /// 這邊使用的是陣列的操作
  /// 因為設想以後可能連線時是 2 vs 2 的可能性
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
              DropBombData.client(
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
      case RemoveBombEvent():
        onRemoveBombEvent(eventData);
      case BrickDestroyedData():
        onRemoveBrickEvent(eventData);
      case PlayerDeadEvent():
        onPlayerDeadEvent(eventData);
    }
  }

  /// Host 接收到此 Event 的話需要將 Event 再分發給其他玩家 (目前因為是 1 vs 1並未實作)
  /// Client 接收到的話則是直接更新其他 RemotePlayerComponent 的位置資訊即可
  void onPlayerPositionEvent(int playerIndex, PlayerPositionData eventData) {
    gameRef.query<RemotePlayerComponent>()
        .whereType<RemotePlayerComponent>()
        .firstWhereOrNull((player) => player.playerIndex == playerIndex)
        ?.onRemoteUpdatePosition(eventData);
  }

  /// Host 如果收到這個 Event 的話判斷發出訊號的玩家是否能夠合法的放置炸彈
  /// 如果合法會在廣播一個訊號給其他玩家說此位置被放置了炸彈
  ///
  /// Client 端接收到訊號後就會在此座標也放置上炸彈
  /// 需要注意的是 Client 端不會判斷秒數引爆的邏輯
  /// 這部分統一是由 Host 廣播訊號
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

      addBombAndBroadcast(player, eventData.coordinate);
    }
    else {
      myPrint('Receive Bomb Event: ${eventData.bombId}');
      if(removedBombIds.contains(eventData.bombId)) {
        return;
      }

      gameRef.add(
        BombComponent.create(
          bombId: eventData.bombId,
          ownerPlayerIndex: player.playerIndex,
          coordinate: eventData.coordinate,
          configData: BombConfigData(player.force),
          isHost: false,
        ),
      );
    }
  }

  void addBombAndBroadcast(PlayerComponent player, Point<int> coordinate) {
    final bombId = bombIdGenerator();


    gameRef.add(
      BombComponent.create(
        bombId: bombId,
        ownerPlayerIndex: player.playerIndex,
        coordinate: coordinate,
        configData: BombConfigData(player.force),
        isHost: true,
      ),
    );

    provider.send(
      GameUpdateMessage(
        timestamp: elapsedTime,
        data: [
          DropBombData(
            bombId: bombId,
            playerIndex: player.playerIndex,
            coordinate: coordinate,
          ),
        ],
      ),
    );
  }

  /// 只有 Client 端會收到此事件，收到時將會移除對應 ID 的炸彈並撥放爆炸特效
  void onRemoveBombEvent(RemoveBombEvent eventData) {
    myPrint('remove event: ${eventData.bombId}');
    gameRef.query<BombComponent>()
        .where((bomb) => bomb.bombId != null)
        .firstWhereOrNull((bomb) => bomb.bombId == eventData.bombId)
        ?.removeFromParent();

    if(eventData.explosionData.isNotEmpty) {
      gameRef.add(ExplosionAnimation.create(explosionData: eventData.explosionData));
    }
  }

  /// 只有 Client 端會收到此事件，收到時會炸毀牆壁，並且如果有產生能力的話將會在炸毀動畫後產生
  void onRemoveBrickEvent(BrickDestroyedData eventData) {
    final ability = switch(eventData.ability) {
      final ability? => AbilityComponent.create(ability: ability, coordinate: eventData.coordinate),
      _ => null,
    };

    gameRef.query<BrickObject>()
        .firstWhereOrNull((brick) => BomberUtils.getCoordinate(brick.position) == eventData.coordinate)
        ?.playDestroyedAnimation(ability);
  }

  /// Host 會去判斷那些玩家被炸死並且廣播出來，其他 Client 接收到訊號時就讓角色死亡並撥放動畫
  void onPlayerDeadEvent(PlayerDeadEvent eventData) {
    gameRef.query<PlayerComponent>()
      .firstWhereOrNull((player) => player.playerIndex == eventData.playerIndex)
      ?.onReceiveDamageFromNetwork(AttackOriginEnum.WORLD, 1000, null);
  }

  void pushRemovedObject({
    RemoveBombEvent? removeBombEvent,
    BrickDestroyedData? brickEvent,
    PlayerDeadEvent? playerDeadEvent,
  }) {
    if(!isHost) {
      return;
    }

    collectExplosionDataThisFrame ??= ([], [], []);
    final (removeBombEvents, bricks, killPlayers) = collectExplosionDataThisFrame!;

    if(removeBombEvent != null) {
      removeBombEvents.add(removeBombEvent);
    }

    if(brickEvent != null) {
      bricks.add(brickEvent);
    }

    if(playerDeadEvent != null) {
      killPlayers.add(playerDeadEvent);
    }
  }

  /// 每幀去檢查是否有物件被移除的事件
  /// 如果有則進行廣播，並清空事件
  void checkCollectAndBroadcast() {
    final data = collectExplosionDataThisFrame;

    if(!isHost || data == null) {
      return;
    }

    final (
      removeBombEvents,
      bricks,
      killPlayers,
    ) = collectExplosionDataThisFrame!;

    provider.send(
      GameUpdateMessage(
        timestamp: elapsedTime,
        data: [
          ...removeBombEvents,
          ...bricks,
          ...killPlayers,
        ],
      ),
    );

    collectExplosionDataThisFrame = null;
  }
}
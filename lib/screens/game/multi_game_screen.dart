import 'dart:math';

import 'package:bomber_man/providers/peer_provider.dart';
import 'package:bomber_man/providers/settings_provider.dart';
import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/core/bomber_man_game.dart';
import 'package:bomber_man/screens/game/core/map_parser.dart';
import 'package:bomber_man/screens/game/core/obstacle_manager.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/screens/game/core/remote_manager.dart';
import 'package:bomber_man/screens/game/core/remote_player_component.dart';
import 'package:bomber_man/screens/game/overlays/game_over_dialog.dart';
import 'package:bomber_man/utils/my_print.dart';
import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiGameScreen extends StatefulWidget {
  const MultiGameScreen({
    super.key,
    required this.firstPlayer,
    required this.secondPlayer,
    required this.map,
  });

  final PlayerComponent firstPlayer;
  final PlayerComponent secondPlayer;
  final String map;

  static MaterialPageRoute route({
    required PlayerComponent firstPlayer,
    required PlayerComponent secondPlayer,
    required String map,
    required PeerProvider provider,
  }) {
    return MaterialPageRoute(
      settings: const RouteSettings(
        name: 'OnlineGame',
      ),
      builder: (context) => ChangeNotifierProvider.value(
        value: provider,
        child: MultiGameScreen(
          firstPlayer: firstPlayer,
          secondPlayer: secondPlayer,
          map: map,
        ),
      ),
    );
  }

  @override
  State<MultiGameScreen> createState() => _MultiGameScreenState();
}

class _MultiGameScreenState extends State<MultiGameScreen> {

  final BomberManGame game = BomberManGame();

  late PlayerComponent firstPlayer = widget.firstPlayer;

  late PlayerComponent secondPlayer = widget.secondPlayer;

  late List<PlayerComponent> players = [firstPlayer, secondPlayer];

  late final PlayerComponent controlPlayer = players
      .whereNot((player) => player is RemotePlayerComponent)
      .first;

  final ObstacleManager obstacleManager = ObstacleManager();
  late final RemoteManager remoteManager;

  @override
  void initState() {
    super.initState();
    remoteManager = RemoteManager((positions) {
      context.read<PeerProvider>().send(
        GameUpdateMessage(timestamp: 0, data: positions),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeerProvider>().setOnGameUpdateListener(
            (message) {
          for(final eventData in message.data) {
            // myPrint('gameUpdate $eventData');

            if(eventData case PlayerPositionData(:final playerIndex, :final newPosition)) {

              final playerComponent = players.firstWhereOrNull((player) => player.playerIndex == playerIndex);
              playerComponent?.position = newPosition.toVector2();
              myPrint('player: ${playerComponent?.position}');
            }
          }
        },
      );
    });
  }


  @override
  Widget build(BuildContext context) {

    return BonfireWidget(
      // showCollisionArea: true,
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        startFollowPlayer: false,
        initialMapZoomFit: InitialMapZoomFitEnum.none,
        resolution: BomberManConstant.gameSize,
      ),
      player: firstPlayer,
      components: [
        secondPlayer,
        obstacleManager,
        remoteManager,
      ],
      interface: game,
      playerControllers: [
        Keyboard(
          config: getKeyboardConfigFrom(controlPlayer.keyConfig),
          observer: controlPlayer,
        ),
      ],
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/${widget.map}'),
        objectsBuilder: {
          'brick': (properties) {
            final point = Point<int>(
              properties.position.x ~/ BomberManConstant.cellSize.width,
              properties.position.y ~/ BomberManConstant.cellSize.height,
            );

            return BrickObject.createFromMap(
              point,
            );
          },
        },
        forceTileSize: BomberManConstant.cellSize.toVector2(),
      ),

      overlayBuilderMap: {
        'GameOver': (context, gameRef) {
          return GameOverDialog(gameRef: gameRef);
        },
      },
    );
  }


  KeyboardConfig getKeyboardConfigFrom(BomberManKeyConfig keyConfig) {
    return KeyboardConfig(
      directionalKeys: [
        KeyboardDirectionalKeys(
          up: keyConfig.getLogicalKey(BomberManKey.moveUp),
          down: keyConfig.getLogicalKey(BomberManKey.moveDown),
          left: keyConfig.getLogicalKey(BomberManKey.moveLeft),
          right: keyConfig.getLogicalKey(BomberManKey.moveRight),
        ),
      ],
      acceptedKeys: [
        keyConfig.getLogicalKey(BomberManKey.actionBomb),
        keyConfig.getLogicalKey(BomberManKey.actionThrow),
      ],
    );
  }
}

import 'dart:math';

import 'package:bomber_man/providers/settings_provider.dart';
import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/core/map_parser.dart';
import 'package:bomber_man/screens/game/core/obstacle_manager.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      settings: const RouteSettings(
        name: 'LocalGame',
      ),
      builder: (context) => const GameScreen(),
    );
  }


  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  // final BomberManGame game = BomberManGame();

  late PlayerComponent firstPlayer = PlayerComponent(
    position: Vector2(
      BomberManConstant.cellSize.width * (0 + 0.5),
      BomberManConstant.cellSize.height * (0 + 0.5),
    ),
    keyConfig: context.read<SettingsProvider>().player1KeyConfig,
    color: Colors.red,
  );

  late PlayerComponent secondPlayer = PlayerComponent(
    position: Vector2(
      BomberManConstant.cellSize.width * (14 + 0.5),
      BomberManConstant.cellSize.width * (12 + 0.5),
    ),
    keyConfig: context.read<SettingsProvider>().player2KeyConfig,
    color: Colors.blue,
  );

  final ObstacleManager obstacleManager = ObstacleManager();


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
      ],
      playerControllers: [
        Keyboard(
          config: getKeyboardConfigFrom(firstPlayer.keyConfig),
          observer: firstPlayer,
        ),
        Keyboard(
          config: getKeyboardConfigFrom(secondPlayer.keyConfig),
          observer: secondPlayer,
        ),
      ],
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/village_10.json'),
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

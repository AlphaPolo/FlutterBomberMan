import 'dart:math';

import 'package:bomber_man/providers/settings_provider.dart';
import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/core/map_parser.dart';
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

  PlayerComponent firstPlayer = PlayerComponent(
    Vector2(
      BomberManConstant.cellSize.width * (0 + 0.5),
      BomberManConstant.cellSize.height * (0 + 0.5),
    ),
    Vector2.all(56),
  );

  PlayerComponent secondPlayer = PlayerComponent(
    Vector2(
      BomberManConstant.cellSize.width * (14 + 0.5),
      BomberManConstant.cellSize.width * (12 + 0.5),
    ),
    Vector2.all(56),
  );


  @override
  Widget build(BuildContext context) {

    final keyConfigProvider = context.read<SettingsProvider>();

    return BonfireWidget(
      showCollisionArea: true,
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        startFollowPlayer: false,
        initialMapZoomFit: InitialMapZoomFitEnum.none,
        resolution: BomberManConstant.gameSize,
      ),
      playerControllers: [
        Keyboard(
          config: KeyboardConfig(
            directionalKeys: [
              getKeyboardDirectionalKeysFrom(keyConfigProvider.player1KeyConfig),
            ],
          ),
        ),
        Keyboard(
          config: KeyboardConfig(
            directionalKeys: [
              getKeyboardDirectionalKeysFrom(keyConfigProvider.player2KeyConfig),
            ],
          ),
          observer: secondPlayer,
        ),
      ],
      components: [
        secondPlayer,
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
          // 'brick': (properties) => Brick(
          //         Vector2((properties.position.x ~/ cellSize).toDouble(),
          //                 (properties.position.y ~/ cellSize).toDouble()) *
          //             cellSize,
          //         Vector2(cellSize, cellSize),
          //         Sprite.load('tiled/tiles.png',
          //             srcPosition: Vector2(16 * 4, 16 * 3),
          //             srcSize: Vector2(16, 16)),
          //         [
          //           CollisionArea.polygon(points: [
          //             Vector2.zero(),
          //             Vector2(cellSize - 2, 0),
          //             Vector2(cellSize - 2, cellSize - 2),
          //             Vector2(0, cellSize - 2)
          //           ])
          //         ])
        },
        forceTileSize: BomberManConstant.cellSize.toVector2(),
      ),
      player: firstPlayer,
      // map: EmptyWorldMap(),
    );


    // return MultiProvider(
    //   providers: [
    //     Provider<BomberManGame>.value(value: game),
    //     // ChangeNotifierProvider<ComponentsNotifier<ArcherSkillsHudData>>(
    //     //   create: (_) => game.componentsNotifier<ArcherSkillsHudData>(),
    //     // ),
    //   ],
    //   child: Stack(
    //     fit: StackFit.expand,
    //     children: [
    //       Positioned.fill(
    //         child: GameWidget(
    //           game: game,
    //           // overlayBuilderMap: {
    //           //   BaseDefenseGameConstant.gameOver: (context, BaseDefenseGame game) => DefenceGameOver(game: game),
    //           //   BaseDefenseGameConstant.perkPicker: (context, BaseDefenseGame game) => PerkPicker(game: game),
    //           //   BaseDefenseGameConstant.traitSetting: (context, BaseDefenseGame game) => TraitSetting(game: game),
    //           // },
    //         ),
    //       ),
    //       // const ArcherSkillPanel(),
    //     ],
    //   ),
    // );
  }


  KeyboardDirectionalKeys getKeyboardDirectionalKeysFrom(BomberManKeyConfig keyConfig) {
    return KeyboardDirectionalKeys(
      up: keyConfig.getLogicalKey(BomberManKey.moveUp),
      down: keyConfig.getLogicalKey(BomberManKey.moveDown),
      left: keyConfig.getLogicalKey(BomberManKey.moveLeft),
      right: keyConfig.getLogicalKey(BomberManKey.moveRight),
    );
  }
}

import 'package:bomber_man/screens/game/core/bomber_man_game.dart';
import 'package:flame/game.dart';
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

  final BomberManGame game = BomberManGame();


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BomberManGame>.value(value: game),
        // ChangeNotifierProvider<ComponentsNotifier<ArcherSkillsHudData>>(
        //   create: (_) => game.componentsNotifier<ArcherSkillsHudData>(),
        // ),
      ],
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GameWidget(
              game: game,
              // overlayBuilderMap: {
              //   BaseDefenseGameConstant.gameOver: (context, BaseDefenseGame game) => DefenceGameOver(game: game),
              //   BaseDefenseGameConstant.perkPicker: (context, BaseDefenseGame game) => PerkPicker(game: game),
              //   BaseDefenseGameConstant.traitSetting: (context, BaseDefenseGame game) => TraitSetting(game: game),
              // },
            ),
          ),
          // const ArcherSkillPanel(),
        ],
      ),
    );
  }
}

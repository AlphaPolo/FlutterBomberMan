import 'package:bomber_man/screens/game/core/bomber_man_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameOverDialog extends StatelessWidget {
  final BonfireGameInterface gameRef;

  const GameOverDialog({
    super.key,
    required this.gameRef,
  });

  @override
  Widget build(BuildContext context) {
    final alivePlayer = (gameRef.interface as BomberManGame)
        .winner!.firstOrNull;

    final List<Widget> children = [];

    final returnButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
      ),
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('返回'),
    );

    /// 平手
    if(alivePlayer == null) {
      children.addAll([
        const Text('平手', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 16.0),
        returnButton,
      ]);
    }
    else {
      final playerPrintIndex = alivePlayer.playerIndex + 1;

      children.addAll([
        Text('玩家 $playerPrintIndex 獲勝', style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 16.0),
        returnButton,
      ]);
    }

    return TweenAnimationBuilder(
      tween: ColorTween(begin: Colors.transparent, end: Colors.black45),
      duration: 700.ms,
      curve: Curves.easeOutQuart,
      builder: (context, color, child) {
        return Container(
          color: color,
          child: child,
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: Container(
              constraints: const BoxConstraints(minWidth: 250),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  side: BorderSide(width: 4, color: Colors.white),
                ),
                color: Colors.black87,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ).animate()
                .effect(curve: Curves.easeOutQuart)
                .fadeIn()
                .moveY(begin: 25, duration: 300.ms, curve: Curves.easeOutBack)
                .scale(begin: const Offset(0, 2), duration: 300.ms, curve: Curves.easeOutBack),
          ),
        ),
      ),
    );
  }
}

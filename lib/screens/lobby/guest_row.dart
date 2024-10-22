import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../providers/peer_provider.dart';
import '../game/utils/player_sprite_sheet.dart';

class GuestRow extends StatelessWidget {
  const GuestRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PeerProvider, int>(
      selector: (context, provider) => provider.connections,

      builder: (context, connections, _) => Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 自己
            buildPlayerCell(0, true),
            /// 其他玩家 1~3
            for(int i=1; i<4; i++)
              buildPlayerCell(i, i<=connections),
          ],
        ),
      ),
    );
  }

  Widget buildPlayerCell(int playerIndex, bool isAppear) {

    final child = switch(isAppear) {
      true => Container(
        key: ValueKey(playerIndex),
        decoration: const BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          border: Border.fromBorderSide(BorderSide(width: 4, color: Colors.amber)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(12),
        width: 100,
        height: 100,
        // alignment: Alignment.center,
        child: SpriteWidget.asset(
          anchor: Anchor.center,
          path: BomberManConstant.spritesheet,
          srcPosition: PlayerSpriteSheet.getPlayerTexturePosition(1, playerIndex),
          srcSize: PlayerSpriteSheet.playerTextureSize,
        ),
      ).animate()
          .effect(delay: 200.ms, duration: 300.ms, curve: Curves.easeOutBack)
          .fadeIn()
          .scale(),
      false => const SizedBox.shrink(),
    };


    return AnimatedSize(
      duration: 700.ms,
      reverseDuration: 700.ms,
      clipBehavior: Clip.none,
      curve: Curves.easeOutBack,
      child: child,
    );
  }


}

import 'package:bomber_man/extensions/iterable_extension.dart';
import 'package:bomber_man/screens/game/utils/player_sprite_sheet.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../providers/peer_provider.dart';

class HostPartScreen extends StatelessWidget {
  const HostPartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PeerProvider(context),
          lazy: false,
        ),
      ],
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('HOST'),
            const SizedBox(height: 12.0),
            Selector<PeerProvider, String>(
              selector: (context, provider) => provider.peerId ?? '準備中...',
              builder: (context, peerId, _) {
                return SelectableText('ID: $peerId');
              },
            ),
            buildGuestRow(),
            const SizedBox(height: 32.0),
            buildBottomRow(context),
          ],
        ),
      ),
    );
  }

  Widget buildGuestRow() {
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

  Widget buildBottomRow(BuildContext context) {
    return Selector<PeerProvider, bool>(
      selector: (context, provider) => provider.connections > 0,
      builder: (context, canPlay, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Return'),
            ),
            if(canPlay)
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Play'),
            ),
          ].joinElement(const SizedBox(width: 16.0)),
        );
      }
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
            path: 'spritesheet.png',
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

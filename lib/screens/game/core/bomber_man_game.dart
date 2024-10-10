import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/utils/my_print.dart';
import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';

class BomberManGame extends GameInterface {

  /// 0.3 秒內同歸於盡都算平手
  static const double interval = 0.3;

  ComponentsNotifier<PlayerComponent>? playerLeftNotifier;

  /// 有可能平手所以採用 list 的設計
  List<PlayerComponent>? winner;

  BomberManGame();
  @override
  void onMount() {
    super.onMount();
    myPrint('onMount');

    final game = findGame();

    if(game == null) return;
    final notifier = playerLeftNotifier = game.componentsNotifier<PlayerComponent>();

    notifier.addListener(listenToPlayer);
  }

  void listenToPlayer() {
    final notifier = playerLeftNotifier;
    if(notifier == null) return;
    add(
      TimerComponent(
        period: interval,
        onTick: checkWinner,
        removeOnFinish: true,
      ),
    );
  }

  @override
  void onRemove() {
    super.onRemove();
    myPrint('onRemove');

    playerLeftNotifier?.removeListener(listenToPlayer);
  }

  void checkWinner() {

    myPrint('checkWinner');
    final components = playerLeftNotifier?.components;
    if(winner != null || components == null || components.length > 1) {
      return;
    }

    /// 如果沒有也會有空陣列，此時算平手
    winner = [
      if(components.firstOrNull case final player?)
        player
    ];

    /// x秒鐘後顯示結算畫面
    add(
      TimerComponent(
        period: 1.7,
        removeOnFinish: true,
        onTick: () {
          gameRef.pauseEngine();
          gameRef.overlays.add('GameOver');
        },
      ),
    );
  }

}
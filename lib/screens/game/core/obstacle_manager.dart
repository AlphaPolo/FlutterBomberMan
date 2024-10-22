import 'dart:math';

import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';

class ObstacleManager extends GameComponent {

  Set<Point<int>> obstacleSet = {};

  @override
  Future<void> onLoad() async {
    final component = GameDecorationWithCollision(
      position: BomberManConstant.zero,
      size: BomberManConstant.gameSize,
    );

    gameRef.add(component);

    component.add(RectangleHitbox(
      collisionType: CollisionType.passive,
    ));
  }

  @override
  void onMount() {
    super.onMount();

    /// 記錄所有不可破壞的物件座標
    /// 以便之後高效實現遊戲判斷的邏輯
    final result = gameRef.map.layers
      .firstWhereOrNull((layer) => layer.name == 'blocks')
      ?.tiles;


    obstacleSet = result?.map((tile) {
      return Point<int>(
        tile.x.toInt(),
        tile.y.toInt(),
      );
    }).toSet() ?? {};
  }

  bool hasObstacleAt(Point<int> position) => obstacleSet.contains(position);

}
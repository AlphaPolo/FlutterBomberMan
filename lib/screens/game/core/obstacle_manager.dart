import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';

class ObstacleManager extends GameComponent {

  Set<Point<int>> obstacleSet = {};

  @override
  Future<void> onLoad() async {

  }

  @override
  void onMount() {
    super.onMount();
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
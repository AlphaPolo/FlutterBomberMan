import 'dart:math';

import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bonfire/bonfire.dart';

class BomberUtils {
  const BomberUtils._();

  static Point<int> getCoordinate(Vector2 worldPosition) {
    return Point<int>(
      worldPosition.x ~/ BomberManConstant.cellSize.width,
      worldPosition.y ~/ BomberManConstant.cellSize.height,
    );
  }
}
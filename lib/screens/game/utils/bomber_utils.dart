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

  static Vector2 getPosition(Point<int> coordinate) {
    return Vector2(
      coordinate.x * BomberManConstant.cellSize.width,
      coordinate.y * BomberManConstant.cellSize.height,
    );
  }

  static Vector2 getPositionCenter(Point<int> coordinate) {
    return Vector2(
      (coordinate.x + 0.5) * BomberManConstant.cellSize.width,
      (coordinate.y + 0.5) * BomberManConstant.cellSize.height,
    );
  }
}
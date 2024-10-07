import 'package:flame/extensions.dart';

class BomberManConstant {

  const BomberManConstant._();

  static const double width = 960;
  static const double height = 832;
  static const double cellSide = 64;

  static const Size gameContentSize = Size(width, height);
  static const Size cellSize = Size(cellSide, cellSide);
  static final Vector2 bombSize = Vector2.all(52);

  /// 寬度總共可以容納多少個tile
  static const int colTiles = width ~/ cellSide;
  /// 高度總共可以容納多少個tile
  static const int rowTiles = height ~/ cellSide;

  static final Vector2 zero = Vector2.zero();
  static final Vector2 gameSize = gameContentSize.toVector2();

  static final Vector2 up = Vector2(0, -1);
  static final Vector2 down = Vector2(0, 1);
  static final Vector2 left = Vector2(-1, 0);
  static final Vector2 right = Vector2(1, 0);

  //#region Draw Priority
  static const int background = 1;
  static const int environment = 2;
  static const int player = 3;
  static const int effect = 10;
  static const int hud = 100;
  //#endregion

}
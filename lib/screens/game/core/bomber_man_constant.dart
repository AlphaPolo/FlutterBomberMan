import 'package:flame/extensions.dart';

class BomberManConstant {

  const BomberManConstant._();

  static const double width = 960;
  static const double height = 832;

  static const Size gameContentSize = Size(width, height);
  static const Size cellSize = Size(64, 64);

  static final Vector2 zero = Vector2.zero();
  static final Vector2 gameSize = gameContentSize.toVector2();

  static final Vector2 up = Vector2(0, -1);
  static final Vector2 down = Vector2(0, 1);
  static final Vector2 left = Vector2(-1, 0);
  static final Vector2 right = Vector2(1, 0);

  // draw priority
  static const int background = 1;
  static const int environment = 2;
  static const int player = 3;
  static const int effect = 10;
  static const int hud = 100;

}
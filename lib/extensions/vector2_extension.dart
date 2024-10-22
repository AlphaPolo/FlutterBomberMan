import 'package:bonfire/bonfire.dart';

extension Vector2Extension on Vector2 {
  bool get isUp => y < 0;

  bool get isDown => y > 0;

  bool get isLeft => x < 0;

  bool get isRight => x > 0;
}

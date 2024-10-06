import 'package:flame/extensions.dart';

extension SetExtension on Set<Vector2> {
  Vector2 average() {
    Vector2 sum = Vector2.zero();
    forEach(sum.add);
    return Vector2(sum.x / length, sum.y / length);
  }
}
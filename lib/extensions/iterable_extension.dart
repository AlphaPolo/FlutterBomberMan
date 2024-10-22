
import 'package:bonfire/bonfire.dart';

extension SetExtension on Set<Vector2> {
  Vector2 average() {
    Vector2 sum = Vector2.zero();
    forEach(sum.add);
    return Vector2(sum.x / length, sum.y / length);
  }
}


extension IterableExtension<E> on Iterable<E> {

  List<E> joinElement(E separator) {
    final list = <E>[];
    Iterator<E> iterator = this.iterator;
    if (!iterator.moveNext()) return list;
    if (separator == null) {
      do {
        list.add(iterator.current);
      } while (iterator.moveNext());
    } else {
      list.add(iterator.current);
      while (iterator.moveNext()) {
        list.add(separator);
        list.add(iterator.current);
      }
    }
    return list;
  }

}
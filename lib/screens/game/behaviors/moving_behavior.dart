// import 'dart:collection';
// import 'dart:ui';
//
// import 'package:bomber_man/extensions/vector2_extension.dart';
// import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
// import 'package:bomber_man/screens/game/core/player_component.dart';
// import 'package:flame/components.dart';
// import 'package:flame_behaviors/flame_behaviors.dart';
//
// class MovingBehavior<T extends PlayerComponent> extends Behavior<T> {
//   final Queue<(PositionComponent, Set<Vector2>)> _queuedCollisions = Queue();
//
//   // Caching helper for `undoCollisions`
//   final Vector2 _cachedMovementThisFrame = Vector2.zero();
//
//   /// Caching helper for `undoCollisions`.
//   final Vector2 _originalPosition = Vector2.zero();
//
//   final Vector2 _handleMovement = Vector2.zero();
//
//   @override
//   void update(double dt) {
//     applyMovement(dt);
//     checkOutOfBounds();
//     processCollisions();
//   }
//
//   void applyMovement(double dt) {
//     _originalPosition.setFrom(parent.position);
//     _handleMovement
//       ..setFrom(parent.inputMovement)
//       ..scale(dt * parent.speed);
//
//     parent.position.add(_handleMovement);
//
//     _cachedMovementThisFrame
//       ..setFrom(parent.position)
//       ..sub(_originalPosition);
//   }
//
//
//   void checkOutOfBounds() {
//     final halfSize = parent.size / 2;
//     parent.position.clamp(halfSize, BomberManConstant.gameSize - halfSize);
//   }
//
//   void queueCollision({
//     required PositionComponent other,
//     required Set<Vector2> intersectionPoints,
//   }) {
//     _queuedCollisions.add((other, intersectionPoints));
//   }
//
//   /// Handles any collisions registered via [queueCollisions].
//   void processCollisions() {
//     while (_queuedCollisions.isNotEmpty) {
//       final (PositionComponent other, Set<Vector2> intersectionPoints) =
//           _queuedCollisions.removeFirst();
//       // if (!unwalkableComponentChecker(other)) {
//       //   return;
//       // }
//
//       // final topLeft = parent.positionOfAnchor(Anchor.topLeft);
//       // final topCenter = parent.positionOfAnchor(Anchor.topCenter);
//       // final topRight = parent.positionOfAnchor(Anchor.topRight);
//       // final centerLeft = parent.positionOfAnchor(Anchor.centerLeft);
//       // final centerRight = parent.positionOfAnchor(Anchor.centerLeft);
//
//       // final collisionOnTop =
//       //     other.containsPoint(parent.positionOfAnchor(Anchor.topCenter));
//       // final collisionOnBottom =
//       //     other.containsPoint(parent.positionOfAnchor(Anchor.bottomCenter));
//       // final collisionOnLeft =
//       //     other.containsPoint(parent.positionOfAnchor(Anchor.centerLeft));
//       // final collisionOnRight =
//       //     other.containsPoint(parent.positionOfAnchor(Anchor.centerRight));
//       //
//       // other.containsPoint(point);
//
//       final otherRect = other.toRect();
//
//       // if (_cachedMovementThisFrame.isUp && isOverlaps) {
//       //   print('up');
//       //   parent.position.y = _originalPosition.y;
//       // }
//       // if (_cachedMovementThisFrame.isDown && isOverlaps) {
//       //   print('down');
//       //   parent.position.y = _originalPosition.y;
//       // }
//
//       checkHorizontal(otherRect);
//       checkVertical(otherRect);
//     }
//   }
//
//   void checkHorizontal(Rect otherRect) {
//
//     final playerRect = parent.toRect();
//     final isOverlaps = otherRect.overlaps(playerRect);
//
//     if (_cachedMovementThisFrame.isLeft && isOverlaps) {
//       print('left');
//       parent.position.x = _originalPosition.x;
//     }
//     if (_cachedMovementThisFrame.isRight && isOverlaps) {
//       print('right');
//       parent.position.x = _originalPosition.x;
//     }
//   }
//
//   void checkVertical(Rect otherRect) {
//     final playerRect = parent.toRect();
//     final isOverlaps = otherRect.overlaps(playerRect);
//
//     if (_cachedMovementThisFrame.isUp && isOverlaps) {
//       print('up');
//       parent.position.y = _originalPosition.y;
//     }
//     if (_cachedMovementThisFrame.isDown && isOverlaps) {
//       print('down');
//       parent.position.y = _originalPosition.y;
//     }
//   }
// }

// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flame_behaviors/flame_behaviors.dart';
// import 'package:flutter/foundation.dart';
//
// import '../behaviors/moving_behavior.dart';
//
// /// Parent class of game actors that move, like [Player] and [Zombie] instances.
// abstract class MovableActor extends PositionedEntity with CollisionCallbacks {
//   MovableActor({
//     required super.position,
//     required this.speed,
//     super.anchor,
//     super.children,
//     super.behaviors,
//     super.priority,
//     super.size,
//   });
//
//   double speed;
//
//   /// The actor's desired movement this frame. This vector should not
//   /// incorporate the actor's speed or the frame's `dt`.
//   Vector2 inputMovement = Vector2.zero();
//
//
//   @override
//   @mustCallSuper
//   void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
//     super.onCollision(intersectionPoints, other);
//     print('onCollision');
//     findBehavior<MovingBehavior>().queueCollision(
//       other: other,
//       intersectionPoints: intersectionPoints,
//     );
//   }
//
// }
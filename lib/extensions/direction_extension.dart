import 'package:bonfire/bonfire.dart';

extension JoystickMoveDirectionalExt on JoystickMoveDirectional {
  Direction? toMoveDirection() {
    switch (this) {
      case JoystickMoveDirectional.MOVE_UP:
        return Direction.up;
      case JoystickMoveDirectional.MOVE_RIGHT:
        return Direction.right;
      case JoystickMoveDirectional.MOVE_DOWN:
        return Direction.down;
      case JoystickMoveDirectional.MOVE_LEFT:
        return Direction.left;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        return Direction.upLeft;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        return Direction.upRight;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        return Direction.downRight;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        return Direction.downLeft;
      case JoystickMoveDirectional.IDLE:
        return null;
    }
  }
}
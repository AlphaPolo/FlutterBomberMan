import 'dart:math';

import 'package:bomber_man/screens/game/core/ability_component.dart';
import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/core/map_parser.dart';
import 'package:bomber_man/screens/game/core/obstacle_manager.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/screens/game/core/remote_player_component.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bomber_man/screens/game/utils/object_sprite_sheet.dart';
import 'package:bonfire/bonfire.dart';
import 'package:collection/collection.dart';

import '../../../utils/my_print.dart';

class BombConfigData {
  /// 火力
  final int force;

  const BombConfigData(this.force);
}

class BombComponent extends GameDecorationWithCollision with Attackable, RemoteMixin {

  static const lifeTime = 2.5;

  @override
  final bool isHost;

  final BombConfigData configData;
  final Set<Component> ignoreList = {};
  final int? ownerPlayerIndex;

  /// 先用ExplosionDirectionType來代替方向定義
  ExplosionDirectionType currentDirection = ExplosionDirectionType.cross;


  BombComponent._({
    required this.ownerPlayerIndex,
    required this.configData,
    required super.position,
    required super.size,
    required this.isHost,
  });

  factory BombComponent.create(
    int? ownerPlayerIndex,
    Point<int> coordinate,
    BombConfigData configData,
    [bool isHost = true]
  ) {
   return BombComponent._(
      ownerPlayerIndex: ownerPlayerIndex,
      configData: configData,
      position: Vector2(
        BomberManConstant.cellSize.width * (coordinate.x + 0.5),
        BomberManConstant.cellSize.height * (coordinate.y + 0.5),
      ),
      size: BomberManConstant.bombSize,
      isHost: isHost,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(currentDirection != ExplosionDirectionType.cross) {
      final oldCell = BomberUtils.getCoordinate(position);
      final directionForce = currentDirection.getVector2();
      position.add(directionForce.scaled(700 * dt));

      final nextCellPosition = position + directionForce.scaled(BomberManConstant.cellSide);
      final nextCell = BomberUtils.getCoordinate(nextCellPosition);
      if (oldCell.distanceTo(nextCell) == 1 && checkIsHitEnvironment(nextCell)) {
        currentDirection = ExplosionDirectionType.cross;
        position = BomberUtils.getPositionCenter(oldCell);
      }
    }

  }

  @override
  Future<void> onLoad() async {
    // setupPushable(
    //   pushPerCellEnabled: true,
    //   pushPerCellDuration: 1,
    //   cellSize: BomberManConstant.cellSize.toVector2(),
    // );
    anchor = Anchor.center;

    addAll([
      GameDecoration.withAnimation(
        animation: ObjectSpriteSheet.bomb,
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      ),
      // CircleComponent.relative(
      //   1,
      //   parentSize: size,
      //   paint: Paint()..color = Colors.black,
      // ),
      RectangleHitbox(
        isSolid: true,
      ),
      /// 自傷觸發 onDie
      TimerComponent(
        period: lifeTime,
        removeOnFinish: true,
        onTick: suicide,
      ),
    ]);
  }

  @override
  void onMount() {
    super.onMount();
    addAbovePlayerToIgnoreList();
  }

  @override
  void onRemove() {
    ignoreList.clear();
    super.onRemove();
  }

  void suicide() {
    handleAttack(AttackOriginEnum.WORLD, 1000, null);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if(currentDirection == ExplosionDirectionType.cross) {
      return;
    }

    if(ignoreList.contains(other)) {
      return;
    }

    if(other is AbilityComponent) {
      return;
    }

    currentDirection = ExplosionDirectionType.cross;
    position = BomberUtils.getPositionCenter(BomberUtils.getCoordinate(position));
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if(ignoreList.contains(other)) {
      ignoreList.remove(other);
    }
  }

  // 出生的瞬間所有站在炸彈上的Player可以暫時不受炸彈的碰撞
  void addAbovePlayerToIgnoreList() {
    final currentPosition = BomberUtils.getCoordinate(position);

    final result = gameRef.query<PlayerComponent>()
        .where((player) => BomberUtils.getCoordinate(player.position) == currentPosition);

    ignoreList.addAll(result);
  }

  void explosion() {
    final explosionPosition = BomberUtils.getCoordinate(position);
    checkHitPlayers(explosionPosition);


    final explosionData = [
      (ExplosionDirectionType.cross, explosionPosition, false),
    ];

    for(final direction in ExplosionDirectionType.values.skip(1)) {
      createDirectionChildren(explosionPosition, direction, explosionData);
    }

    gameRef.add(ExplosionAnimation.create(explosionData: explosionData));
  }

  void checkHitPlayers(Point<int> explosionPosition) {
    gameRef.query<PlayerComponent>()
        .where((player) => BomberUtils.getCoordinate(player.position) == explosionPosition)
        .forEach((player) => player.handleAttack(AttackOriginEnum.WORLD, 1000, this));
  }

  void checkHitBombs(Point<int> currentPosition) {
    gameRef.query<BombComponent>()
        .whereNot((bomb) => bomb.isDead)
        .firstWhereOrNull((bomb) => BomberUtils.getCoordinate(bomb.position) == currentPosition)
        ?.handleAttack(AttackOriginEnum.WORLD, 1000, this);
  }

  bool checkHitWall(Point<int> currentPosition) {

    final isBlock = gameRef.query<ObstacleManager>()
        .firstOrNull
        ?.hasObstacleAt(currentPosition) ?? false;

    if(isBlock) {
      return true;
    }

    final wall = gameRef
        .query<BrickObject>()
        .firstWhereOrNull((wall) => BomberUtils.getCoordinate(wall.position) == currentPosition);

    if(wall == null) {
      return false;
    }

    final coordinate = BomberUtils.getCoordinate(wall.position);
    myPrint('coordinate: $coordinate, position: ${wall.position}');
    wall.handleAttack(AttackOriginEnum.WORLD, 1000, this);
    return true;
  }

  @override
  void onDie() {
    super.onDie();
    explosion();
    removeFromParent();
  }

  void createDirectionChildren(
    Point<int> centerPosition,
    ExplosionDirectionType direction,
    List<(ExplosionDirectionType, Point<int>, bool)> explosionData,
  ) {
    Point<int> currentPosition = centerPosition;
    for(int force=configData.force; force>0; force--) {
      currentPosition = direction.nextPosition(currentPosition);

      if(checkIsOutOfBounds(currentPosition)) {
        myPrint('$currentPosition is out of bounds');
        break;
      }

      if(checkHitWall(currentPosition)) {
        break;
      }

      checkHitPlayers(currentPosition);
      checkHitBombs(currentPosition);
      explosionData.add((direction, currentPosition, force==1));
    }
  }

  bool checkIsOutOfBounds(Point<int> currentPosition) {
    return switch(currentPosition) {
      Point(x: <0 || >=BomberManConstant.colTiles) => true,
      Point(y: <0 || >=BomberManConstant.rowTiles) => true,
      _ => false,
    };
  }

  bool checkIsHitEnvironment(Point<int> nextCell) {
    return gameRef.query<ObstacleManager>().firstOrNull?.hasObstacleAt(nextCell) ?? false;
  }

  void applyKickForce(ExplosionDirectionType direction) {
    currentDirection = direction;
    myPrint('currentDirection: $currentDirection');
  }

}

enum ExplosionDirectionType {
  cross(Point<int>(0, 0), 0),
  up(Point<int>(0, -1), -90 * degrees2Radians),
  right(Point<int>(1, 0), 0),
  down(Point<int>(0, 1), 90 * degrees2Radians),
  left(Point<int>(-1, 0), 180 * degrees2Radians);

  const ExplosionDirectionType(this._nextPoint, this.angle);

  final Point<int> _nextPoint;
  final double angle;

  Point<int> nextPosition([Point<int>? currentPosition]) {
    if(currentPosition == null) {
      return _nextPoint;
    }
    return currentPosition + _nextPoint;
  }

  Vector2 getVector2() {
    return switch (this) {
      ExplosionDirectionType.cross => BomberManConstant.zero,
      ExplosionDirectionType.up => BomberManConstant.up,
      ExplosionDirectionType.right => BomberManConstant.right,
      ExplosionDirectionType.down => BomberManConstant.down,
      ExplosionDirectionType.left => BomberManConstant.left,
    };
  }
}

class ExplosionAnimation extends GameDecoration {
  static const double explodeStepTime = 0.055;

  List<(ExplosionDirectionType, Point<int>, bool)> explosionData;


  ExplosionAnimation._({
    required super.position,
    required super.size,
    this.explosionData = const [],
    super.anchor = Anchor.center,
  }) {
    priority = BomberManConstant.effect;
  }


  factory ExplosionAnimation.create({
    required List<(ExplosionDirectionType, Point<int>, bool)> explosionData,
  }) {

    final (_, coordinate, _) = explosionData.firstWhere((data) => data.$1 == ExplosionDirectionType.cross);
    final position = Vector2(
      (coordinate.x + 0.5) * BomberManConstant.cellSize.width,
      (coordinate.y + 0.5) * BomberManConstant.cellSize.height,
    );

    return ExplosionAnimation._(
      position: position,
      size: BomberManConstant.cellSize.toVector2(),
      explosionData: explosionData,
    );

  }



  @override
  Future<void> onLoad() async {

    final centerPosition = BomberUtils.getCoordinate(position);
    final cellSize = BomberManConstant.cellSize.toVector2();

    final children = explosionData
        .map((data) => (data.$1, data.$2 - centerPosition, data.$3))
        .map((data) => mapToExplodeChild(data, cellSize))
        .whereNotNull();

    addAll(
      children
          .followedBy([
        TimerComponent(
          period: explodeStepTime * 7,
          onTick: removeFromParent,
          removeOnFinish: true,
        ),
      ]),
    );
  }

  Component mapToExplodeChild((ExplosionDirectionType, Point<int>, bool) data, Vector2 cellSize) {
    final (ExplosionDirectionType type, Point<int> position, bool isEdge) = data;

    final double textureY = switch(type) {
      ExplosionDirectionType.cross => 0,
      _ when !isEdge => 49,
      _ => 97,
    };

    return GameDecoration.withAnimation(
      animation: SpriteAnimation.load(
        "explode_sheet.png",
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: BomberManConstant.explodeSize,
          texturePosition: Vector2(0, textureY),
          stepTime: explodeStepTime,
        ),
      ),
      position: Vector2(
        (position.x + 0.5) * BomberManConstant.cellSize.width,
        (position.y + 0.5) * BomberManConstant.cellSize.height,
      ),
      anchor: Anchor.center,
      size: cellSize,
      angle: type.angle,
    );
  }
}
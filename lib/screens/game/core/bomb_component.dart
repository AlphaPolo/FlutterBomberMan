import 'dart:math';

import 'package:bomber_man/screens/game/core/ability_component.dart';
import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/core/map_parser.dart';
import 'package:bomber_man/screens/game/core/obstacle_manager.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/screens/game/core/remote_manager.dart';
import 'package:bomber_man/screens/game/core/remote_player_component.dart';
import 'package:bomber_man/screens/game/network_event/network_event.dart';
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

  static const double lifeTime = BomberManConstant.bombLifeTime;

  @override
  final bool isHost;
  final int? bombId;

  final BombConfigData configData;
  final Set<Component> ignoreList = {};
  final int? ownerPlayerIndex;

  /// 先用ExplosionDirectionType來代替方向定義
  ExplosionDirectionType currentDirection = ExplosionDirectionType.cross;

  /// 如果停止後跑這個 timer，如果正在 running 不可再次被踢
  Timer stopCD = Timer(
    0.2,
    autoStart: false,
  );


  BombComponent._({
    this.bombId,
    required this.ownerPlayerIndex,
    required this.configData,
    required super.position,
    required super.size,
    required this.isHost,
  });

  factory BombComponent.create({
    int? bombId,
    int? ownerPlayerIndex,
    required Point<int> coordinate,
    required BombConfigData configData,
    bool isHost = true,
  }) {
   return BombComponent._(
      bombId: bombId,
      ownerPlayerIndex: ownerPlayerIndex,
      configData: configData,
      position: BomberUtils.getPositionCenter(coordinate),
      size: BomberManConstant.bombSize,
      isHost: isHost,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    stopCD.update(dt);

    if(currentDirection != ExplosionDirectionType.cross) {
      final oldCell = BomberUtils.getCoordinate(position);
      final directionForce = currentDirection.getVector2();
      position.add(directionForce.scaled(BomberManConstant.bombKickForceSpeed * dt));

      final nextCellPosition = position + directionForce.scaled(BomberManConstant.cellSide);
      final nextCell = BomberUtils.getCoordinate(nextCellPosition);
      if (oldCell.distanceTo(nextCell) == 1 && (checkHasPlayer(nextCell) || checkIsHitEnvironment(nextCell))) {
        stopSliding(oldCell);
      }
    }

  }

  void stopSliding(Point<int> stopCoordinate) {
    currentDirection = ExplosionDirectionType.cross;
    position = BomberUtils.getPositionCenter(stopCoordinate);
    stopCD.start();
  }

  @override
  Future<void> onLoad() async {
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

    if (other is PlayerComponent) {
      return;
      // final currentPosition = BomberUtils.getCoordinate(position);
      // final playerPosition = BomberUtils.getCoordinate(other.position);
      // switch(ExplosionDirectionType.getDirectionFromPoint(currentPosition - playerPosition)) {
      //   case final direction? when direction == currentDirection:
      //     return;
      //   case _:
      // }
    }
    stopSliding(BomberUtils.getCoordinate(position));
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
    _broadcastExplosion(explosionData);
  }

  void checkHitPlayers(Point<int> explosionPosition) {
    gameRef.query<PlayerComponent>()
        .where((player) => BomberUtils.getCoordinate(player.position) == explosionPosition)
        .forEach((player) => player.handleAttack(AttackOriginEnum.WORLD, 1000, this));
  }

  bool checkHasPlayer(Point<int> nextCell) {
    return gameRef.query<PlayerComponent>()
        .any((player) => BomberUtils.getCoordinate(player.position) == nextCell);
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
    if(stopCD.isRunning()) {
      return;
    }

    currentDirection = direction;
    myPrint('currentDirection: $currentDirection');
  }

  void _broadcastExplosion(List<(ExplosionDirectionType, Point<int>, bool)> explosionData) {
    final bombId = this.bombId;
    if (bombId == null) {
      return;
    }

    gameRef.query<RemoteManager>().firstOrNull?.pushRemovedObject(
          removeBombEvent: RemoveBombEvent(
            bombId: bombId,
            explosionData: explosionData,
          ),
        );
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

  static ExplosionDirectionType? getDirectionFromPoint(Point<int> point) {
    return switch(point) {
      Point<int>(x: 0, y: 0) => ExplosionDirectionType.cross,
      Point<int>(x: 0, y: <0) => ExplosionDirectionType.up,
      Point<int>(x: >0, y: 0) => ExplosionDirectionType.right,
      Point<int>(x: 0, y: >0) => ExplosionDirectionType.down,
      Point<int>(x: <0, y: 0) => ExplosionDirectionType.left,
      _ => null,
    };
  }

  static ExplosionDirectionType? getDirectionFromPointStrict(Point<int> point) {
    return switch(point) {
      Point<int>(x: 0, y: 0) => ExplosionDirectionType.cross,
      Point<int>(x: 0, y: -1) => ExplosionDirectionType.up,
      Point<int>(x: 1, y: 0) => ExplosionDirectionType.right,
      Point<int>(x: 0, y: 1) => ExplosionDirectionType.down,
      Point<int>(x: -1, y: 0) => ExplosionDirectionType.left,
      _ => null,
    };
  }

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
  }): super(anchor: Anchor.center) {
    priority = BomberManConstant.effect;
  }


  factory ExplosionAnimation.create({
    required List<(ExplosionDirectionType, Point<int>, bool)> explosionData,
  }) {

    final (_, coordinate, _) = explosionData.firstWhere((data) => data.$1 == ExplosionDirectionType.cross);
    final position = BomberUtils.getPositionCenter(coordinate);

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
    final (ExplosionDirectionType type, Point<int> coordinate, bool isEdge) = data;

    final double textureY = switch(type) {
      ExplosionDirectionType.cross => 0,
      _ when !isEdge => 49,
      _ => 97,
    };

    return GameDecoration.withAnimation(
      animation: SpriteAnimation.load(
        BomberManConstant.explode,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: BomberManConstant.explodeSize,
          texturePosition: Vector2(0, textureY),
          stepTime: explodeStepTime,
        ),
      ),
      position: BomberUtils.getPositionCenter(coordinate),
      anchor: Anchor.center,
      size: cellSize,
      angle: type.angle,
    );
  }
}
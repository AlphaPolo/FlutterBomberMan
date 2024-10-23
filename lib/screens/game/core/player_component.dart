import 'dart:math';

import 'package:bomber_man/screens/game/core/bomb_component.dart';
import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/core/remote_manager.dart';
import 'package:bomber_man/screens/game/network_event/network_event.dart';
import 'package:bomber_man/screens/game/utils/blink_effect.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bomber_man/screens/game/core/remote_player_component.dart';
import 'package:bonfire/bonfire.dart';

import '../../../providers/settings_provider.dart';
import '../../../utils/my_print.dart';
import '../utils/player_sprite_sheet.dart';

class PlayerComponent extends SimplePlayer with BlockMovementCollision, RemoteMixin, Notifier {
  static const double maxSpeed = BomberManConstant.maxSpeed;
  static const double defaultSpeed = BomberManConstant.defaultSpeed;
  final Vector2 halfSize = Vector2.zero();

  final BomberManKeyConfig keyConfig;

  @override
  final bool isHost;
  final int playerIndex;

  // ability
  int force = 1;
  int bombCapacity = 1;
  bool actionKick = false;
  bool actionThrow = false;


  /// for client network
  bool triggerBomb = false;

  PlayerComponent({
    required super.position,
    required this.keyConfig,
    required this.playerIndex,
    this.isHost = true,
  }) : super(
    animation: PlayerSpriteSheet.simpleDirectionAnimation(playerIndex),
    size: BomberManConstant.playerSize,
    speed: defaultSpeed,
    initDirection: Direction.down,
  ) {
    priority = BomberManConstant.player;
    renderAboveComponents = true;
  }

  @override
  Future<void> onLoad() {
    // debugMode = true;

    anchor = const Anchor(0.5, 2/3);
    final hitBoxPosition = Vector2(
      size.x * anchor.x,
      size.y * anchor.y,
    );
    add(
      CircleHitbox(
        position: hitBoxPosition,
        anchor: Anchor.center,
        radius: 26,
      ),
    );

    halfSize.setAll(26);
    return super.onLoad();
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    switch(other) {
      case PlayerComponent():
        return false;
      case BombComponent():
        return !other.ignoreList.contains(this);
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void onBlockedMovement(PositionComponent other, CollisionData collisionData) {
    // TODO: implement onBlockedMovement
    final v = velocity;
    super.onBlockedMovement(other, collisionData);

    checkKickBomb(other);
    velocity = v;
  }

  void checkKickBomb(PositionComponent other) {
    /// 如果沒有這個能力直接return
    if(!actionKick) {
      return;
    }

    if(other case BombComponent bomb) {
      myPrint(bomb.currentDirection);
      if(bomb.ignoreList.contains(this)) return;
      if(bomb.currentDirection != ExplosionDirectionType.cross) return;
      final currentPosition = BomberUtils.getCoordinate(position);
      final bombPosition = BomberUtils.getCoordinate(other.position);
      switch(ExplosionDirectionType.getDirectionFromPointStrict(bombPosition - currentPosition)) {
        case final direction? when direction != ExplosionDirectionType.cross:
          other.applyKickForce(direction);
        case _:
          myPrint('invalid kick direction');
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    checkOutOfBounds();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if(isDead) return;
    if(event case JoystickActionEvent(event: ActionEvent.DOWN)) {
      if(event.id == keyConfig.getLogicalKey(BomberManKey.actionBomb) || event.id == BomberManKey.actionBomb) {
        placeBomb();
      }
      if(event.id == keyConfig.getLogicalKey(BomberManKey.actionThrow)) {
        throwBomb();
      }
    }
    super.onJoystickAction(event);
  }

  void checkOutOfBounds() {
    position.clamp(halfSize, BomberManConstant.gameSize - halfSize);
  }

  void placeBomb() {
    if(!isHost) {
      triggerBomb = true;
      return;
    }

    final coordinate = BomberUtils.getCoordinate(position);

    if(alreadyOverBombCapacity()) {
      myPrint('超過最大炸彈數');
      return;
    }

    if(alreadyHasBomb(coordinate)) {
      myPrint('下方已經有炸彈');
      return;
    }

    if(gameRef.query<RemoteManager>().firstOrNull case final manager?) {
      manager.addBombAndBroadcast(this, coordinate);
    }
    else {
      gameRef.add(
        BombComponent.create(
          bombId: null,
          ownerPlayerIndex: playerIndex,
          coordinate: coordinate,
          configData: BombConfigData(force),
        ),
      );
    }
    myPrint('placeBomb');
  }

  void throwBomb() {
    myPrint(properties);
    myPrint('throwBomb');
  }

  bool alreadyOverBombCapacity() {
    return gameRef.query<BombComponent>()
        .where((bomb) => bomb.ownerPlayerIndex == playerIndex)
        .length >= bombCapacity;
  }

  bool alreadyHasBomb(Point<int> coordinate) {
    return gameRef.query<BombComponent>()
        .any((bomb) => BomberUtils.getCoordinate(bomb.position) == coordinate);
  }

  @override
  void onDie() {
    super.onDie();

    _broadcastDeadEvent();

    AnimatedGameObject? stub;

    stub = AnimatedGameObject(
      position: topLeftPosition,
      size: size,
      animation: animation?.others[PlayerSpriteSheet.playerDead],
      removeOnFinish: false,
      loop: false,
      onFinish: () {
        stub?.add(
          createBlinkEffect(
            type: BlinkType.fadeOut,
            onComplete: () {
              stub?.removeFromParent();
            },
          ),
        );
      },
    );

    gameRef.add(
      stub,
    );


    removeFromParent();
    myPrint('player onDie');
  }

  bool consumeBombTrigger() {
    if(triggerBomb) {
      myPrint('consume');
      triggerBomb = false;
      return true;
    }
    return false;
  }

  void _broadcastDeadEvent() {
    gameRef.query<RemoteManager>()
        .firstOrNull
        ?.pushRemovedObject(
      playerDeadEvent: PlayerDeadEvent(playerIndex: playerIndex),
    );
  }

}
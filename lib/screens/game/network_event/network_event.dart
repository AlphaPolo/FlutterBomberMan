import 'dart:math';

import 'package:bomber_man/screens/game/core/ability.dart';
import 'package:bonfire/bonfire.dart';

import '../core/bomb_component.dart';

sealed class PeerMessage {
  const PeerMessage();

  factory PeerMessage.parse(Map<String, dynamic> data) {
    return switch (data['type']) {
      GameInitMessage.type => GameInitMessage.fromJson(data),
      GameUpdateMessage.type => GameUpdateMessage.fromJson(data),
      _ => throw 'Error PeerMessage',
    };
  }
}

class GameInitMessage extends PeerMessage {
  static const String type = 'GameInit';

  final int gameId;
  final String initialMap;

  const GameInitMessage({
    required this.gameId,
    required this.initialMap,
  });

  factory GameInitMessage.fromJson(Map<String, dynamic> json) {
    return GameInitMessage(
      gameId: json['gameId'],
      initialMap: json['initialMap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'gameId': gameId,
      'initialMap': initialMap,
    };
  }
}

/// Host Receive Guest Message
class GamePreparedMessage extends PeerMessage {
  static const String type = 'GamePrepared';

  const GamePreparedMessage();
}

/// GameStart
class GameStartMessage extends PeerMessage {
  static const String type = 'GameStart';

  const GameStartMessage();
}

class GameUpdateMessage extends PeerMessage {
  static const String type = 'GameUpdate';

  final double timestamp;
  final List<GameEventData> data;

  const GameUpdateMessage({
    required this.timestamp,
    required this.data,
  });

  factory GameUpdateMessage.fromJson(Map<String, dynamic> json) {
    return GameUpdateMessage(
      timestamp: json['timestamp'],
      data: [
        for(final e in (json['data'] as List))
          GameEventData.parse(e),
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp,
      'data': [
        for(final e in data)
          e.toJson(),
      ],
    };
  }
}

sealed class GameEventData {
  const GameEventData();

  factory GameEventData.parse(Map<String, dynamic> json) {
    return switch (json['tag']) {
      PlayerPositionData.tag => PlayerPositionData.fromJson(json),
      DropBombData.tag => DropBombData.fromJson(json),
      RemoveBombEvent.tag => RemoveBombEvent.fromJson(json),
      BrickDestroyedData.tag => BrickDestroyedData.fromJson(json),
      PlayerDeadEvent.tag => PlayerDeadEvent.fromJson(json),
      _ => throw 'GameEventData error',
    };
  }

  Map<String, dynamic> toJson();
}

class PlayerPositionData extends GameEventData {
  static const String tag = 'PlayerMove';

  final int playerIndex;
  final Offset newPosition;
  final SimpleAnimationEnum currentAnimation;

  const PlayerPositionData({
    required this.playerIndex,
    required this.newPosition,
    required this.currentAnimation,
  });

  factory PlayerPositionData.fromJson(Map<String, dynamic> json) {
    return PlayerPositionData(
      playerIndex: json['playerIndex'],
      newPosition: Offset(
        json['newPosition']['x'],
        json['newPosition']['y'],
      ),
      currentAnimation: SimpleAnimationEnum.values[json['currentAnimation']],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'playerIndex': playerIndex,
      'newPosition': {
        'x': newPosition.dx,
        'y': newPosition.dy,
      },
      'currentAnimation': currentAnimation.index,
    };
  }
}

class DropBombData extends GameEventData {
  static const String tag = 'DropBomb';

  final int? bombId;
  final int playerIndex;
  final Point<int> coordinate;


  const DropBombData.client({
    required this.playerIndex,
    required this.coordinate,
  }): bombId = null;

  const DropBombData({
    required this.bombId,
    required this.playerIndex,
    required this.coordinate,
  });

  factory DropBombData.fromJson(Map<String, dynamic> json) {
    return DropBombData(
      bombId: json['bombId'],
      playerIndex: json['playerIndex'],
      coordinate: Point<int>(
        json['coordinate']['x'],
        json['coordinate']['y'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'bombId': bombId,
      'playerIndex': playerIndex,
      'coordinate': {
        'x': coordinate.x,
        'y': coordinate.y,
      },
    };
  }

}

class RemoveBombEvent extends GameEventData {
  static const String tag = 'RemoveBomb';

  final int bombId;
  final List<(ExplosionDirectionType, Point<int>, bool)> explosionData;

  const RemoveBombEvent({
    required this.bombId,
    this.explosionData = const [],
  });

  factory RemoveBombEvent.fromJson(Map<String, dynamic> json) {
    return RemoveBombEvent(
      bombId: json['bombId'],
      explosionData: [
        for(final data in json['explosionData'] as List)
          (
            ExplosionDirectionType.values[data['explosionDirectionType']],
            Point<int>(data['coordinate']['x'], data['coordinate']['y']),
            data['isEdge'],
          ),
      ],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'bombId': bombId,
      'explosionData': [
        for(final data in explosionData)
          {
            'explosionDirectionType': data.$1.index,
            'coordinate': {
              'x': data.$2.x,
              'y': data.$2.y,
            },
            'isEdge': data.$3,
          },
      ],
    };
  }

}


class BrickDestroyedData extends GameEventData {

  static const String tag = 'BrickDestroyed';

  final Point<int> coordinate;
  final Ability? ability;

  const BrickDestroyedData({
    required this.coordinate,
    this.ability,
  });

  factory BrickDestroyedData.fromJson(Map<String, dynamic> json) {
    return BrickDestroyedData(
      coordinate: Point<int>(
        json['coordinate']['x'],
        json['coordinate']['y'],
      ),
      ability: switch(json['ability']) {
        AbilityCapacity.tag => AbilityCapacity(),
        AbilitySpeed.tag => AbilitySpeed(),
        AbilityKick.tag => AbilityKick(),
        AbilityThrow.tag => AbilityThrow(),
        AbilityPower.tag => AbilityPower(),
        AbilitySkull.tag => AbilitySkull(),
        AbilityGoldenPower.tag => AbilityGoldenPower(),
        _ => null,
      },
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'coordinate': {
        'x': coordinate.x,
        'y': coordinate.y,
      },
      'ability': switch(ability) {
        AbilityCapacity() => AbilityCapacity.tag,
        AbilitySpeed() => AbilitySpeed.tag,
        AbilityKick() => AbilityKick.tag,
        AbilityThrow() => AbilityThrow.tag,
        AbilityPower() => AbilityPower.tag,
        AbilitySkull() => AbilitySkull.tag,
        AbilityGoldenPower() => AbilityGoldenPower.tag,
        _ => null,
      },
    };
  }
}

class PlayerDeadEvent extends GameEventData {

  static const String tag = 'PlayerDead';

  final int playerIndex;

  const PlayerDeadEvent({
    required this.playerIndex,
  });

  factory PlayerDeadEvent.fromJson(Map<String, dynamic> json) {
    return PlayerDeadEvent(
      playerIndex: json['playerIndex'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'playerIndex': playerIndex,
    };
  }
}
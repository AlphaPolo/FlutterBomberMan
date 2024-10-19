import 'dart:math';

import 'package:bonfire/bonfire.dart';

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
      data: (json['data'] as List).map((e) => GameEventData.parse(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

sealed class GameEventData {
  const GameEventData();

  factory GameEventData.parse(Map<String, dynamic> json) {
    return switch (json['tag']) {
      PlayerPositionData.tag => PlayerPositionData.fromJson(json),
      DropBombData.tag => DropBombData.fromJson(json),
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

  final int playerIndex;
  final Point<int> coordinate;

  const DropBombData({
    required this.playerIndex,
    required this.coordinate,
  });

  factory DropBombData.fromJson(Map<String, dynamic> json) {
    return DropBombData(
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
      'playerIndex': playerIndex,
      'coordinate': {
        'x': coordinate.x,
        'y': coordinate.y,
      },
    };
  }

}
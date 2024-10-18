import 'dart:math';

import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/screens/online_game/core/remote_player_component.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bomber_man/utils/my_print.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:provider/provider.dart';

import '../screens/online_game/multi_game_screen.dart';
import 'settings_provider.dart';

class PeerProvider extends ChangeNotifier {

  final Peer _peer = Peer(
    options: PeerOptions(
      debug: LogLevel.All,
      key: 'AlphaPoloBomberMan',
    ),
  );

  late DataConnection _conn;

  String? _peerId;
  bool _connected = false;

  String? get peerId => _peerId;
  bool get connected => _connected;


  final Set<String> _connections = {};

  void Function(GameUpdateMessage message)? _callback;

  int get connections => _connections.length;

  PeerProvider(BuildContext context) {
    _peer.on("open").listen((id) {
      _peerId = _peer.id;
      notifyListeners();
    });

    _peer.on("close").listen((id) {
      _connected = false;
      notifyListeners();
    });

    _setHostListener(context);
  }

  void connect(BuildContext context, String id) {
    final connection = _peer.connect(id);
    _conn = connection;

    _setGuestListener(connection, context);
  }

  @override
  void dispose() {
    // _peer.close();
    _callback = null;
    _peer.dispose();
    super.dispose();
  }

  void _setHostListener(BuildContext context) {
    _peer.on<DataConnection>("connection").listen((conn) {
      /// FIXME:目前只接受另一個玩家
      if(_connections.isNotEmpty) {
        _peer.removeConnection(conn);
        return;
      }


      _conn = conn;
      _connections.add(_conn.connectionId);
      myPrint('host receive data: $conn');

      _conn.on("data").listen((data) {
        if(!context.mounted) return;

        myPrint('host receive data: $data');

        switch(PeerMessage.parse(data)) {
          case GameInitMessage(:final gameId, :final initialMap):
            myPrint('GameInitMessageEvent: $gameId, $initialMap');
            _onPlay(context, initialMap);
        // case GameUpdateMessage(:final timestamp, :final data):
          case GameUpdateMessage gameUpdateMessage:
            _callback?.call(gameUpdateMessage);
          case _:
        }

        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text(data)));
      });

      _conn.on("binary").listen((data) {
        if(!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Got binary")));
      });

      _conn.on("close").listen((event) {
        _connections.remove(conn.connectionId);
        myPrint('host onReceive close');
        _connected = false;
        notifyListeners();
      });

      _connected = true;
      notifyListeners();
    });
  }

  void _setGuestListener(DataConnection connection, BuildContext context) {
    _conn.on("open").listen((event) {
      _connected = true;
      notifyListeners();

      connection.on("close").listen((event) {
        _connected = false;
        notifyListeners();
      });

      connection.on("data").listen((data) {
        if(!context.mounted) return;
        myPrint('Guest onData: $data');

        switch(PeerMessage.parse(data)) {
          case GameInitMessage(:final gameId, :final initialMap):
            myPrint('GameInitMessageEvent: $gameId, $initialMap');
            _onPlay(context, initialMap);
          // case GameUpdateMessage(:final timestamp, :final data):
          case GameUpdateMessage gameUpdateMessage:
            _callback?.call(gameUpdateMessage);
          case _:
        }

        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text(data)));
      });

      connection.on("binary").listen((data) {
        if(!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Got binary!")));
      });
    });
  }

  /// host function
  /// FIXME: _conn need to be array
  void play(BuildContext context) async {
    const initialMap = 'village_10.json';
    await _conn.send(
      const GameInitMessage(
        gameId: 1,
        initialMap: initialMap,
      ),
    );

    if(!context.mounted) return;

    Navigator.of(context).push(
      MultiGameScreen.route(
        firstPlayer: PlayerComponent(
          position: BomberUtils.getPositionCenter(
            const Point<int>(0, 0),
          ),
          keyConfig: context.read<SettingsProvider>().player1KeyConfig,
          playerIndex: 0,
          // color: Colors.red,
        ),
        secondPlayer: RemotePlayerComponent(
          position: BomberUtils.getPositionCenter(
            const Point<int>(14, 12),
          ),
          playerIndex: 1,
          // connection: _conn,
        ),
        map: initialMap,
        provider: this,
      ),
    );
  }

  void _onPlay(BuildContext context, String initialMap) async {
    if(!context.mounted) return;

    Navigator.of(context).push(
      MultiGameScreen.route(
        firstPlayer: RemotePlayerComponent(
          position: BomberUtils.getPositionCenter(
            const Point<int>(0, 0),
          ),
          playerIndex: 0,
          // color: Colors.red,
        ),
        secondPlayer: PlayerComponent(
          position: BomberUtils.getPositionCenter(
            const Point<int>(14, 12),
          ),
          keyConfig: context.read<SettingsProvider>().player1KeyConfig,
          playerIndex: 1,
        ),
        map: initialMap,
        provider: this,
      ),
    );
  }


  void send(dynamic data) {
    _conn.send(data);
  }

  void setOnGameUpdateListener(void Function(GameUpdateMessage) callback) {
    _callback = callback;
  }

}


sealed class PeerMessage {
  const PeerMessage();


  factory PeerMessage.parse(Map<String, dynamic> data) {
    return switch(data['type']) {
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

  final int timestamp;
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
    return switch(json['tag']) {
      PlayerPositionData.tag => PlayerPositionData.fromJson(json),
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



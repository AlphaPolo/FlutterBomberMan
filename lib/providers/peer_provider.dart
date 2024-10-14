import 'package:bomber_man/utils/my_print.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data)));
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data)));
      });

      connection.on("binary").listen((data) {
        if(!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Got binary!")));
      });
    });
  }
}


sealed class PeerMessage {
  const PeerMessage();


  factory PeerMessage.parse() {
    return GameInitMessage.fromJson({});
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
    return const GameInitMessage(
      gameId: 1,
      initialMap: 'village_10.map',
    );
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

  const GameUpdateMessage({
    required this.timestamp,
  });

  factory GameUpdateMessage.fromJson(Map<String, dynamic> json) {
    return GameUpdateMessage(
      timestamp: json['timestamp'],
    );
  }


}




sealed class GameEventData {
  const GameEventData();

}

class PlayerPositionData extends GameEventData {

  static const String tag = 'PlayerMove';

  final int playerIndex;
  final Offset newPosition;



  const PlayerPositionData({
    required this.playerIndex,
    required this.newPosition,
  });

  factory PlayerPositionData.fromJson(Map<String, dynamic> json) {
    return PlayerPositionData(
      playerIndex: json['playerIndex'],
      newPosition: Offset(
        json['newPosition']['x'],
        json['newPosition']['y'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerIndex': playerIndex,
      'newPosition': {
        'x': newPosition.dx,
        'y': newPosition.dy,
      },
    };
  }
}



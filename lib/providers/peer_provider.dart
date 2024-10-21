import 'dart:math';

import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:bomber_man/screens/game/core/remote_player_component.dart';
import 'package:bomber_man/screens/game/utils/bomber_utils.dart';
import 'package:bomber_man/utils/my_print.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:provider/provider.dart';

import '../screens/game/multi_game_screen.dart';
import '../screens/game/network_event/network_event.dart';
import 'settings_provider.dart';

class PeerProvider extends ChangeNotifier {

  final Peer _peer = Peer(
    options: PeerOptions(
      // debug: LogLevel.All,
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
  void Function()? _onDisconnectCallback;

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

      _conn.on("data").listen((data) {
        if(!context.mounted) return;

        switch(PeerMessage.parse(data)) {
          case GameInitMessage(:final gameId, :final initialMap):
            myPrint('GameInitMessageEvent: $gameId, $initialMap');
            _onPlay(context, initialMap);
          case GameUpdateMessage gameUpdateMessage:
            _callback?.call(gameUpdateMessage);
          case _:
        }
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
        _onDisconnectCallback?.call();
      });

      _connected = true;
      notifyListeners();
    });
  }

  void _setGuestListener(DataConnection connection, BuildContext context) {
    _conn.on("open").listen((event) {
      _connections.add(connection.connectionId);
      _connected = true;
      notifyListeners();

      connection.on("close").listen((event) {
        _connections.remove(connection.connectionId);
        _connected = false;
        notifyListeners();
        _onDisconnectCallback?.call();
      });

      connection.on("data").listen((data) {
        if(!context.mounted) return;

        switch(PeerMessage.parse(data)) {
          case GameInitMessage(:final gameId, :final initialMap):
            myPrint('GameInitMessageEvent: $gameId, $initialMap');
            _onPlay(context, initialMap);
          case GameUpdateMessage gameUpdateMessage:
            _callback?.call(gameUpdateMessage);
          case _:
        }
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

    await Navigator.of(context).push(
      MultiGameScreen.route(
        firstPlayer: PlayerComponent(
          position: BomberUtils.getPositionCenter(
            const Point<int>(0, 0),
          ),
          keyConfig: context.read<SettingsProvider>().networkKeyConfig,
          playerIndex: 0,
          isHost: true,
        ),
        secondPlayer: RemotePlayerComponent(
          position: BomberUtils.getPositionCenter(
            const Point<int>(14, 12),
          ),
          playerIndex: 1,
          isHost: true,
        ),
        map: initialMap,
        provider: this,
        isHost: true,
      ),
    );

    _disconnect();

    if(!context.mounted) return;
    Navigator.pop(context);
  }

  void _onPlay(BuildContext context, String initialMap) async {
    if(!context.mounted) return;

    await Navigator.of(context).push(
      MultiGameScreen.route(
        firstPlayer: RemotePlayerComponent(
          position: BomberUtils.getPositionCenter(
            const Point<int>(0, 0),
          ),
          playerIndex: 0,
          isHost: false,
        ),
        secondPlayer: PlayerComponent(
          position: BomberUtils.getPositionCenter(
            const Point<int>(14, 12),
          ),
          keyConfig: context.read<SettingsProvider>().networkKeyConfig,
          playerIndex: 1,
          isHost: false,
        ),
        map: initialMap,
        provider: this,
        isHost: false,
      ),
    );

    _disconnect();

    if(!context.mounted) return;
    Navigator.pop(context);
  }

  void _disconnect() {
    _conn.dispose();
    _connected = false;
    _connections.clear();
    _peer.disconnect();
    notifyListeners();
  }


  void send(dynamic data) {
    _conn.send(data);
  }

  void setOnGameUpdateListener(void Function(GameUpdateMessage)? callback) {
    _callback = callback;
  }

  void setDisconnectListener(void Function()? callback) {
    _onDisconnectCallback = callback;
  }

}






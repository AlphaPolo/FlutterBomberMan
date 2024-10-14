// import 'dart:async';
//
// import 'package:nakama/nakama.dart';
// import 'package:uuid/uuid.dart';
//
// enum NakamaStatus {
//   connecting,
//   connected,
//   failure,
// }
//
// class NakamaProvider {
//   final StreamController<NakamaStatus> _controller = StreamController.broadcast();
//
//   late final NakamaBaseClient client;
//
//
//   late final Stream<NakamaStatus> nakamaStatusStream = _controller.stream;
//
//   NakamaProvider() {
//     initState();
//   }
//
//   void initState() async {
//     _controller.add(NakamaStatus.connecting);
//
//     client = getNakamaClient(
//       host: '127.0.0.1', // 替换成你的Nakama服务器IP或域名
//       ssl: false,
//       serverKey: 'defaultkey',
//     );
//
//     const uuid = Uuid();
//     final deviceId = uuid.v4();
//
//     await client.authenticateDevice(deviceId: deviceId).then((session) {
//       NakamaWebsocketClient.init(
//         host: '127.0.0.1',
//         ssl: false,
//         token: session.token,
//       );
//       // client.close();
//       _controller.add(NakamaStatus.connected);
//     }).catchError((error) {
//       _controller.add(NakamaStatus.failure);
//     });
//   }
//
//   void dispose() {
//     _controller.close();
//     NakamaWebsocketClient.instance.close();
//   }
// }

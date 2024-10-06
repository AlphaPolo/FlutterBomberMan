// import 'dart:async';
// import 'dart:ui';
//
// import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
// import 'package:bomber_man/screens/game/core/map_parser.dart';
// import 'package:flame/components.dart';
// import 'package:flame/game.dart';
// import 'package:flame/input.dart';
//
// class BomberManGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
//
//   static const Size gameContentSize = BomberManConstant.gameContentSize;
//
//
//   BomberManGame();
//
//   @override
//   FutureOr<void> onLoad() async {
//
//     world = BomberManGameWorld();
//
//     camera = CameraComponent.withFixedResolution(
//       width: gameContentSize.width,
//       height: gameContentSize.height,
//       world: world,
//     ) ..viewfinder.anchor = Anchor.topLeft
//       ..addAll([
//         FpsTextComponent(),
//       ]);
//
//     await addAll([world]);
//
//   }
//
// }
//
// class BomberManGameWorld extends World with HasGameReference<BomberManGame> {
//   @override
//   FutureOr<void> onLoad() async {
//     final components = await MapParser.parse('assets/map/village_10.map');
//     await addAll(components);
//   }
// }
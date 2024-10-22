import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 在應用啟動前預加載圖片資源
  await Flame.images.loadAll([
    BomberManConstant.tiles,
    BomberManConstant.explode,
    BomberManConstant.spritesheet,
  ]);
  runApp(const MyApp());
}
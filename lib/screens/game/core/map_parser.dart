import 'dart:async';
import 'dart:math';

import 'package:bomber_man/providers/settings_provider.dart';
import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bomber_man/screens/game/core/player_component.dart';
import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapParser {


  const MapParser._();


  static Future<List<PositionComponent>> parse(String path) async {
    final response = await rootBundle.loadString(path);

    Map<String, PositionComponent Function(Point<int>)> mapParser = {
      'B' : (coordinate) => BlockObject.createFromMap(coordinate),
      '1' : (coordinate) => PlayerComponent.createFromMap(coordinate, BomberManKeyConfig.player1()),
      // 'B' : (coordinate) => BlockObject.createFromMap(coordinate),
      // 'B' : (coordinate) => BlockObject.createFromMap(coordinate),
    };

    // for(final (int y, String line) in response.split('\n').mapIndexed((y, line) => (y, line))) {
    //
    // }


    final components = response.split('\n')
      .expandIndexed((y, line) {
        return line.trim()
            .split(',')
            .mapIndexed((x, token) => mapParser[token]?.call(Point(x, y)));
      })
      .whereNotNull()
      // .sortedByCompare((component) => component is PlayerComponent ? 1 : 0, (a, b) => a.compareTo(b))
      .toList();

    return components;
  }

}

class BlockObject extends PositionedEntity {
  BlockObject._({
    super.priority = BomberManConstant.environment,
    super.position,
    super.size,
    Iterable<Behavior>? behaviors,
  }) : super(
    behaviors: [
      if(behaviors != null) ...behaviors,
    ],
  );

  @override
  FutureOr<void> onLoad() async {
    debugMode = true;
    addAll([
      RectangleComponent.relative(
        Vector2.all(1),
        parentSize: size,
        paint: Paint()..color = Colors.grey,
      ),
      RectangleHitbox(),
    ]);
  }

  factory BlockObject.createFromMap(Point<int> coordinate) {
    return BlockObject._(
      position: Vector2(
        coordinate.x * BomberManConstant.cellSize.width,
        coordinate.y * BomberManConstant.cellSize.height,
      ),
      size: BomberManConstant.cellSize.toVector2(),
    );
  }

}

class EmptyObject {
  const EmptyObject();
}
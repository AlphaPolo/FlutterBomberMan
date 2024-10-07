import 'package:bonfire/bonfire.dart';

class ObjectSpriteSheet {


  const ObjectSpriteSheet._();


  static Future<SpriteAnimation> get bomb => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.157,
        textureSize: Vector2.all(16),
        texturePosition: Vector2(0, 97),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: Vector2.all(16),
        srcPosition: Vector2(16, 97),
        stepTime: 0.157,
      ),
    ]),
  );

  static Future<Sprite> get brick => Sprite.load(
    'wall_tile.png',
  );

  static Future<Sprite> get brick2 => Sprite.load(
    'tiled/tiles.png',
    srcSize: Vector2.all(16),
    srcPosition: Vector2(64, 48),
  );
}
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

  static Future<Sprite> get abilityCapacity => Sprite.load(
    'spritesheet.png',
    srcSize: Vector2.all(16),
    srcPosition: Vector2(0, 131),
  );

  static Future<Sprite> get abilitySpeed => Sprite.load(
    'spritesheet.png',
    srcSize: Vector2.all(16),
    srcPosition: Vector2(17, 131),
  );

  static Future<Sprite> get abilityKick => Sprite.load(
    'spritesheet.png',
    srcSize: Vector2.all(16),
    srcPosition: Vector2(34, 131),
  );

  static Future<Sprite> get abilityThrow => Sprite.load(
    'spritesheet.png',
    srcSize: Vector2.all(16),
    srcPosition: Vector2(51, 131),
  );

  static Future<Sprite> get abilityPower => Sprite.load(
    'spritesheet.png',
    srcSize: Vector2.all(16),
    srcPosition: Vector2(68, 131),
  );

  static Future<Sprite> get abilitySkull => Sprite.load(
    'spritesheet.png',
    srcSize: Vector2.all(16),
    srcPosition: Vector2(85, 131),
  );

  static Future<Sprite> get abilityGoldenPower => Sprite.load(
    'spritesheet.png',
    srcSize: Vector2.all(16),
    srcPosition: Vector2(102, 131),
  );
}
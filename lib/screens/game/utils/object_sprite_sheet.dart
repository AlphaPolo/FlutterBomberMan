import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bonfire/bonfire.dart';

class ObjectSpriteSheet {


  const ObjectSpriteSheet._();


  static Future<SpriteAnimation> get bomb => SpriteAnimation.load(
    BomberManConstant.spritesheet,
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
    BomberManConstant.tiles,
    srcSize: Vector2.all(16),
    srcPosition: Vector2(64, 48),
  );

  static Future<Sprite> get abilityCapacity => Sprite.load(
    BomberManConstant.spritesheet,
    srcSize: Vector2.all(16),
    srcPosition: Vector2(0, 131),
  );

  static Future<Sprite> get abilitySpeed => Sprite.load(
    BomberManConstant.spritesheet,
    srcSize: Vector2.all(16),
    srcPosition: Vector2(17, 131),
  );

  static Future<Sprite> get abilityKick => Sprite.load(
    BomberManConstant.spritesheet,
    srcSize: Vector2.all(16),
    srcPosition: Vector2(34, 131),
  );

  static Future<Sprite> get abilityThrow => Sprite.load(
    BomberManConstant.spritesheet,
    srcSize: Vector2.all(16),
    srcPosition: Vector2(51, 131),
  );

  static Future<Sprite> get abilityPower => Sprite.load(
    BomberManConstant.spritesheet,
    srcSize: Vector2.all(16),
    srcPosition: Vector2(68, 131),
  );

  static Future<Sprite> get abilitySkull => Sprite.load(
    BomberManConstant.spritesheet,
    srcSize: Vector2.all(16),
    srcPosition: Vector2(85, 131),
  );

  static Future<Sprite> get abilityGoldenPower => Sprite.load(
    BomberManConstant.spritesheet,
    srcSize: Vector2.all(16),
    srcPosition: Vector2(102, 131),
  );
}
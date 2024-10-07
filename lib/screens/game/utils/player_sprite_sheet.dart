import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {

  static final Vector2 playerTextureSize = Vector2(16, 24);

  static Vector2 getPlayerTexturePosition(int x, int y) {
    return Vector2(
      playerTextureSize.x * x,
      playerTextureSize.y * y,
    );
  }

  static Future<SpriteAnimation> get idleUp => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData.sequenced(
      amount: 1,
      textureSize: playerTextureSize,
      texturePosition: getPlayerTexturePosition(10, 0),
      stepTime: 0.5,
    ),
  );

  static Future<SpriteAnimation> get idleDown => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData.sequenced(
      amount: 1,
      textureSize: playerTextureSize,
      texturePosition: getPlayerTexturePosition(1, 0),
      stepTime: 0.5,
    ),
  );

  static Future<SpriteAnimation> get idleLeft => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData.sequenced(
      amount: 1,
      textureSize: playerTextureSize,
      texturePosition: getPlayerTexturePosition(4, 0),
      stepTime: 0.5,
    ),
  );

  static Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData.sequenced(
      amount: 1,
      textureSize: playerTextureSize,
      texturePosition: getPlayerTexturePosition(7, 0),
      stepTime: 0.5,
    ),
  );

  static Future<SpriteAnimation> get runUp => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: playerTextureSize,
        texturePosition: getPlayerTexturePosition(9, 0),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: playerTextureSize,
        srcPosition: getPlayerTexturePosition(10, 0),
        stepTime: 0.1,
      ),
    ]),
  );

  static Future<SpriteAnimation> get runDown => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: playerTextureSize,
        texturePosition: getPlayerTexturePosition(0, 0),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: playerTextureSize,
        srcPosition: getPlayerTexturePosition(1, 0),
        stepTime: 0.1,
      ),
    ]),
  );


  static Future<SpriteAnimation> get runLeft => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: playerTextureSize,
        texturePosition: getPlayerTexturePosition(3, 0),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: playerTextureSize,
        srcPosition: getPlayerTexturePosition(4, 0),
        stepTime: 0.1,
      ),
    ]),
  );

  static Future<SpriteAnimation> get runRight => SpriteAnimation.load(
    "spritesheet.png",
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: playerTextureSize,
        texturePosition: getPlayerTexturePosition(6, 0),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: playerTextureSize,
        srcPosition: getPlayerTexturePosition(7, 0),
        stepTime: 0.1,
      ),
    ]),
  );

  static SimpleDirectionAnimation get simpleDirectionAnimation =>
      SimpleDirectionAnimation(
        idleUp: idleUp,
        idleDown: idleDown,
        idleLeft: idleLeft,
        idleRight: idleRight,
        runUp: runUp,
        runDown: runDown,
        runLeft: runLeft,
        runRight: runRight,
      );
}
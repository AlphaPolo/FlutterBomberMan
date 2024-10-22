import 'package:bomber_man/screens/game/core/bomber_man_constant.dart';
import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {

  const PlayerSpriteSheet._();

  static const String playerDead = 'playerDead';

  static final Vector2 playerTextureSize = Vector2(16, 24);

  static Vector2 getPlayerTexturePosition(int x, int playerIndex) {
    return Vector2(
      playerTextureSize.x * x,
      playerTextureSize.y * playerIndex,
    );
  }

  static Future<SpriteAnimation> idleUp(int playerIndex) => SpriteAnimation.load(
    BomberManConstant.spritesheet,
    SpriteAnimationData.sequenced(
      amount: 1,
      textureSize: playerTextureSize,
      texturePosition: getPlayerTexturePosition(10, playerIndex),
      stepTime: 0.5,
    ),
  );

  static Future<SpriteAnimation> idleDown(int playerIndex) => SpriteAnimation.load(
    BomberManConstant.spritesheet,
    SpriteAnimationData.sequenced(
      amount: 1,
      textureSize: playerTextureSize,
      texturePosition: getPlayerTexturePosition(1, playerIndex),
      stepTime: 0.5,
    ),
  );

  static Future<SpriteAnimation> idleLeft(int playerIndex) => SpriteAnimation.load(
    BomberManConstant.spritesheet,
    SpriteAnimationData.sequenced(
      amount: 1,
      textureSize: playerTextureSize,
      texturePosition: getPlayerTexturePosition(4, playerIndex),
      stepTime: 0.5,
    ),
  );

  static Future<SpriteAnimation> idleRight(int playerIndex) => SpriteAnimation.load(
    BomberManConstant.spritesheet,
    SpriteAnimationData.sequenced(
      amount: 1,
      textureSize: playerTextureSize,
      texturePosition: getPlayerTexturePosition(7, playerIndex),
      stepTime: 0.5,
    ),
  );

  static Future<SpriteAnimation> runUp(int playerIndex) => SpriteAnimation.load(
    BomberManConstant.spritesheet,
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: playerTextureSize,
        texturePosition: getPlayerTexturePosition(9, playerIndex),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: playerTextureSize,
        srcPosition: getPlayerTexturePosition(10, playerIndex),
        stepTime: 0.1,
      ),
    ]),
  );

  static Future<SpriteAnimation> runDown(int playerIndex) => SpriteAnimation.load(
    BomberManConstant.spritesheet,
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: playerTextureSize,
        texturePosition: getPlayerTexturePosition(0, playerIndex),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: playerTextureSize,
        srcPosition: getPlayerTexturePosition(1, playerIndex),
        stepTime: 0.1,
      ),
    ]),
  );


  static Future<SpriteAnimation> runLeft(int playerIndex) => SpriteAnimation.load(
    BomberManConstant.spritesheet,
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: playerTextureSize,
        texturePosition: getPlayerTexturePosition(3, playerIndex),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: playerTextureSize,
        srcPosition: getPlayerTexturePosition(4, playerIndex),
        stepTime: 0.1,
      ),
    ]),
  );

  static Future<SpriteAnimation> runRight(int playerIndex) => SpriteAnimation.load(
    BomberManConstant.spritesheet,
    SpriteAnimationData([
      ...SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: playerTextureSize,
        texturePosition: getPlayerTexturePosition(6, playerIndex),
      ).frames,
      SpriteAnimationFrameData(
        srcSize: playerTextureSize,
        srcPosition: getPlayerTexturePosition(7, playerIndex),
        stepTime: 0.1,
      ),
    ]),
  );

  static Future<SpriteAnimation> dead(int playerIndex) =>
      SpriteAnimation.load(
        BomberManConstant.spritesheet,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: playerTextureSize,
          texturePosition: getPlayerTexturePosition(12, playerIndex),
          loop: false,
        ),
      );

  static SimpleDirectionAnimation simpleDirectionAnimation(int playerIndex) =>
      SimpleDirectionAnimation(
        // eightDirection: true,
        enabledFlipX: false,
        // centerAnchor: true,
        idleUp: idleUp(playerIndex),
        idleDown: idleDown(playerIndex),
        idleLeft: idleLeft(playerIndex),
        idleRight: idleRight(playerIndex),
        runUp: runUp(playerIndex),
        runDown: runDown(playerIndex),
        runLeft: runLeft(playerIndex),
        runRight: runRight(playerIndex),
        others: {
          playerDead: dead(playerIndex),
        },
      );
}
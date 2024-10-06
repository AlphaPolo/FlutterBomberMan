import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SettingsProvider extends ChangeNotifier {
  BomberManKeyConfig _player1KeyConfig = BomberManKeyConfig.player1();
  BomberManKeyConfig _player2KeyConfig = BomberManKeyConfig.player2();

  BomberManKeyConfig get player1KeyConfig => _player1KeyConfig;
  BomberManKeyConfig get player2KeyConfig => _player2KeyConfig;

  set player1KeyConfig(BomberManKeyConfig value) {
    _player1KeyConfig = value;
    notifyListeners();
  }

  set player2KeyConfig(BomberManKeyConfig value) {
    _player2KeyConfig = value;
    notifyListeners();
  }
}

enum BomberManPlayer {
  player1,
  player2,
  player3,
  player4,
}

enum BomberManKey {
  moveUp('UP'),
  moveDown('DOWN'),
  moveLeft('LEFT'),
  moveRight('RIGHT'),
  actionBomb('BOMB'),
  actionThrow('THROW'),
  ;

  const BomberManKey(this.description);

  final String description;
}

class BomberManKeyConfig {
  /// should only read
  final Map<BomberManKey, LogicalKeyboardKey> keyMap;

  const BomberManKeyConfig._(
    this.keyMap,
  );

  /// default Player 1 key setting
  factory BomberManKeyConfig.player1() {
    return const BomberManKeyConfig._({
      BomberManKey.moveUp: LogicalKeyboardKey.keyW,
      BomberManKey.moveRight: LogicalKeyboardKey.keyD,
      BomberManKey.moveDown: LogicalKeyboardKey.keyS,
      BomberManKey.moveLeft: LogicalKeyboardKey.keyA,
      BomberManKey.actionBomb: LogicalKeyboardKey.keyY,
      BomberManKey.actionThrow: LogicalKeyboardKey.keyT,
    });
  }

  /// default Player 2 key setting
  factory BomberManKeyConfig.player2() {
    return const BomberManKeyConfig._({
      BomberManKey.moveUp: LogicalKeyboardKey.arrowUp,
      BomberManKey.moveRight: LogicalKeyboardKey.arrowRight,
      BomberManKey.moveDown: LogicalKeyboardKey.arrowDown,
      BomberManKey.moveLeft: LogicalKeyboardKey.arrowLeft,
      BomberManKey.actionBomb: LogicalKeyboardKey.numpad2,
      BomberManKey.actionThrow: LogicalKeyboardKey.numpad1,
    });
  }

  factory BomberManKeyConfig.custom({
    required LogicalKeyboardKey keyUp,
    required LogicalKeyboardKey keyRight,
    required LogicalKeyboardKey keyDown,
    required LogicalKeyboardKey keyLeft,
    required LogicalKeyboardKey keyBomb,
    required LogicalKeyboardKey keyThrow,
  }) {
    return BomberManKeyConfig._({
      BomberManKey.moveUp: keyUp,
      BomberManKey.moveRight: keyRight,
      BomberManKey.moveDown: keyDown,
      BomberManKey.moveLeft: keyLeft,
      BomberManKey.actionBomb: keyBomb,
      BomberManKey.actionThrow: keyThrow,
    });
  }


  LogicalKeyboardKey getLogicalKey(BomberManKey key) => keyMap[key]!;

  BomberManKeyConfig copyWith({
    LogicalKeyboardKey? keyUp,
    LogicalKeyboardKey? keyRight,
    LogicalKeyboardKey? keyDown,
    LogicalKeyboardKey? keyLeft,
    LogicalKeyboardKey? keyBomb,
    LogicalKeyboardKey? keyThrow,
  }) {
    return BomberManKeyConfig.custom(
      keyUp: keyUp ?? keyMap[BomberManKey.moveUp]!,
      keyRight: keyRight ?? keyMap[BomberManKey.moveRight]!,
      keyDown: keyDown ?? keyMap[BomberManKey.moveDown]!,
      keyLeft: keyLeft ?? keyMap[BomberManKey.moveLeft]!,
      keyBomb: keyBomb ?? keyMap[BomberManKey.actionBomb]!,
      keyThrow: keyThrow ?? keyMap[BomberManKey.actionThrow]!,
    );
  }

  BomberManKeyConfig overwriteKey(
    BomberManKey bomberManKey,
    LogicalKeyboardKey keyboardKey,
  ) {
    return BomberManKeyConfig._(
      {
        ...keyMap,
        bomberManKey: keyboardKey,
      }
    );
  }
}

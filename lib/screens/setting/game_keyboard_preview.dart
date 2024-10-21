import 'package:bomber_man/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// 8*13 (104) + 40*13 (520) + 60 = 684
/// 8*13 (104) + 40*13 (520) + 60 = 684
/// 8*12 (96) + 40*11 (440) + 70 + 78 = 684
/// 8*11 (88) + 40*10 (400) + 90 + 106 = 684
/// 8*6 (48) + 50*6 (300) + 336 = 684

// const List<List<String>> _keyboardLayout = [
//   ['Esc', '', '', '', '', '', '', '', '', '', '', '', '', 'Backspace'],
//   ['Tab', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '\\'],
//   ['Caps', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', '\'', 'Enter'],
//   ['Left Shift', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 'Right Shift'],
//   ['Ctrl', 'Win', 'Alt', 'Space', 'Alt', 'Win', 'Ctrl'],
// ];

// const List<List<String?>> _arrowAreaKeyboardLayout = [
//   ['Insert', 'Home', 'PageUp'],
//   ['Delete', 'End', 'PageDown'],
//   [null, null, null],
//   [null, 'ArrowUp', null],
//   ['ArrowLeft', 'ArrowDown', 'ArrowRight'],
// ];

const List<List<LogicalKeyboardKey>> _keyboardLayout = [
  [
    LogicalKeyboardKey.backquote,
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
    LogicalKeyboardKey.digit0,
    LogicalKeyboardKey.minus,
    LogicalKeyboardKey.equal,
    LogicalKeyboardKey.backspace,
  ],
  [
    LogicalKeyboardKey.tab,
    LogicalKeyboardKey.keyQ,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.keyR,
    LogicalKeyboardKey.keyT,
    LogicalKeyboardKey.keyY,
    LogicalKeyboardKey.keyU,
    LogicalKeyboardKey.keyI,
    LogicalKeyboardKey.keyO,
    LogicalKeyboardKey.keyP,
    LogicalKeyboardKey.bracketLeft,
    LogicalKeyboardKey.bracketRight,
    LogicalKeyboardKey.backslash,
  ],
  [
    LogicalKeyboardKey.capsLock,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyG,
    LogicalKeyboardKey.keyH,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.keyL,
    LogicalKeyboardKey.semicolon,
    LogicalKeyboardKey.quote,
    LogicalKeyboardKey.enter,
  ],
  [
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.keyZ,
    LogicalKeyboardKey.keyX,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyV,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyN,
    LogicalKeyboardKey.keyM,
    LogicalKeyboardKey.comma,
    LogicalKeyboardKey.period,
    LogicalKeyboardKey.slash,
    LogicalKeyboardKey.shiftRight,
  ],
  [
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.metaRight,
    LogicalKeyboardKey.controlRight
  ],
];

const List<List<LogicalKeyboardKey?>> _arrowAreaKeyboardLayout = [
  [LogicalKeyboardKey.insert, LogicalKeyboardKey.home, LogicalKeyboardKey.pageUp],
  [LogicalKeyboardKey.delete, LogicalKeyboardKey.end, LogicalKeyboardKey.pageDown],
  [null, null, null],
  [null, LogicalKeyboardKey.arrowUp, null],
  [LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowRight],
];

class GameKeyboardPreview extends StatelessWidget {
  final Map<LogicalKeyboardKey, BomberManKey> keyBindings;

  const GameKeyboardPreview({
    super.key,
    required this.keyBindings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: IconTheme(
          data: IconThemeData(
            size: 18,
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final row in _keyboardLayout) buildKeyboardRow(row), // 對應每一行鍵位
                ],
              ),
              const SizedBox(width: 20.0),
              buildArrowArea(),
              const SizedBox(width: 20.0),
              buildNumPad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildKeyboardRow(List<LogicalKeyboardKey> keys) {
    return Row(
      children:[
        for(final key in keys)
          buildKey(key),
      ],
    );
  }

  Widget buildKey(LogicalKeyboardKey key, [double? customHeight]) {
    Color? color;
    if(keyBindings[key] != null) {
      color = Colors.green;
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        // padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: Colors.black, width: 2),
        ),
        width: getKeyWidth(key), // 設置不同按鍵的寬度
        height: customHeight ?? 40,
        alignment: Alignment.center,
        child: switch(keyBindings[key]) {
          null || BomberManKey.actionThrow => null,
          BomberManKey.moveUp => const Icon(Icons.arrow_upward),
          BomberManKey.moveRight => const Icon(Icons.arrow_forward),
          BomberManKey.moveDown => const Icon(Icons.arrow_downward),
          BomberManKey.moveLeft => const Icon(Icons.arrow_back),
          BomberManKey.actionBomb => const ImageIcon(AssetImage('assets/images/icon_bomb.png')),
        },
      ),
    );
  }

  Widget buildArrowArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final row in _arrowAreaKeyboardLayout)
          SizedBox(
            height: 48,
            child: Row(
              children: [
                for (final key in row)
                  if(key != null)
                    buildKey(key),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildNumPad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            buildKey(LogicalKeyboardKey.numLock),
            buildKey(LogicalKeyboardKey.numpadDivide),
            buildKey(LogicalKeyboardKey.numpadMultiply),
            buildKey(LogicalKeyboardKey.numpadSubtract),
          ],
        ),
        Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    buildKey(LogicalKeyboardKey.numpad7),
                    buildKey(LogicalKeyboardKey.numpad8),
                    buildKey(LogicalKeyboardKey.numpad9),
                  ],
                ),
                Row(
                  children: [
                    buildKey(LogicalKeyboardKey.numpad4),
                    buildKey(LogicalKeyboardKey.numpad5),
                    buildKey(LogicalKeyboardKey.numpad6),
                  ],
                ),
              ],
            ),
            buildKey(LogicalKeyboardKey.numpadAdd, 88),
          ],
        ),

        Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    buildKey(LogicalKeyboardKey.numpad1),
                    buildKey(LogicalKeyboardKey.numpad2),
                    buildKey(LogicalKeyboardKey.numpad3),
                  ],
                ),
                Row(
                  children: [
                    buildKey(LogicalKeyboardKey.numpad0),
                    buildKey(LogicalKeyboardKey.numpadDecimal),
                  ],
                ),
              ],
            ),
            buildKey(LogicalKeyboardKey.numpadEnter, 88),
          ],
        ),
      ],
    );
  }

  double getKeyWidth(LogicalKeyboardKey key) {
    // 根據按鍵設置寬度
    switch (key) {
      case LogicalKeyboardKey.backspace:
        return 60;
      case LogicalKeyboardKey.enter:
        return 78;
      case LogicalKeyboardKey.tab:
        return 60;
      case LogicalKeyboardKey.capsLock:
        return 70;
      case LogicalKeyboardKey.shiftLeft:
        return 90;
      case LogicalKeyboardKey.shiftRight:
        return 106;

      case LogicalKeyboardKey.space:
        return 336;
      case LogicalKeyboardKey.controlLeft:
      case LogicalKeyboardKey.controlRight:
      case LogicalKeyboardKey.altLeft:
      case LogicalKeyboardKey.altRight:
      case LogicalKeyboardKey.metaLeft:
      case LogicalKeyboardKey.metaRight:
        return 50;
      case LogicalKeyboardKey.numpad0:
        return 88;
      default:
        return 40; // 默認寬度
    }
  }

  // double getKeyWidth(String keyLabel) {
  //   // 根據按鍵的標籤設置寬度
  //   switch (keyLabel) {
  //     case 'Backspace':
  //       return 60;
  //     case 'Enter':
  //       return 78;
  //     case 'Tab':
  //       return 60;
  //     case 'Caps':
  //       return 70;
  //     case 'Left Shift':
  //       return 90;
  //     case 'Right Shift':
  //       return 106;
  //     case 'Space':
  //       return 336;
  //     case 'Ctrl':
  //     case 'Alt':
  //     case 'Win':
  //       return 50;
  //     case '0':
  //       return 88;
  //     default:
  //       return 40; // 默認寬度
  //   }
  // }
}
import 'package:bomber_man/providers/settings_provider.dart';
import 'package:bomber_man/widgets/dialog/base_style_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../utils/my_transition.dart';
import 'game_keyboard_preview.dart';

typedef BindingKeyChanged = void Function(BomberManKeyConfig);
typedef ConfigSelector = BomberManKeyConfig Function(
    BuildContext context, SettingsProvider provider);

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      settings: const RouteSettings(
        name: 'Setting',
      ),
      builder: (context) => const SettingScreen(),
    );
  }

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // (
  //   BomberManKey currentBomberManKey,
  //   LogicalKeyboardKey currentBindingKey,
  //   BindingKeyChanged callback,
  // )? currentBindingState;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SettingsProvider>();

    return ColoredBox(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(24),
          children: [
            buildPlayerSetting(
              'Player1 Key Setting',
                  (context, provider) => provider.player1KeyConfig,
                  (config) => provider.player1KeyConfig = config,
            ),
            buildPlayerSetting(
              'Player2 Key Setting',
                  (context, provider) => provider.player2KeyConfig,
                  (config) => provider.player2KeyConfig = config,
            ),
          ],
        ),
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(MaterialLocalizations.of(context).backButtonTooltip),
          ),

          /// Test Keyboard Preview
          // ElevatedButton(
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         final keyBindings = <LogicalKeyboardKey, BomberManKey>{
          //           for(final MapEntry(:key, :value) in context.read<SettingsProvider>().player1KeyConfig.keyMap.entries)
          //             value: key,
          //         };
          //
          //         return Dialog(
          //           child: GameKeyboardPreview(
          //             keyBindings: keyBindings,
          //           ),
          //         );
          //       },
          //     );
          //   },
          //   child: const Text('Test'),
          // ),
        ],
      ),
    );
  }

  Widget buildPlayerSetting(
      String title,
      ConfigSelector selector,
      BindingKeyChanged onChanged,
      ) {
    const titleStyle = TextStyle(
        fontWeight: FontWeight.w900, color: Colors.white, fontSize: 36);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: titleStyle),
              const SizedBox(width: 16.0),
              Selector<SettingsProvider, BomberManKeyConfig>(
                selector: selector,
                builder: (context, value, _) {
                  return IconButton(
                    tooltip: '查看鍵位',
                    onPressed: () => showKeyboardPreviewDialog(value),
                    icon: const Icon(Icons.search),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Align(
            alignment: Alignment.centerLeft,
            child: Selector<SettingsProvider, BomberManKeyConfig>(
              selector: selector,
              builder: (context, value, child) => buildKeyTable(value, onChanged),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildKeyTable(
      BomberManKeyConfig currentConfig, BindingKeyChanged onChange) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
      },
      children: [
        ...currentConfig.keyMap.entries.map(
              (entry) {
            final description = entry.key.description;
            return TableRow(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    // shape: const StadiumBorder(),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    side: const BorderSide(width: 2, color: Colors.white),
                  ),
                  onPressed: () async {
                    final result = await _showKeyBindingDialog(
                      context,
                      entry.key,
                      entry.value,
                    );
                    if(result == null) return;
                    onChange.call(currentConfig.overwriteKey(
                      entry.key,
                      result,
                    ));
                  },
                  child: entry.value == LogicalKeyboardKey.space
                      ? const Text(
                          'Space',
                          style: TextStyle(color: Colors.white),
                        )
                      : Text(
                          entry.value.keyLabel,
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }


  Future<void> showKeyboardPreviewDialog(BomberManKeyConfig selected) async {
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',

        builder: (context) {
          final keyBindings = <LogicalKeyboardKey, BomberManKey>{
            for(final MapEntry(:key, :value) in selected.keyMap.entries)
              value: key,
          };

          return BaseStyleDialog(
            backgroundColor: Colors.blueGrey,
            alignment: Alignment.bottomCenter,
            child: GameKeyboardPreview(
              keyBindings: keyBindings,
            ),
          );
        }
    );
  }
}


Future<LogicalKeyboardKey?> _showKeyBindingDialog(
    BuildContext context,
    BomberManKey bomberManKey,
    LogicalKeyboardKey currentKey,
    ) {
  return showGeneralDialog<LogicalKeyboardKey?>(
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    context: context,
    transitionBuilder: buildMyMaterialDialogTransitions,
    pageBuilder: (context, animation, secondaryAnimation) {
      return _KeyBindingDialog(initialPair: (bomberManKey, currentKey));
    },
  );
}

class _KeyBindingDialog extends StatefulWidget {
  const _KeyBindingDialog({
    required this.initialPair,
  });

  final (BomberManKey, LogicalKeyboardKey) initialPair;

  @override
  State<_KeyBindingDialog> createState() => _KeyBindingDialogState();
}


class _KeyBindingDialogState extends State<_KeyBindingDialog> {

  final FocusNode focusNode = FocusNode();
  late BomberManKey currentBomberManKey = widget.initialPair.$1;
  late LogicalKeyboardKey currentLogicalKey = widget.initialPair.$2;

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseStyleDialog(child: buildBody());
  }

  Widget buildBody() {

    return KeyboardListener(
      autofocus: true,
      focusNode: focusNode,
      onKeyEvent: (event) {
        setState(() => currentLogicalKey = event.logicalKey);
        Navigator.of(context).pop(currentLogicalKey);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('PRESSED THE DESIRED KEY FOR', style: TextStyle(color: Colors.white, fontSize: 18)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(currentBomberManKey.description, style: const TextStyle(color: Colors.white, fontSize: 24)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
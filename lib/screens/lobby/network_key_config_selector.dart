import 'package:bomber_man/widgets/dialog/base_style_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../setting/game_keyboard_preview.dart';

class NetworkKeyConfigSelector extends StatelessWidget {
  const NetworkKeyConfigSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, (List<BomberManKeyConfig>, BomberManKeyConfig)>(
      selector: (context, provider) =>
      (
        [
          provider.player1KeyConfig,
          provider.player2KeyConfig,
        ],
        provider.networkKeyConfig,
      ),
      builder: (context, record, child) {
        final (configs, selected) = record;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: DropdownButton<BomberManKeyConfig>(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                value: selected,
                items: configs.mapIndexed((index, config) {
                  return DropdownMenuItem<BomberManKeyConfig>(
                    value: config,
                    child: Text('Player${index+1} KeyConfig'),
                  );
                }).toList(),
                onChanged: (value) {
                  if(value == null) return;
                  context.read<SettingsProvider>().networkKeyConfig = value;
                },
              ),
            ),
            const SizedBox(width: 16.0),
            IconButton(
              tooltip: '查看鍵位',
              onPressed: () {
                showKeyboardPreviewDialog(context, selected);
              },
              icon: const Icon(Icons.search),
            ),
          ],
        );
      },
    );
  }

  Future<void> showKeyboardPreviewDialog(BuildContext context, BomberManKeyConfig selected) async {
    // showGeneralDialog(
    //   context: context,
    //   barrierColor: Colors.transparent,
    //   barrierDismissible: true,
    //   barrierLabel: 'Dismiss',
    //   transitionBuilder: buildMyMaterialDialogTransitions,
    //   pageBuilder: (context, animation, secondaryAnimation) {
    //     final keyBindings = <LogicalKeyboardKey, BomberManKey>{
    //       for(final MapEntry(:key, :value) in selected.keyMap.entries)
    //         value: key,
    //     };
    //
    //     return BaseStyleDialog(
    //       backgroundColor: Colors.blueGrey,
    //       alignment: Alignment.bottomCenter,
    //       child: GameKeyboardPreview(
    //         keyBindings: keyBindings,
    //       ),
    //     );
    //   },
    // );

    showDialog(
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

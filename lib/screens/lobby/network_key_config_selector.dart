import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

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

        return DropdownButton<BomberManKeyConfig>(
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
        );
      },
    );
  }
}

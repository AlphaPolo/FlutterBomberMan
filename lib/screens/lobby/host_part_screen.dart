import 'package:bomber_man/extensions/iterable_extension.dart';
import 'package:bomber_man/screens/lobby/guest_row.dart';
import 'package:bomber_man/screens/lobby/network_key_config_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/peer_provider.dart';

class HostPartScreen extends StatelessWidget {
  const HostPartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PeerProvider(context),
          lazy: false,
        ),
      ],
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('HOST'),
            const SizedBox(height: 12.0),
            Selector<PeerProvider, String>(
              selector: (context, provider) => provider.peerId ?? '準備中...',
              builder: (context, peerId, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText('ID: $peerId'),
                    IconButton(
                      onPressed: () => Clipboard.setData(ClipboardData(text: peerId)),
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                );
              },
            ),
            const GuestRow(),
            const SizedBox(height: 32.0),
            const NetworkKeyConfigSelector(),
            const SizedBox(height: 32.0),
            buildBottomRow(context),
          ],
        ),
      ),
    );
  }

  Widget buildBottomRow(BuildContext context) {
    return Selector<PeerProvider, bool>(
      selector: (context, provider) => provider.connections > 0,
      builder: (context, canPlay, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Return'),
            ),
            if(canPlay)
            ElevatedButton(
              onPressed: () {
                context.read<PeerProvider>().play(context);
              },
              child: const Text('Play'),
            ),
          ].joinElement(const SizedBox(width: 16.0)),
        );
      }
    );
  }

}
